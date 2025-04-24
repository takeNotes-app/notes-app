FROM node:18-alpine as build

WORKDIR /app

# Copy package files and install dependencies
COPY package.json ./
RUN npm install

# Copy application files
COPY public ./public
COPY src ./src

# Build the app
RUN npm run build

# Production environment
FROM nginx:1.28.0-alpine

# Create non-root user for nginx
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Create required directories and set permissions
RUN mkdir -p /var/cache/nginx /var/run && \
    chown -R appuser:appgroup /var/cache/nginx /var/run

# Copy build from the previous stage
COPY --from=build /app/build /usr/share/nginx/html
RUN chown -R appuser:appgroup /usr/share/nginx/html

# Copy nginx config
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Add healthcheck
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:80/health || exit 1

EXPOSE 80

# Switch to non-root user
USER appuser

CMD ["nginx", "-g", "daemon off;"]
