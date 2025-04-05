# Étape 1 : Construction
FROM maven:3.9.5-eclipse-temurin-21 AS build
WORKDIR /build

COPY pom.xml .
RUN mvn dependency:resolve

COPY src ./src
RUN mvn clean package -DskipTests

# Étape 2 : Image d'exécution sécurisée
FROM eclipse-temurin:21-jre-jammy
WORKDIR /app

# Créer un utilisateur non privilégié
RUN groupadd -g 1001 appgroup && \
    useradd -r -u 1001 -g appgroup appuser

COPY --from=build /build/target/backend*.war /app/backend.war

# Changer les permissions et exécuter en tant que l'utilisateur non privilégié
RUN chown -R appuser:appgroup /app
USER appuser

EXPOSE 9090
ENTRYPOINT ["java", "-jar", "/app/backend.war"]
