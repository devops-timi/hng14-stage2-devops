FROM node:20-alpine AS builder

WORKDIR /app

COPY package*.json ./
RUN npm install --only=production

FROM node:20-alpine AS production

WORKDIR /app

COPY --from=builder /app/node_modules ./node_modules
COPY app.js ./
COPY views/ ./views/

RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
  CMD wget --spider http://localhost:3000/health || exit 1

CMD ["node", "app.js"]