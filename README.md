# API FizzBuzz - Architecture Hexagonale avec Déploiement Flexible (Fargate/Lambda)

## Vue d'ensemble

Ce projet implémente une API REST FizzBuzz en respectant les principes de développement suivants :
- Architecture Decision Records (ADR) en syntaxe MADR
- Modélisation C4 avec PlantUML
- Développement Test-First (BDD puis TDD)
- Architecture hexagonale
- CI/CD avec GitHub Actions
- **Déploiement flexible : AWS Fargate OU AWS Lambda (au choix)**
- Langage Node.js

## 🆕 Nouveauté : Choix de déploiement

L'application peut maintenant être déployée sur **deux cibles serverless** différentes :

### 🐳 **AWS Fargate**
- Conteneurs Docker serverless
- Idéal pour applications avec état ou nécessitant plus de contrôle
- Auto-scaling basé sur CPU/mémoire
- Application Load Balancer intégré

### ⚡ **AWS Lambda**
- Fonctions serverless pures
- Idéal pour charges sporadiques
- Scaling automatique jusqu'à zéro
- API Gateway intégré

## Structure du projet mise à jour

```
fizzbuzz-api/
├── ADR/                          # Architecture Decision Records
│   ├── 0001-architecture-generale.md
│   ├── 0002-choix-modelisation-c4-plantuml.md
│   ├── 0003-strategie-de-test.md
│   ├── 0004-choix-nodejs.md
│   ├── 0005-strategie-ci-cd-github-actions.md
│   ├── 0006-deploiement-aws-fargate-serverless.md
│   └── 0007-choix-deploiement-fargate-lambda.md  # 🆕
├── C4_Model/                     # Diagrammes d'architecture C4
│   ├── 01_System_Context.puml
│   ├── 02_Container.puml
│   └── 03_Component.puml
├── features/                     # Spécifications BDD
│   └── fizzbuzz.feature
├── src/                          # Code source (Architecture hexagonale)
│   ├── domain/                   # Logique métier
│   │   └── fizzbuzz.js
│   ├── application/              # Services d'application
│   │   ├── fizzbuzz-application-port.js
│   │   └── fizzbuzz-application-service.js
│   ├── interfaces/               # Adaptateurs d'entrée (Fargate)
│   │   └── fizzbuzz-rest-adapter.js
│   ├── adapters/                 # 🆕 Adaptateurs d'entrée (Lambda)
│   │   └── fizzbuzz-lambda-adapter.js
│   ├── infrastructure/           # Adaptateurs de sortie
│   ├── index.js                  # Point d'entrée Fargate/Express
│   └── lambda.js                 # 🆕 Point d'entrée Lambda
├── tests/                        # Tests unitaires (TDD)
│   └── domain/
│       └── fizzbuzz.test.js
├── terraform/                    # Infrastructure as Code
│   ├── modules/
│   │   ├── fargate/              # Module Fargate
│   │   └── lambda/               # 🆕 Module Lambda
│   └── environments/
│       ├── staging/              # Fargate staging
│       ├── production/           # Fargate production
│       ├── staging-lambda/       # 🆕 Lambda staging
│       └── production-lambda/    # 🆕 Lambda production
├── .github/workflows/            # CI/CD GitHub Actions
│   └── ci-cd.yml                 # 🆕 Mis à jour pour Fargate/Lambda
├── Dockerfile                    # Image Docker (Fargate)
├── deploy.sh                     # 🆕 Script de déploiement flexible
└── package.json                  # Configuration Node.js
```

## 🚀 Déploiement

### Script de déploiement unifié

Le script `deploy.sh` permet de choisir la cible de déploiement :

```bash
# Déploiement Fargate (défaut)
./deploy.sh staging fargate
./deploy.sh production fargate

# Déploiement Lambda
./deploy.sh staging lambda
./deploy.sh production lambda

# Raccourcis (fargate par défaut)
./deploy.sh staging
./deploy.sh production
```

### Options de déploiement

| Commande | Environnement | Cible | Description |
|----------|---------------|-------|-------------|
| `./deploy.sh staging fargate` | Staging | Fargate | Conteneurs Docker sur ECS Fargate |
| `./deploy.sh staging lambda` | Staging | Lambda | Fonction Lambda + API Gateway |
| `./deploy.sh production fargate` | Production | Fargate | Conteneurs Docker sur ECS Fargate |
| `./deploy.sh production lambda` | Production | Lambda | Fonction Lambda + API Gateway |

### CI/CD automatique

Le workflow GitHub Actions déploie automatiquement selon les règles :

#### Déploiement automatique Fargate (défaut)
- **Staging** : Push sur `develop` → Déploiement Fargate
- **Production** : Push sur `main` → Déploiement Fargate

#### Déploiement automatique Lambda
- **Staging** : Push sur `develop` avec `[lambda]` dans le message de commit
- **Production** : Push sur `main` avec `[lambda]` dans le message de commit

#### Déploiement manuel
- Interface GitHub Actions avec choix de l'environnement et de la cible

### Exemples de commits

