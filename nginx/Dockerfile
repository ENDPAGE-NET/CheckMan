# Stage 1: Build React app
FROM node:20-alpine AS builder
WORKDIR /app
COPY frontend/web/package*.json ./
RUN npm ci
COPY frontend/web/ .
RUN npm run build

# Stage 2: Serve with Nginx
FROM nginx:alpine
COPY nginx/nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=builder /app/dist /usr/share/nginx/html
