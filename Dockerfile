FROM node:8.11.4

RUN npm -g config set user root
RUN npm install -g elm@0.18.0
ENV NODE_PATH ${NODE_PATH}:/src/lib

WORKDIR /src
