FROM node:22-slim AS build
WORKDIR /app
COPY package.json package-lock.json tsconfig.json ./
RUN npm ci
COPY src ./src
RUN npm run build

FROM node:22-slim
WORKDIR /app
ENV NODE_ENV=production DB_PATH=/app/data/hausihelfer.db
COPY package.json package-lock.json ./
RUN npm ci --omit=dev && mkdir -p /app/data && chown node:node /app/data
COPY --from=build /app/dist ./dist
# Mount a persistent volume here so usage counters and reports survive restarts.
VOLUME /app/data
EXPOSE 8080
USER node
CMD ["node", "dist/server.js"]
