# 5. Choix de la stratégie CI/CD avec GitHub Actions

## Statut
Proposé

## Contexte
Le projet nécessite une stratégie de CI/CD robuste pour automatiser les tests, la construction, et le déploiement de l'API FizzBuzz. GitHub Actions a été spécifiquement mentionné comme exigence pour l'intégration et le déploiement continus.

## Décision
Nous allons utiliser GitHub Actions pour implémenter une pipeline CI/CD complète qui inclut :
1.  **Tests automatisés** : Exécution des tests unitaires (TDD) et des spécifications BDD à chaque push et pull request.
2.  **Analyse statique** : Vérification de la qualité du code avec des outils de linting et d'analyse de sécurité.
3.  **Construction d'images Docker** : Création automatique d'images Docker et push vers Amazon ECR.
4.  **Déploiement multi-environnements** : Déploiement automatique en staging (branche develop) et en production (branche main).
5.  **Tests de fumée** : Validation du bon fonctionnement de l'API après déploiement.

## Conséquences
### Positives
*   **Automatisation complète** : Réduction des erreurs humaines et accélération des cycles de développement grâce à l'automatisation de toutes les étapes de la pipeline.
*   **Qualité assurée** : Les tests automatisés et l'analyse statique garantissent que seul du code de qualité est déployé en production.
*   **Déploiement sécurisé** : La séparation des environnements et les tests de fumée réduisent les risques de déploiement défaillant.
*   **Traçabilité** : Chaque déploiement est lié à un commit spécifique, facilitant le suivi et le rollback si nécessaire.
*   **Intégration native avec GitHub** : GitHub Actions s'intègre parfaitement avec le repository, simplifiant la configuration et la maintenance.

### Négatives
*   **Dépendance à GitHub** : La pipeline est liée à l'écosystème GitHub, ce qui peut poser des problèmes de portabilité vers d'autres plateformes.
*   **Coût potentiel** : Les minutes d'exécution GitHub Actions peuvent représenter un coût pour les projets avec de nombreuses exécutions.
*   **Complexité de configuration** : La configuration initiale peut être complexe, surtout pour les intégrations avec AWS et les secrets de sécurité.

## Alternatives considérées
*   **Jenkins** : Rejeté car GitHub Actions a été spécifiquement demandé et offre une meilleure intégration native avec GitHub.
*   **GitLab CI/CD** : Rejeté pour les mêmes raisons que Jenkins, bien qu'il soit une excellente alternative.
*   **AWS CodePipeline** : Considéré comme complémentaire mais GitHub Actions reste le choix principal pour respecter les exigences.

