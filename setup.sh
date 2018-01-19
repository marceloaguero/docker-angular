#!/bin/bash
DOCKER_HUB_USER="marceloaguero"
DOCKER_HUB_REPO="ng-app"
VERSION="latest"

# Clean everything
rm -fr ng-app
mkdir ng-app

# Run a nodejs docker container. Install angular cli.
# Then initialize a basic angular app in it
docker run -it -v ng-app:/ng-app node:carbon-alpine npm install -g @angular/cli && ng new ng-app --skip-install

# Copy Dockerfiles
cp Dockerfile ng-app/
cp Dockerfile.prod ng-app/

# Copy nginx configuration
mkdir ng-app/nginx
cp nginx-default.conf ng-app/nginx/default.conf

# Build docker image
#cd ng-app
#docker build -t $DOCKER_HUB_USER/$DOCKER_HUB_REPO:$VERSION .

# Run it (to test)
#docker run -d -p 8080:80 $DOCKER_HUB_USER/$DOCKER_HUB_REPO:$VERSION