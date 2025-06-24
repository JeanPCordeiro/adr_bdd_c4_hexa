

# 4. Choix du langage de développement (Node.js)

## Statut
Proposé

## Contexte
Le langage de développement pour l'API FizzBuzz doit être choisi en accord avec les principes de développement de l'utilisateur, qui a spécifiquement mentionné Node.js.

## Décision
Nous allons utiliser Node.js comme langage de développement principal pour l'API FizzBuzz. Cela inclut l'utilisation de JavaScript (ou TypeScript pour une meilleure robustesse et maintenabilité, si cela est jugé approprié par la suite) pour l'implémentation de la logique métier et des interfaces.

## Conséquences
### Positives
*   **Conformité aux exigences** : Respecte le principe de développement de l'utilisateur concernant l'utilisation de Node.js.
*   **Écosystème riche** : Node.js bénéficie d'un vaste écosystème de bibliothèques et de frameworks (npm) qui peuvent accélérer le développement.
*   **Performance** : Node.js est performant pour les applications I/O-bound, ce qui est souvent le cas des APIs REST.
*   **Un langage pour le frontend et le backend** : Si un frontend web devait être développé ultérieurement, l'utilisation de JavaScript/TypeScript sur les deux couches faciliterait le partage de code et la cohérence.
*   **Serverless-friendly** : Node.js est bien supporté par les plateformes serverless comme AWS Lambda et Fargate, ce qui est cohérent avec la stratégie de déploiement.

### Négatives
*   **Gestion des erreurs asynchrones** : La nature asynchrone de Node.js peut rendre la gestion des erreurs plus complexe si elle n'est pas gérée correctement.
*   **Calcul intensif** : Moins adapté aux tâches intensives en CPU en raison de son modèle d'exécution à thread unique (bien que cela puisse être atténué avec des workers).
*   **Dépendance aux dépendances** : La prolifération de petites dépendances peut parfois entraîner des problèmes de sécurité ou de maintenance si elles ne sont pas gérées avec soin.

## Alternatives considérées
*   **Python (Flask/Django)** : Rejeté car Node.js a été spécifiquement demandé. Bien que Python soit excellent pour les APIs et le serverless, il ne correspond pas à l'exigence.
*   **Java (Spring Boot)** : Rejeté pour les mêmes raisons que Python. Java est robuste mais plus verbeux et ne correspond pas à l'exigence de Node.js.
*   **.NET (ASP.NET Core)** : Rejeté pour les mêmes raisons. Excellent framework mais pas le langage demandé.