```bash
# Déploiement Fargate automatique
git commit -m "feat: amélioration de l'API FizzBuzz"

# Déploiement Lambda automatique
git commit -m "feat: amélioration de l'API FizzBuzz [lambda]"
```

## Architecture hexagonale adaptée

### Adaptateurs d'entrée multiples

L'architecture hexagonale permet d'avoir plusieurs adaptateurs d'entrée :

#### Pour Fargate (Express)
- **fizzbuzz-rest-adapter.js** : Adaptateur REST classique avec Express
- **index.js** : Point d'entrée serveur HTTP

#### Pour Lambda (API Gateway)
- **fizzbuzz-lambda-adapter.js** : Adaptateur Lambda avec gestion des événements
- **lambda.js** : Point d'entrée fonction Lambda

### Logique métier partagée

Le **domaine** et l'**application** restent identiques :
- **fizzbuzz.js** : Logique métier pure
- **fizzbuzz-application-service.js** : Orchestration

## API Endpoints (identiques pour les deux cibles)

### Fargate (via ALB)
```
https://fizzbuzz-staging-alb-xxx.eu-west-1.elb.amazonaws.com/
```

### Lambda (via API Gateway)
```
https://xxx.execute-api.eu-west-1.amazonaws.com/staging/
```

### Endpoints disponibles
- `GET /` - Documentation de l'API
- `GET /api/health` - Vérification de l'état
- `GET /api/fizzbuzz/{number}` - Calcul FizzBuzz (paramètre URL)
- `POST /api/fizzbuzz` - Calcul FizzBuzz (body JSON)

## Comparaison Fargate vs Lambda

| Aspect | AWS Fargate | AWS Lambda |
|--------|-------------|------------|
| **Type** | Conteneurs serverless | Fonctions serverless |
| **Démarrage à froid** | ~10-30s | ~1-3s |
| **Durée max** | Illimitée | 15 minutes |
| **Mémoire** | 512MB - 30GB | 128MB - 10GB |
| **Coût** | Par seconde d'exécution | Par requête + durée |
| **Scaling** | Auto-scaling ECS | Auto-scaling natif |
| **Monitoring** | CloudWatch + ECS | CloudWatch + X-Ray |
| **Cas d'usage** | Apps web, APIs constantes | APIs sporadiques, événements |

## Développement local

### Tests (identiques pour les deux cibles)
```bash
npm test
npm run test:coverage
```

### Test local Fargate
```bash
npm start
curl http://localhost:3000/api/fizzbuzz/15
```

### Test local Lambda
```bash
# Test direct de la fonction
node -e "
const { handler } = require('./src/lambda');
handler({
  requestContext: { http: { method: 'GET', path: '/api/fizzbuzz/15' } },
  pathParameters: { number: '15' }
}).then(console.log);
"
```

## Infrastructure as Code

### Modules Terraform

#### Module Fargate (`terraform/modules/fargate/`)
- ECS Cluster + Service
- Application Load Balancer
- Auto Scaling
- ECR Repository

#### Module Lambda (`terraform/modules/lambda/`)
- Fonction Lambda
- API Gateway v2
- CloudWatch Logs
- IAM Roles

### Environnements

Chaque environnement a sa propre configuration :
- `staging/` et `production/` pour Fargate
- `staging-lambda/` et `production-lambda/` pour Lambda

## Monitoring et observabilité

### Fargate
- **Logs** : CloudWatch Logs (`/ecs/fizzbuzz-{env}`)
- **Métriques** : ECS + ALB metrics
- **Scaling** : CPU/Memory based

### Lambda
- **Logs** : CloudWatch Logs (`/aws/lambda/fizzbuzz-{env}-function`)
- **Métriques** : Lambda metrics (duration, errors, invocations)
- **Scaling** : Automatic based on requests

## Sécurité

### Commune aux deux cibles
- IAM roles avec principe du moindre privilège
- Audit npm automatique
- Scan de sécurité dans CI/CD

### Spécifique Fargate
- Security Groups restrictifs
- Scan d'images Docker dans ECR

### Spécifique Lambda
- Fonction dans VPC si nécessaire
- Chiffrement des variables d'environnement

## Évolutivité et maintenance

### Avantages de l'architecture hexagonale
- **Code métier réutilisable** : Aucune modification du domaine
- **Adaptateurs interchangeables** : Facile de passer de Fargate à Lambda
- **Tests unitaires partagés** : Même logique, mêmes tests
- **Déploiement flexible** : Choix de la cible selon les besoins

### Stratégies de migration
1. **Développement** : Tester sur Lambda pour les coûts
2. **Staging** : Valider sur Fargate pour la production
3. **Production** : Choisir selon la charge et les besoins

## Documentation des décisions

L'ADR 0007 documente la décision d'ajouter le support Lambda en complément de Fargate, avec les justifications et alternatives considérées.

## Contribution

1. Créer une branche feature
2. Implémenter les changements avec tests
3. Choisir la cible de déploiement :
   - Commit normal → Fargate
   - Commit avec `[lambda]` → Lambda
4. Créer une pull request vers develop
5. Le déploiement se fait automatiquement selon le message de commit

