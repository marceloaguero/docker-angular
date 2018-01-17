#!/bin/bash

# Run a nodejs docker container. Install angular cli.
# Then initialize a basic angular app in it
docker run -it -v ng-app:/ng-app node:carbon-alpine npm install -g @angular/cli && ng new ng-app --skip-install

# Build docker image
docker build -t marceloaguero/ng-app .

# Run it (to test)
docker run -d -p 8080:80 marceloaguero/ng-app