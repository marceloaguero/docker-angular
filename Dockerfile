FROM node:carbon-alpine

WORKDIR /ng-app

COPY package.json .

RUN npm set progress=false \
 && npm config set depth 0 \
 && npm cache clean --force \
 && npm install
 
COPY . .

EXPOSE 4200

CMD $(npm bin)/ng serve --host 0.0.0.0 --watch
