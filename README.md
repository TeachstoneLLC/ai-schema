# ai-schema
Schema for PostgreSQL database backing svc-ai

## Before you do anything else

Make sure your `postgres` container is up and running (`docker container ls`).

You also need to make sure `sem` ([schema evolution manager](https://github.com/mbryzek/schema-evolution-manager)) is installed; 
the [laptop setup script](https://github.com/TeachstoneLLC/tools/) will do this for you.

## First-time setup

Run the init script to set up a role in the development database:

    SVC_PASSWORD=some_password ./init.sh

and again to set up the test database:

    PGDATABASE=ai_test SVC_PASSWORD=some_password ./init.sh

You'll get an error this time complaining `ERROR:  role "svc_ai" already exists` – ignore it.

## Applying pending migrations

    ./update.sh

This will apply changes to both `ai_development` and `ai_test`. Use environment variables
and/or a `~/.pgpass` file to enable password-less login to your local PosgreSQL server.

## Adding new migrations

Write your SQL in a new file in this directory, for example:

```sql
-- ai-schema/new_migration.sql
create table foo (id serial, name varchar not null);
insert into foo (name) values ('bar'), ('baz'), ('buzz');
```

Then use `sem-add` to add it:

    sem-add new_migration.sql

This will rename the file and move it to the `scripts/` folder, but _does not apply the change_.
To apply the change, run the `update.sh` script as noted above; this will apply the change to both
the development and test databases.

`sem-add` also adds the (renamed) file to `git` but _does not commit it_. After applying, if you
are satisfied with your change, commit it (the usual way).

## Conventions and Design Guidelines

It's important that everyone working on the database design be more or less in agreement on naming conventions,
common database design decisions, and other technical standards. It is perhaps more important for us to be in
agreement than it is for each choice to be fully, 100% optimized as the best choice – so what follows here are
the default choices about:
    - how database objects should be named, spelled, and inflected
    - common design patterns that should be applied
    - other design choices commonly made

### Naming Conventions

1. Table names should be lower-case, snake-cased (i.e. `snake_case`, not `CamelCase` or `kebab-cased`), and pluralized:
    - `widgets` and not `Widgets` (capitalized) or `widget` (singular)
    - `widget_attributes` (plural, snake-cased) and not `widgetAttribute` (`camelCase`, singular)

2. To the greatest extent possible, the name of a table should clearly reflect the meaning of a single row of data
    - In a `widgets` table, each record would describe a single `widget`
    - In a `job_files` table, each record would describe a single file used for a job

3. Column names should be similarly clear in their meaning, and again lower-snake-cased (`lower_snake_case`).

4. Columns that describe quantities should also embed the units of those quantities in their names, if applicable:
    - `total_steps` would imply the column is counting the number of steps
    - `elapsed_time_seconds` to clearly indicate the column counts the number of seconds (and not simply `elapsed_time`)

5. Avoid using the table name in the column name: `pets.name` instead of `pets.pet_name`

6. In general, follow Ruby on Rails conventions regarding foreign keys and join tables, for example:
    - Given that Owners have Pets, expect an `owners` table and a `pets` table, and a `pets.owner_id` column
        * the foreign key column is singular: `owner_id` instead of `owners_id`
        * the FK column repeats the source table name along with the primary key: `owner_id` instead of merely `owner`
    - In a many-to-many join table, for example representing `accounts` and `users`:
        * list the tables alphabetically: `account_users` and not `user_accounts`
        * the first table listed is singular, the second is plural: `account_users` and not `accounts_user` or `accounts_users`

7. All tables require comments:
    - `comment on table accounts is 'Describes client accounts; each record is 1 account';`

8. Virtually all columns require comments:
    - `comment on column accounts.name is 'The name of the account';`

9. Please make your comments useful, with an eye toward eliminating ambiguity:
    - `comment on column job_histories.processing_end_time is 'UTC timestamp at which step processing ended; this is null for steps that haven''t finished processing yet.';`

10. Certain very common columns always mean the same thing, and do not require comments:
    - `id` - the sequential integer ID (starting at 1) for the primary key of a table
    - `created_at`, `updated_at`, `deleted_at` – the UTC timestamp at which a record was created, updated, or soft-deleted
    - `uuid` – a Universally Unique Identifier that functions as an alternate key for this record, and can safely be shared externally
        * like `id` values, `uuid` values should never change
    - `slug` – a string intended to be used in a URL to uniquely identify this record as part of a route/URI.
        * No more than 80 characters
        * lower-case alpha-numeric values and the dash character are allowed, but must start with a letter: `^[a-z][-a-z0-9]*$`
    - `key` – a unique key for this record used in place of an integer `id`
        * No more than 32 characters
        * upper-case alpha-numeric values and the underscore character are allowed, but must start with a letter: `^[A-Z][_A-Z0-9]*$`
        * should human-readable; the intent of these columns is to provide referential integrity without compromising readability
    - `description` – Describes the meaning of this particular record; usually used alongside `key` columns

### Common design patterns and choices

**Enum tables.** In many cases it is useful to have a column in a table that denotes some enumerable value, and it would be helpful
to users of that table (e.g. in reporting) to be able to read the value as plain English. Consider a `pets` table that lists
the pets of various people. In the U.S., people commonly own dogs and cats, but it's not uncommon to see rabbits as pets, and
occasionally there are more "exotic" pet types:

```
pets
--------------------------------------------
| id | animal_type | name                  |
+----+-------------+-----------------------+
|  1 | DOG         | Fido                  |
|  2 | CAT         | Snowball              |
|  3 | DOG         | Santa's Little Helper |
|  4 | SPIDER      | Charlotte             |
|  5 | PIG         | Wilbur                |
|  6 | CAT         | Dinah                 |
+----+-------------+-----------------------+
select animal_type, count(*) from pets group by animal_type;

animal_type | COUNT(*)
------------+---------+
DOG         |       2 |
CAT         |       2 |
SPIDER      |       1 |
PIG         |       1 |
------------+---------+
```

Leaving `animal_type` as a string type simplifies reporting, as there is no need to join to a table 
listing the types of animals in order to see results in plain English. However, this leaves open the 
possibility of typos:
```
insert into pets (animal_type, name) values ('SPYDER', 'Shelob');
```

To enforce referential integrity and constrain the values that `animal_types` may take on, it's useful
to declare an enum table consisting of a `key` and optionally a `description` column, and use the key as
a foreign key in the `pets` table:

```
create table animal_types (
    key varchar(32) NOT NULL PRIMARY KEY,
    description varchar NOT NULL
);
create table pets (
    id SERIAL PRIMARY KEY,
    animal_type varchar(32) NOT NULL REFERENCES animal_types(key),
    name varchar(500) NOT NULL
);
```

Such tables are useful for values that will wind up enumerated in the back-end service that reads the data
(as a Java `Enum` or in Ruby as class property).

**Timestamp fields.** For major entities it can be useful to include timestamp fields which will indicate
when a record was created, updated, or marked for deletion. When using any one of these, all three should 
be included. They are:
* `created_at` – the UTC timestamp at which the record was inserted
* `updated_at` – the UTC timestamp at which the record was most recently updated
* `deleted_at` – if present, the UTC timestamp at which the record was marked as deleted

They can be included in a table definition as follows:
```
    created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL default now(),
    updated_at TIMESTAMP WITHOUT TIME ZONE NOT NULL default now(),
    deleted_at TIMESTAMP WITHOUT TIME ZONE
```
These fields do not require comments. A function is provided to automatically update the `updated_at` field
in cases where the record is modified by any database client besides the service that typically maintains the data.
Install it as follows:
```
    CREATE TRIGGER <table_name>_update_trigger BEFORE UPDATE ON <table_name> FOR EACH ROW EXECUTE PROCEDURE updated_at_timestamp();
```

When defining unique indexes on such tables, it is often useful to use a partial index that excludes deleted records:
```
    CREATE UNIQUE INDEX idx_job_files_name ON job_files (s3_bucket, s3_key) WHERE deleted_at is NULL;
```

**Primary and Alternate Keys.** The vast majority of tables will have a simple `id` column as the primary key (see **Enum Tables** above for an exception), defined as
`id SERIAL PRIMARY KEY`, regardless of whether there is another logical choice for primary key. Having a sequential 
integer as the primary key is a convenience and simplifies model/entity code in the applications that make
use of the data.

However, it's not a good idea for sequential internal identifiers to leak out into the external world, so very
often additional alternate keys should be supplied:
* `uuid` – `uuid UUID NOT NULL default gen_random_uuid()` – this provides a unique and non-sequential key that
           can be shared with external parties
* `slug` – `slug varchar(80) NOT NULL` – Should start with a lower-case letter and can include lower-case letters, numbers, 
           and hyphens. A slug is expected to be unique on the table and can be used in URLs to identify a record 
           using plain English words (useful for Search Engine Optimization or SEO).

PostgreSQL will add unqiue indexes automatically to a primary key, but it will not apply indexes to alternate unique keys, 
so be sure to provide them:
```
    CREATE UNIQUE INDEX idx_job_files_uuid ON job_files (uuid);
```
