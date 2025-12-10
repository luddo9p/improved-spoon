# --- Stage 1: Build (L'usine de construction) ---
FROM node:20-alpine AS builder

WORKDIR /app

# Copie des fichiers de dépendances
COPY package.json package-lock.json* ./

# Installation des dépendances avec NPM
# "npm ci" est plus strict et sûr que "npm install" pour la prod
RUN npm ci

# Copie du code source
COPY . .

# Génération du site statique
RUN npm run generate

# --- Stage 2: Production (Le serveur web) ---
FROM nginx:alpine-slim AS production

# Suppression de la config par défaut
RUN rm /etc/nginx/conf.d/default.conf

# Copie de notre config Nginx
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copie des fichiers générés par Nuxt (dans .output/public)
COPY --from=builder /app/.output/public /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]