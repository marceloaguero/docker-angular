FROM node:carbon-alpine

COPY package.json ./

## Storing node modules on a separate layer will prevent unnecessary npm installs at each build
RUN npm i && mkdir /ng-app && cp -R ./node_modules ./ng-app

WORKDIR /ng-app
COPY . .
VOLUME /ng-app
EXPOSE 4200
CMD $(npm bin)/ng serve --watch
