FROM node:lts-slim
#Add some debug utilities
RUN apt-get update
RUN apt-get install -y curl wget mc iputils-ping telnet

WORKDIR /usr/src/app
RUN npm install

EXPOSE 8081
CMD [ "nodejs", "index.js" ]
