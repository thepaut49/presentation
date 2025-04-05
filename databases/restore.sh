#!/bin/bash

POSTGRES_PASSWORD=$1
BACKEND_USER_PASSWORD=$2
KC_DB_PASSWORD=$3

# Définition des bases de données et leurs paramètres
declare -A databases
databases["db_data_generator"]="backend/backup"
databases["db_keycloak"]="keycloak/backup"

# Définition des utilisateurs et mots de passe associés
declare -A users
users["db_data_generator"]="root"
users["db_keycloak"]="keycloak"

declare -A passwords
passwords["db_data_generator"]="$BACKEND_USER_PASSWORD"
passwords["db_keycloak"]="$KC_DB_PASSWORD"

# Nom du conteneur PostgreSQL
CONTAINER_NAME=$(docker ps --format "{{.Names}}" | grep "data-generator_postgres")
echo "Le conteneur PostgreSQL est : $CONTAINER_NAME"

echo "Attente de 30 secondes avant de continuer..."
sleep 30
echo "Reprise du script après 30 secondes."

# Initialisation du user et de la base du backend
echo "➡️ Lancement de 01_init_db.sql"
docker exec -i "$CONTAINER_NAME" env PGPASSWORD="$POSTGRES_PASSWORD" \
       psql -U postgres --dbname "postgres" -v backend_password="$BACKEND_USER_PASSWORD" < "backend/01_init_db.sql"
echo "✔️ Exécution du script backend/01_init_db.sql terminée."

# Initialisation du user et de la base de keycloak
echo "➡️ Lancement de 05_init_db.sql"
docker exec -i "$CONTAINER_NAME" env PGPASSWORD="$POSTGRES_PASSWORD" \
       psql -U postgres --dbname "postgres" -v keycloak_password="$KC_DB_PASSWORD"< "keycloak/05_init_db.sql"
echo "✔️ Exécution du script keycloak/05_init_db.sql terminée."

# Restauration de chaque base de données
for db in "${!databases[@]}"; do
    BACKUP_DIR="${databases[$db]}"
    DB_USER="${users[$db]}"
    DB_PASSWORD="${passwords[$db]}"

    echo "🔄 Restauration de la base '$db' avec l'utilisateur '$DB_USER'..."

    # Vérifier si le dossier de backup existe
    if [ ! -d "$BACKUP_DIR" ]; then
        echo "❌ Dossier $BACKUP_DIR introuvable, saut de la restauration pour $db."
        continue
    fi

    # Restaurer chaque fichier .sql dans le dossier de backup
    for file in "$BACKUP_DIR"/*.sql; do
        if [ -f "$file" ]; then
            echo "➡️ Restauration de $file..."
            docker exec -i "$CONTAINER_NAME" env PGPASSWORD="$DB_PASSWORD" \
                psql -U "$DB_USER" -d "$db" < "$file"
            echo "✔️ Restauration de $file terminée pour '$db'."
        fi
    done
done

echo "✅ Restauration complète."