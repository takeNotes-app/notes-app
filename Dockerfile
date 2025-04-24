FROM node:18-alpine AS build
WORKDIR /app
COPY package.json ./
RUN npm install
COPY public ./public
COPY src    ./src
RUN npm run build

FROM nginxinc/nginx-unprivileged:1.26.3-alpine

USER root
# install wget so healthcheck can run
RUN apk add --no-cache wget
USER 101

# copy your build artifacts
COPY --from=build --chown=101:101 /app/build /usr/share/nginx/html
COPY nginx.conf   /etc/nginx/nginx.conf

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget -O /dev/null http://localhost:8080/health || exit 1

CMD ["nginx", "-g", "daemon off;"]
