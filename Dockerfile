FROM node:18-alpine as build

WORKDIR /app

# Copy package files
COPY package.json package-lock.json* ./

# Clear npm cache and install dependencies
RUN npm cache clean --force && npm install

# Copy application files (exclude node_modules)
COPY public ./public
COPY src ./src
COPY .env* ./

# Build the app
RUN npm run build

# Production environment
FROM nginx:1.28.0-alpine

# Copy build from the previous stage
COPY --from=build /app/build /usr/share/nginx/html

# Copy nginx config
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"] 
