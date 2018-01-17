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

# Create Dockerfile
cat <<EOF >ng-app/Dockerfile
### STAGE 1: Build ###

# We label our stage as 'builder'
FROM node:carbon-alpine as builder

COPY package.json ./

RUN npm set progress=false && npm config set depth 0 && npm cache clean --force

## Storing node modules on a separate layer will prevent unnecessary npm installs at each build
RUN npm i && mkdir /ng-app && cp -R ./node_modules ./ng-app

WORKDIR /ng-app

COPY . .

## Build the angular app in production mode and store the artifacts in dist folder
RUN $(npm bin)/ng build --prod --build-optimizer


### STAGE 2: Setup ###

FROM nginx:1.13-alpine

## Copy our default nginx config
COPY nginx/default.conf /etc/nginx/conf.d/

## Remove default nginx website
RUN rm -rf /usr/share/nginx/html/*

## From 'builder' stage copy over the artifacts in dist folder to default nginx public folder
COPY --from=builder /ng-app/dist /usr/share/nginx/html

CMD ["nginx", "-g", "daemon off;"]
EOF

# Create nginx configuration
mkdir ng-app/nginx
cat <<EOF >ng-app/nginx/default.conf
server {

  listen 80;

  sendfile on;

  default_type application/octet-stream;


  gzip on;
  gzip_http_version 1.1;
  gzip_disable      "MSIE [1-6]\.";
  gzip_min_length   256;
  gzip_vary         on;
  gzip_proxied      expired no-cache no-store private auth;
  gzip_types        text/plain text/css application/json application/javascript application/x-javascript text/xml application/xml application/xml+rss text/javascript;
  gzip_comp_level   9;


  root /usr/share/nginx/html;


  location / {
    try_files $uri $uri/ /index.html =404;
  }

}
EOF

# Build docker image
cd ng-app
docker build -t $DOCKER_HUB_USER/$DOCKER_HUB_REPO:$VERSION .

# Run it (to test)
docker run -d -p 8080:80 $DOCKER_HUB_USER/$DOCKER_HUB_REPO:$VERSION