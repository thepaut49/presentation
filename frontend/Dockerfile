# Étape 1 : Base
FROM node:22-alpine AS base
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
# Installer PNPM manuellement sans Corepack
RUN npm install -g pnpm@9 && pnpm --version

WORKDIR /app
COPY . /app

# Étape 2 : Installer les dépendances de production
FROM base AS prod-deps
RUN --mount=type=cache,id=pnpm,target=/pnpm/store pnpm install --prod --frozen-lockfile

# Étape 3 : Construire l'application
FROM base AS build
RUN --mount=type=cache,id=pnpm,target=/pnpm/store pnpm install --frozen-lockfile
RUN pnpm run build

# Vérification des fichiers générés
RUN ls -la /app/.output/server || (echo "Build failed: /app/.output/server not found" && exit 1)

# Étape 4 : Image finale
FROM node:22-alpine

# Créer un utilisateur non-root
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /app

# Copier uniquement les fichiers nécessaires
COPY --from=prod-deps /app/node_modules /app/node_modules
COPY --from=build /app/.output /app/.output

# Changer les permissions pour l'utilisateur non-root
RUN chown -R appuser:appgroup /app

# Exposer le port de l'application
EXPOSE 3000

# Activer les options de sécurité
USER appuser

# Définit la commande de démarrage de l'application
CMD ["node", "/app/.output/server/index.mjs"]
