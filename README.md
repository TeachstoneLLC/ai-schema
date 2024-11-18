# ai-schema
Schema for PostgreSQL database backing svc-ai

## Before you do anything else

Make sure your `postgres` container is up and running (`docker container ls`).

You also need to make sure `sem` ([schema evolution manager](https://github.com/mbryzek/schema-evolution-manager)) is installed; 
the [laptop setup script](https://github.com/TeachstoneLLC/tools/) will do this for you.

## First-time setup

Run the init script to set up a role in the development database:

    SVC_PASS=some_password ./init.sh

and again to set up the test database:

    PGDATABASE=ai_test SVC_PASS=some_password ./init.sh

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
    - `comment on column job_histories.processing_end_time is 'UTC timestamp at which step processing ended; this is null for steps that haven't finished processing yet.';`

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

[ still to come ]