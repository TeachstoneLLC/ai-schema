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