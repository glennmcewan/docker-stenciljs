ARG NODE_ENV=development

#Builder stage
FROM node:10-slim as builder
ENV NODE_ENV=${NODE_ENV}

COPY package*.json ./
RUN npm install

# Final stage/image
FROM node:10-slim
ENV NODE_ENV=${NODE_ENV}
WORKDIR /usr/src/app

COPY --from=builder node_modules node_modules

COPY . .

CMD ["npm", "start"]
