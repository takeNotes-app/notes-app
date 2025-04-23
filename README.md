# 📘 Cahier des Charges – Application de Prise de Notes

## 1. Contexte et objectifs

Ce projet a pour objectif de créer une **application web de prise de notes** utilisant une stack moderne :
- **Frontend** : React
- **Backend** : Node.js avec Express
- **Base de données** : MongoDB
- **Conteneurisation** : Docker & Docker Compose

L'utilisateur pourra ajouter, consulter et visualiser ses notes de manière simple à travers une interface web conviviale.

---

## 2. Fonctionnalités attendues

### Fonctionnalités principales :
- 📝 **Création de note** : l'utilisateur peut saisir un texte et l'enregistrer.
- 📖 **Affichage des notes** : toutes les notes enregistrées sont listées.
- 🗑️ (Facultatif) **Suppression de note** : l'utilisateur peut supprimer une note.

---

## 3. Architecture technique

### 3.1 Frontend (React)
- Interface utilisateur simple en React.
- Consommation de l'API REST du backend.
- Application servie via Nginx dans un conteneur Docker.

### 3.2 Backend (Node.js / Express)
- API REST avec deux routes principales :
  - `GET /api/notes` : récupérer toutes les notes.
  - `POST /api/notes` : ajouter une nouvelle note.
- Connexion à une base de données MongoDB.
- Serveur tournant sur le port 5000 dans un conteneur Docker.

### 3.3 Base de données (MongoDB)
- Stockage des notes sous forme de documents avec un champ `content`.
- Volume Docker pour la persistance des données.

### 3.4 Déploiement (Azure)

L'application complète sera **déployée sur Microsoft Azure** à l'aide des services suivants :
- **Azure Container Instances** ou **Azure App Service** pour héberger les conteneurs Docker (frontend et backend).
- Un **nom DNS personnalisé** sera configuré pour accéder à l'application en ligne.

Objectif : permettre l'accès à l'application via un navigateur, sans configuration locale, et s'initier à la mise en production cloud.

---

## 4. Conteneurisation

Utilisation de **Docker** pour isoler chaque composant de l'application :
- Un conteneur pour le frontend
- Un conteneur pour le backend
- Un conteneur pour MongoDB

### Docker Compose
- Définition de l'ensemble des services dans un fichier `docker-compose.yml`.
- Réseau interne pour la communication entre services.

---

## 5. Dépendances et prérequis

- **Docker** et **Docker Compose** installés.
- Connaissances de base en JavaScript / Node.js / React recommandées.

---

## 6. Livrables

- Code source complet (frontend, backend, Dockerfiles).
- Fichier `docker-compose.yml`.
- Ce cahier des charges (`CDC.md` en markdown).

# Notes App

A full-stack notes application with a dark theme and markdown support. This application stores notes in a MongoDB database and uses Docker for easy deployment.

## Features

- Create, view, and delete notes
- Markdown support
- Dark theme
- Persistent storage with MongoDB
- Dockerized application

## Prerequisites

- [Docker](https://www.docker.com/products/docker-desktop)
- [Docker Compose](https://docs.docker.com/compose/install/)

## Getting Started

1. Clone the repository:
   ```
   git clone <repository-url>
   cd notes-app-stack
   ```

2. Start the application using Docker Compose:
   ```
   docker-compose up -d
   ```

3. Access the application:
   - Frontend: http://localhost
   - Backend API: http://localhost:5000/api
   - Health check: http://localhost:5000/health

4. To stop the application:
   ```
   docker-compose down
   ```

## Project Structure

```
notes-app-stack/
├── docker-compose.yml
├── notes-app/               # Frontend (React)
│   ├── Dockerfile
│   ├── public/
│   ├── src/
│   └── ...
└── notes-app-backend/       # Backend (Node.js/Express)
    ├── Dockerfile
    ├── index.js
    └── ...
```

## Development

### Running Locally (without Docker)

#### Frontend

```
cd notes-app
npm install
npm start
```

#### Backend

```
cd notes-app-backend
npm install
npm run dev
```

## Environment Variables

### Frontend (.env)

- `REACT_APP_API_URL`: Backend API URL

### Backend (.env)

- `PORT`: Port number (default: 5000)
- `MONGODB_URI`: MongoDB connection string
- `NODE_ENV`: Node environment (development, production)

## License

MIT
