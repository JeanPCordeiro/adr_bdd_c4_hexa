# 7. Choix du déploiement (Fargate ou Lambda)

## Statut
Proposé

## Contexte
L'utilisateur souhaite pouvoir choisir le mode de déploiement de l'API FizzBuzz entre AWS Fargate Serverless et AWS Lambda, via un paramètre. Cela nécessite une flexibilité dans l'infrastructure de déploiement tout en conservant les principes d'architecture hexagonale et de serverless.

## Décision
Nous allons modifier le processus de déploiement pour permettre le choix entre AWS Fargate et AWS Lambda. Cela sera géré principalement au niveau de l'Infrastructure as Code (Terraform) et du script de déploiement (`deploy.sh`).

### Implémentation :
1.  **Code de l'application** : L'architecture hexagonale permet au code métier de rester indépendant du mode de déploiement. Seuls les adaptateurs d'entrée (interface) et le point d'entrée de l'application devront être adaptés pour fonctionner dans les deux environnements (un adaptateur HTTP pour Fargate/Express, et un adaptateur Lambda pour Lambda/API Gateway).
2.  **Terraform** : Nous créerons des modules Terraform distincts pour Fargate et Lambda, ou un module paramétrable capable de provisionner l'un ou l'autre en fonction d'une variable d'entrée.
3.  **Script de déploiement (`deploy.sh`)** : Le script sera mis à jour pour accepter un paramètre (`--target=fargate` ou `--target=lambda`) qui déterminera le type de déploiement à effectuer.
4.  **GitHub Actions** : Le workflow CI/CD sera ajusté pour passer ce paramètre au script de déploiement.

## Conséquences
### Positives
*   **Flexibilité accrue** : L'utilisateur peut choisir le mode de déploiement le plus adapté à ses besoins (coût, performance, gestion).
*   **Réutilisation du code métier** : L'architecture hexagonale garantit que la logique métier reste inchangée, quel que soit le mode de déploiement.
*   **Optimisation des coûts** : Lambda peut être plus économique pour des charges de travail sporadiques, tandis que Fargate peut être plus adapté pour des charges plus constantes ou des applications nécessitant plus de ressources ou un contrôle plus fin du conteneur.
*   **Apprentissage et exploration** : Offre la possibilité d'explorer les deux principales options serverless d'AWS pour les applications conteneurisées et sans serveur.

### Négatives
*   **Complexité de l'infrastructure** : La gestion de deux chemins de déploiement distincts (même si partiels) ajoute de la complexité à l'Infrastructure as Code et au script de déploiement.
*   **Maintenance accrue** : Nécessite de maintenir deux configurations d'infrastructure et potentiellement deux adaptateurs d'entrée pour l'application.
*   **Taille du bundle Lambda** : Pour Lambda, la taille du package de déploiement peut devenir un facteur limitant si toutes les dépendances sont incluses, nécessitant potentiellement des couches Lambda ou des optimisations.

## Alternatives considérées
*   **Uniquement Fargate** : Rejeté car l'utilisateur souhaite la flexibilité de choisir Lambda.
*   **Uniquement Lambda** : Rejeté car Fargate a déjà été implémenté et offre des avantages pour certains cas d'usage.
*   **Déploiement manuel** : Rejeté car cela irait à l'encontre des principes de CI/CD et d'automatisation.


