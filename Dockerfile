# syntax=docker/dockerfile:1

# ---- Build stage ----
FROM node:22-alpine AS build
WORKDIR /app
# Avoid running husky in container builds
ENV HUSKY=0
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# ---- Runtime stage ----
FROM node:22-alpine AS runtime
WORKDIR /app
ENV NODE_ENV=production
# Copy only runtime artifacts
COPY --from=build /app/lib ./lib
COPY package*.json ./
RUN npm ci --omit=dev --ignore-scripts && npm cache clean --force
EXPOSE 3000
# Start SSE server on port 3000
CMD ["node", "lib/index.js", "--port", "3000"]
