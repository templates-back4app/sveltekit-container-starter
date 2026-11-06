# ---- Build stage ----
FROM node:22-alpine AS build
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci
COPY . .
RUN npm run build

# ---- Runtime stage ----
FROM node:22-alpine
WORKDIR /app
ENV NODE_ENV=production HOST=0.0.0.0 PORT=8080

# adapter-node output is self-contained for this starter (no runtime deps);
# package.json is still needed for "type": "module".
COPY --from=build /app/build ./build
COPY package.json ./

EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s \
  CMD wget -qO /dev/null http://127.0.0.1:8080/ || exit 1
USER node
CMD ["node", "build"]
