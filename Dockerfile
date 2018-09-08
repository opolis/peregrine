FROM node:8.11.4

RUN npm -g config set user root
ENV NODE_PATH ${NODE_PATH}:/src/lib

WORKDIR /src
