#!/bin/zsh

# Step 1: we need to know the version we're building; get it via maven
PROJECT_VERSION=$(mvn help:evaluate -Dexpression=project.version -q -DforceStdout)

# Ensure PROJECT_VERSION is set
if [ -z "$PROJECT_VERSION" ]; then
  echo "Error: PROJECT_VERSION is not set."
  exit 1
fi

# we will tag via SHA of current commit in CircleCI:
GIT_SHA=$(git rev-parse --verify HEAD)

# Remove the image if it already exists:
if [[ -n "$(docker images -q ai-schema:$PROJECT_VERSION 2> /dev/null)" ]]; then
  docker image rm ai-schema:$PROJECT_VERSION
fi

# Now build the Docker image:
docker build --tag ai-schema:$GIT_SHA \
  --tag ai-schema:latest \
  --build-arg project_version=$PROJECT_VERSION \
  --build-arg config=$config_file .
