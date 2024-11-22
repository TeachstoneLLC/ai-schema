FROM ruby:3.1.4

RUN gem install schema-evolution-manager

RUN  apt-get update -qq && apt-get upgrade -qq --no-install-recommends  \
  && apt-get install --no-install-recommends -qq postgresql-client

RUN addgroup --system teachstone && \
    adduser --system teachstone --ingroup teachstone

ENV APP_HOME=/var/deploy
WORKDIR $APP_HOME

COPY . $APP_HOME

RUN chown -R teachstone:teachstone $APP_HOME

USER teachstone
# Note we are using the Shell form of ENTRYPOINT to allow for environment variable substitution
ENTRYPOINT sem-apply --url postgresql://$PGUSER@$PGHOST:$PGPORT/$PGDATABASE
