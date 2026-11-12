# TP Docker – Déploiement et comparaison de trois API

## Présentation

Ce projet consiste à conteneuriser et déployer trois applications backend développées avec des technologies différentes :

- **Spring Boot** – Java
- **Express.js** – Node.js
- **Laravel** – PHP

Les trois applications utilisent une base de données MySQL commune. Docker Compose permet de gérer les différents services dans un environnement conteneurisé.

Le projet comprend également des tests de performance avec Apache JMeter et la collecte des métriques des conteneurs Docker.

## Architecture

```text
TP_Docker/
│
├── docker/
│   └── docker-compose.yml
│
├── jmeter/
│   ├── springboot/
│   ├── express/
│   └── laravel/
│
├── metrics/
│   ├── stats.csv
│   ├── logs_spring.txt
│   ├── logs_express.txt
│   └── logs_laravel.txt
│
├── scripts/
│
├── init.sql
└── README.md
```

Les projets backend sont conservés dans leurs répertoires respectifs et sont utilisés par Docker Compose pour construire les images.

## Technologies utilisées

| Technologie | Utilisation |
|---|---|
| Docker | Conteneurisation |
| Docker Compose | Orchestration des services |
| Spring Boot | API Java |
| Express.js | API Node.js |
| Laravel | API PHP |
| MySQL 8 | Base de données |
| Apache JMeter 5.6.3 | Tests de charge |
| PowerShell | Commandes et automatisation |

## Services Docker

| Service | Conteneur | Port |
|---|---|---|
| Spring Boot | `spring-api` | 8081 |
| Express.js | `express-api` | 8082 |
| Laravel PHP-FPM | `laravel-php` | Interne |
| Laravel Nginx | `laravel-nginx` | 8083 |
| MySQL | `products-mysql` | 3306 |

## Installation et démarrage

### Prérequis

- Docker Desktop
- Git
- Apache JMeter 5.6.3 (pour les tests de performance)

### Démarrer les services

Depuis le répertoire principal du projet :

```powershell
docker compose -f docker/docker-compose.yml up -d --build
```

### Vérifier les conteneurs

```powershell
docker ps
```

### Consulter les logs

```powershell
docker compose -f docker/docker-compose.yml logs
```

## Base de données

Les trois applications utilisent une base de données MySQL commune nommée `products`.

Le script `init.sql` contient la structure de la table `products` et les données initiales.

Pour initialiser la base de données :

```powershell
docker exec -i products-mysql mysql -uroot -psecret products < init.sql
```

## Accès aux API

Les API sont accessibles localement aux adresses suivantes :

| Application | URL |
|---|---|
| Spring Boot | http://localhost:8081/api/products |
| Express.js | http://localhost:8082/api/products |
| Laravel | http://localhost:8083/api/products |

**Remarque :** certaines routes sont protégées par authentification ou par clé API. Les en-têtes requis doivent être configurés dans les requêtes de test.

## Tests de performance avec JMeter

Apache JMeter est utilisé pour comparer les performances des trois applications backend.

Les plans de test sont organisés par application :

- Spring Boot
- Express.js
- Laravel

### Scénarios de charge

Les tests peuvent être exécutés avec différents nombres d'utilisateurs virtuels :

- 10 utilisateurs
- 50 utilisateurs
- 100 utilisateurs
- 200 utilisateurs

Paramètres de test :

| Paramètre | Valeur |
|---|---|
| Nombre d'utilisateurs | Variable selon le scénario |
| Ramp-up period | 5 secondes |
| Durée du test | 60 secondes |
| Méthode HTTP | GET |
| Endpoint | `/api/products` |

Les résultats JMeter sont exportés au format CSV pour permettre leur analyse et leur comparaison.

## Collecte des métriques Docker

Les métriques des conteneurs sont collectées pendant les tests de charge.

```powershell
docker stats --format "{{.Name}};{{.CPUPerc}};{{.MemUsage}};{{.NetIO}};{{.BlockIO}}" products-mysql spring-api express-api laravel-php laravel-nginx > .\metrics\stats.csv
```

Cette commande collecte :

- Utilisation du processeur (CPU).
- Utilisation de la mémoire (RAM).
- Entrées et sorties réseau (Network I/O).
- Entrées et sorties disque (Block I/O).

La collecte peut être arrêtée avec `Ctrl + C`.

## Collecte des logs applicatifs

Les logs des applications sont exportés dans des fichiers texte.

### Spring Boot

```powershell
docker logs spring-api 2>&1 > .\metrics\logs_spring.txt
```

### Express.js

```powershell
docker logs express-api 2>&1 > .\metrics\logs_express.txt
```

### Laravel

Laravel écrit ses logs applicatifs dans `storage/logs/laravel.log`.

```powershell
docker exec laravel-php cat storage/logs/laravel.log | Set-Content -Encoding utf8 .\metrics\logs_laravel.txt
```

## Résultats

Les fichiers générés permettent de comparer les trois technologies selon plusieurs critères :

- Temps de réponse.
- Débit des requêtes (Throughput).
- Taux d'erreur.
- Utilisation CPU.
- Consommation mémoire.
- Trafic réseau.
- Entrées et sorties disque.

Les résultats CSV peuvent être exploités ultérieurement avec Excel ou Python pour produire des tableaux et des graphiques comparatifs.

## Arrêt des services

Pour arrêter et supprimer les conteneurs et le réseau du projet :

```powershell
docker compose -f docker/docker-compose.yml down
```


Test de charge réussi sous Apache JMeter (10 utilisateurs simultanés).



Les données du volume MySQL nommé sont conservées.

**Attention :** ne pas utiliser `docker compose down -v` si vous souhaitez conserver les données de la base.

## Auteur

Projet réalisé dans le cadre d'un travail pratique sur Docker, la conteneurisation et l'analyse des performances des applications backend.

Test de charge réussi sous Apache JMeter (10 utilisateurs simultanés) springboot.

<img width="982" height="509" alt="Screenshot 2026-11-12 160511" src="https://github.com/user-attachments/assets/4683b80a-ba7c-41d4-9fa8-9b007339b1b6" />

Test de charge réussi pour l'API Laravel (50 utilisateurs).

<img width="883" height="468" alt="Screenshot 2026-11-12 163940" src="https://github.com/user-attachments/assets/19af3866-95cf-4319-949b-0949ae3756e1" />



Test de charge réussi pour l'API Express (10 utilisateurs).   


<img width="915" height="551" alt="Screenshot 2026-11-12 164517" src="https://github.com/user-attachments/assets/dadb167a-d2df-425f-a389-b2b3bffef243" />



Test de charge des opérations CRUD réussi pour l'API Spring Boot (10 utilisateurs).   


<img width="1007" height="541" alt="crudspring" src="https://github.com/user-attachments/assets/1d2a74ef-d0f7-4e6a-a4ef-f39dfba26a0e" />


Test de charge des opérations CRUD réussi pour l'API Laravel (10 utilisateurs).   



<img width="981" height="565" alt="laravelcrud" src="https://github.com/user-attachments/assets/e407bded-8d73-4daa-b15b-4d54889cc534" />



Test de charge des opérations CRUD réussi pour l'API Express (10 utilisateurs).   

<img width="1004" height="575" alt="Screenshot 2026-11-12 192352" src="https://github.com/user-attachments/assets/c57ca1c6-d43c-4f19-b76e-9a8523bf004a" />



