# 6. Choix du déploiement AWS Fargate serverless

## Statut
Proposé

## Contexte
Le projet nécessite un déploiement sur AWS Fargate en mode serverless, sans avoir à provisionner directement des instances ECS. L'utilisateur a spécifiquement mentionné vouloir du Fargate en serverless sans provisionnement d'ECS, ce qui implique l'utilisation de services AWS gérés pour une approche entièrement serverless.

## Décision
Nous allons utiliser AWS Fargate avec les services suivants pour créer une solution entièrement serverless :
1.  **Amazon ECS avec Fargate** : Pour l'exécution des conteneurs sans gestion de serveurs.
2.  **Application Load Balancer (ALB)** : Pour la distribution du trafic et la haute disponibilité.
3.  **Amazon ECR** : Pour le stockage des images Docker.
4.  **Auto Scaling** : Pour l'adaptation automatique de la capacité en fonction de la charge.
5.  **CloudWatch** : Pour la surveillance et les logs.
6.  **Terraform** : Pour l'Infrastructure as Code et la reproductibilité des déploiements.

Cette approche respecte le principe de l'architecture hexagonale en permettant de déployer l'application sur Fargate ou potentiellement sur Lambda (alternative serverless) sans modification du code métier.

## Conséquences
### Positives
*   **Serverless complet** : Aucune gestion de serveurs ou d'instances EC2, AWS gère entièrement l'infrastructure sous-jacente.
*   **Scalabilité automatique** : Fargate peut automatiquement ajuster le nombre de tâches en fonction de la demande, avec un scaling jusqu'à zéro possible.
*   **Coût optimisé** : Paiement uniquement pour les ressources consommées (CPU et mémoire) pendant l'exécution des tâches.
*   **Haute disponibilité** : Déploiement multi-AZ automatique avec load balancing pour assurer la résilience.
*   **Sécurité renforcée** : Isolation au niveau des tâches, pas de gestion de patches d'OS, et intégration native avec IAM.
*   **Facilité de déploiement** : Déploiements blue-green natifs et rollbacks simplifiés.
*   **Monitoring intégré** : CloudWatch fournit des métriques et logs détaillés sans configuration supplémentaire.

### Négatives
*   **Temps de démarrage** : Les conteneurs Fargate peuvent avoir un temps de démarrage légèrement plus long que Lambda pour les pics de trafic soudains.
*   **Coût pour les charges constantes** : Pour des applications avec une charge très constante et prévisible, des instances réservées pourraient être plus économiques.
*   **Limitations de Fargate** : Certaines limitations en termes de configuration réseau avancée ou de stockage persistant comparé à EC2.
*   **Complexité de l'infrastructure** : Bien que serverless, la configuration initiale avec ALB, ECS, et Auto Scaling peut être complexe.

## Alternatives considérées
*   **AWS Lambda** : Considéré comme une alternative serverless, mais Fargate a été choisi pour sa capacité à exécuter des conteneurs Docker standard et sa meilleure adaptation aux applications web longue durée. Lambda reste une option viable grâce à l'architecture hexagonale.
*   **Amazon EKS Fargate** : Rejeté car plus complexe et orienté Kubernetes, ce qui ne correspond pas aux besoins simples de cette API.
*   **AWS App Runner** : Considéré mais Fargate offre plus de contrôle et de flexibilité pour les configurations avancées et l'intégration avec d'autres services AWS.
*   **Déploiement sur EC2 avec Auto Scaling** : Rejeté car ne respecte pas l'exigence serverless et implique une gestion d'infrastructure plus lourde.

