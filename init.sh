#!/bin/sh

# using sh instead of bash/zsh because the production containers use sh only
# however we could potentially change this, since in theory these DB scripts could run
# from a bastion host (EC2 instance) vs. a container.

# This script initializes sem

# Check to make sure $SVC_PASSWORD is defined and has a value
if [ -z "$SVC_PASSWORD" ]; then
  echo "Error: SVC_PASSWORD is not defined"
  exit 1
fi

# If PGHOST isn't set, set it to a default value of localhost
if [ -z "$PGHOST" ]; then
  export PGHOST=localhost
fi

# If PGPORT isn't set, set it to a default value of 5432
if [ -z "$PGPORT" ]; then
  export PGPORT=5432
fi

# If PGUSER isn't set, set it to a default value of postgres
if [ -z "$PGUSER" ]; then
  export PGUSER=postgres
fi

# If PGPASSWORD isn't set, set it to a default value of password
if [ -z "$PGPASSWORD" ]; then
  export PGPASSWORD=password
fi

# If PGDATABASE isn't set, set it to a default value of ai_development
if [ -z "$PGDATABASE" ]; then
  export PGDATABASE=ai_development
fi

# First, establish the new service role of svc_ai
psql -U $PGUSER -d $PGDATABASE -c "CREATE ROLE svc_ai WITH LOGIN PASSWORD '$SVC_PASSWORD';"

psql -U $PGUSER -d $PGDATABASE -c "GRANT all on database $PGDATABASE TO svc_ai;"

psql -U $PGUSER -d $PGDATABASE -c "GRANT all on schema public TO svc_ai;"