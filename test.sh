#!/bin/sh

# If PGUSER isn't set, set it to a default value of postgres
if [ -z "$PGUSER" ]; then
  export PGUSER=postgres
fi

# If PGDATABASE isn't set, set it to a default value of ai_development
if [ -z "$PGDATABASE" ]; then
  export PGDATABASE=ai_development
fi

psql -U $PGUSER -d $PGDATABASE -v ON_ERROR_STOP=1 < test.sql

#exit $?
