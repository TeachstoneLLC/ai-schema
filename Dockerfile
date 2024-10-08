FROM ruby:3.1.4

ENV PGUSER=svc_ai
ENV PGHOST=host.docker.internal
ENV PGPORT=5432
ENV PGDATABASE=ai_development
ENV PGPASSWORD=password

RUN gem install schema-evolution-manager

RUN  apt-get update -qq && apt-get upgrade -qq --no-install-recommends  \
  && apt-get install --no-install-recommends -qq postgresql-client

ENV APP_HOME=/var/deploy
WORKDIR $APP_HOME

COPY . $APP_HOME

# Note we are using the Shell form of ENTRYPOINT to allow for environment variable substitution
ENTRYPOINT sem-apply --url postgresql://$PGUSER@$PGHOST:$PGPORT/$PGDATABASE