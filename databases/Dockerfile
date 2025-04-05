FROM postgres:16.2

# Passer temporairement en tant que root pour copier des fichiers ou configurer des permissions
USER root

# Déclaration des arguments passés par GitLab CI
ARG POSTGRES_PASSWORD

# Définir les variables d'environnement pour la création de la base de données
ENV POSTGRES_PASSWORD=$POSTGRES_PASSWORD

# Ajuster les permissions des fichiers pour l'utilisateur postgres
RUN chown -R postgres:postgres /docker-entrypoint-initdb.d /var/lib/postgresql /var/run/postgresql
RUN chmod -R 755 /docker-entrypoint-initdb.d /var/lib/postgresql /var/run/postgresql

# Revenir à l'utilisateur non-root par défaut
USER postgres

# Exposer le port par défaut
EXPOSE 5432
