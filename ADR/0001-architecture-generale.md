# 1. Architecture Générale

## Statut
Proposé

## Contexte
Le projet consiste à développer une API simple qui implémente la logique du FizzBuzz. Cette API doit respecter un ensemble de principes de développement stricts fournis par l'utilisateur, notamment l'utilisation d'ADR, la modélisation C4, le test-first (BDD/TDD), l'architecture hexagonale, le CI/CD avec GitHub Actions, et le déploiement sur AWS Fargate en mode serverless.

## Décision
Nous allons adopter une architecture hexagonale pour cette API. Cette approche nous permettra de séparer clairement la logique métier (domaine) des détails techniques (infrastructure et interfaces). Le déploiement se fera sur AWS Fargate en mode serverless, sans provisionnement direct d'ECS, en utilisant des services AWS appropriés pour une solution entièrement gérée et scalable.

## Conséquences
### Positives
*   **Maintenabilité accrue** : La séparation des préoccupations facilite la compréhension et la modification du code.
*   **Testabilité améliorée** : La logique métier peut être testée indépendamment de l'infrastructure.
*   **Flexibilité technologique** : Les composants d'infrastructure peuvent être remplacés sans affecter le cœur de l'application.
*   **Scalabilité native** : Fargate offre une scalabilité automatique et une gestion simplifiée de l'infrastructure.
*   **Coût optimisé** : Le modèle serverless de Fargate permet de payer uniquement pour les ressources consommées.

### Négatives
*   **Complexité initiale** : La mise en place de l'architecture hexagonale et de l'infrastructure serverless peut être plus complexe au début.
*   **Courbe d'apprentissage** : Nécessite une bonne compréhension des principes de l'architecture hexagonale et des services AWS serverless.
*   **Dépendance AWS** : Bien que l'architecture hexagonale réduise cette dépendance au niveau du code, le déploiement reste lié à l'écosystème AWS.

## Alternatives considérées
*   **Architecture monolithique traditionnelle** : Rejetée car elle ne respecte pas les principes de testabilité et de maintenabilité souhaités.
*   **Déploiement sur EC2/VMs** : Rejeté car ne correspond pas au principe de serverless et implique une gestion d'infrastructure plus lourde.
*   **Déploiement sur AWS Lambda** : Considéré comme une alternative viable pour le serverless, mais Fargate est choisi pour sa capacité à exécuter des conteneurs Docker, offrant plus de flexibilité pour des applications plus complexes à l'avenir et une meilleure portabilité si nécessaire, tout en restant serverless dans le contexte de l'utilisateur (pas de gestion d'ECS).


