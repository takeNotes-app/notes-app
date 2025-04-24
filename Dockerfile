# Stage 1: build your React/Angular/etc.
FROM node:18-alpine AS build
WORKDIR /app
COPY package.json ./
RUN npm install
COPY public ./public
COPY src    ./src
RUN npm run build

# Stage 2: serve it with unprivileged NGINX
FROM nginxinc/nginx-unprivileged:1.26.3-alpine

# 1) Copy your build artifacts into NGINX’s webroot
COPY --from=build /app/build /usr/share/nginx/html

# 2) Make sure the nginx user (UID 101) can read/execute
RUN chmod -R a+rX /usr/share/nginx/html

# 3) Drop in your custom config (must listen on 8080)
COPY nginx.conf /etc/nginx/nginx.conf

# 4) Tell Docker what port NGINX is using
EXPOSE 8080

# 5) Healthcheck against the unprivileged port
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:8080/health || exit 1

# 6) Run NGINX in the foreground (already as non-root)
CMD ["nginx", "-g", "daemon off;"]
