# Stage 1: install dependencies
FROM node:slim AS deps
WORKDIR /app
COPY src/package*.json .
RUN \
  if [ -f package-lock.json ]; then npm ci; \
  else echo "Lockfile not found." && npm install; \
  fi

# Stage 2: build
FROM node:slim AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY src .
RUN npm run build --if-present

# Stage 3: run
FROM node:slim
WORKDIR /app
COPY --from=builder /app/.next/standalone .
COPY --from=builder /app/.next/static ./.next/static
COPY --from=builder /app/public ./public
EXPOSE 3000
CMD ["node", "server.js"]
