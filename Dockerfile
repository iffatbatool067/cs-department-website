# ─── Stage 1: Lint ────────────────────────────────────────
FROM node:20-alpine AS linter
WORKDIR /lint
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run lint

# ─── Stage 2: Serve ───────────────────────────────────────
FROM nginx:1.25-alpine AS production

LABEL maintainer="CS Department DevOps Team"
LABEL description="University CS Department Static Website"
LABEL version="1.0.0"

# Remove default nginx content
RUN rm -rf /usr/share/nginx/html/*

# Copy static website files
COPY --from=linter /lint/src/ /usr/share/nginx/html/

# Copy custom nginx config
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port
EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
  CMD wget -qO- http://localhost/ || exit 1

CMD ["nginx", "-g", "daemon off;"]
