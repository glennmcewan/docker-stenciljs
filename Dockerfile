ARG NODE_ENV=development

#Builder stage
FROM node:10-slim as builder
ENV NODE_ENV=${NODE_ENV}

COPY package*.json ./
RUN npm install

# Test stage
FROM node:10-slim as test
ENV NODE_ENV=${NODE_ENV}
WORKDIR /usr/src/app

# Install latest chrome dev package and fonts to support major charsets (Chinese, Japanese, Arabic, Hebrew, Thai and a few others)
# Note: this installs the necessary libs to make the bundled version of Chromium that Puppeteer
# installs, work.
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list' \
    && apt-get update \
    && apt-get install -y google-chrome-unstable fonts-ipafont-gothic fonts-wqy-zenhei fonts-thai-tlwg fonts-kacst fonts-freefont-ttf \
      --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder node_modules node_modules

COPY . .

CMD ["npm", "test"]

# Final stage/image
FROM node:10-slim
ENV NODE_ENV=${NODE_ENV}
WORKDIR /usr/src/app

COPY --from=builder node_modules node_modules

COPY . .

CMD ["npm", "start"]
