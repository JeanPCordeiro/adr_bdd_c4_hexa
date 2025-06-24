# 3. Stratégie de Test (BDD, TDD)

## Statut
Proposé

## Contexte
Le développement de l'API FizzBuzz doit adhérer au principe de "Test first avec du BDD puis TDD puis code". Cela signifie que les tests doivent être écrits avant le code de production, en commençant par des spécifications comportementales (BDD) suivies de tests unitaires (TDD).

## Décision
Nous allons adopter une approche de développement pilotée par les tests en deux étapes :
1.  **Behavior-Driven Development (BDD)** : Nous commencerons par définir le comportement attendu de l'API et de ses composants clés en utilisant un langage naturel et des outils BDD. Cela permettra de s'assurer que l'application répond aux exigences métier dès le début du cycle de développement.
2.  **Test-Driven Development (TDD)** : Une fois les spécifications BDD établies, nous écrirons des tests unitaires pour chaque fonctionnalité ou composant, en suivant le cycle "rouge-vert-refactor". Ces tests guideront l'implémentation du code de production.

## Conséquences
### Positives
*   **Alignement métier-technique** : Le BDD assure que le développement est aligné avec les attentes métier, réduisant les malentendus et les retouches.
*   **Qualité du code** : Le TDD encourage la conception de code modulaire, testable et robuste, améliorant la qualité globale du logiciel.
*   **Documentation vivante** : Les spécifications BDD et les tests TDD servent de documentation à jour du comportement du système.
*   **Détection précoce des défauts** : Les problèmes sont identifiés et corrigés plus tôt dans le cycle de développement, réduisant les coûts de correction.
*   **Confiance dans les refactorings** : La suite de tests robuste permet de refactoriser le code en toute confiance, sans introduire de régressions.

### Négatives
*   **Temps initial plus long** : L'écriture des tests avant le code peut sembler ralentir le développement au début, bien que cela soit compensé par une réduction des défauts et des refactorings ultérieurs.
*   **Compétences requises** : Nécessite une bonne maîtrise des principes BDD et TDD, ainsi que des outils associés.
*   **Maintenance des tests** : Les tests doivent être maintenus à jour avec l'évolution du code, ce qui peut représenter un effort supplémentaire.

## Alternatives considérées
*   **Développement sans tests** : Rejeté car il conduit à un code de moindre qualité, difficile à maintenir et à faire évoluer, et ne respecte pas les principes de l'utilisateur.
*   **Tests écrits après le code** : Rejeté car cela ne permet pas de guider la conception du code et ne garantit pas la même couverture ou la même qualité que le TDD.
*   **Utilisation exclusive du BDD ou du TDD** : Rejeté car la combinaison des deux offre les avantages de l'alignement métier (BDD) et de la qualité technique (TDD) de manière complémentaire.

