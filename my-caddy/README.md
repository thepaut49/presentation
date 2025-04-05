# my-caddy
Ce projet est basé sur [caddy server](https://caddyserver.com/)  
Il va nous permettre de faire du https sur toutes nos applications


## Construire l'image Docker :

```sh
docker build -t my-caddy-server .
```

## Démarrer un conteneur :
```sh
VERSION=$VERSION 
CI_REGISTRY_IMAGE=$CI_REGISTRY_IMAGE 
docker compose -f docker-compose.yml up -d
```

