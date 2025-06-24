# 2. Choix de la modélisation C4 et PlantUML

## Statut
Proposé

## Contexte
Pour documenter l'architecture de l'API FizzBuzz, il est nécessaire d'utiliser une méthode de modélisation claire et standardisée, conformément aux principes de développement énoncés par l'utilisateur. Le C4 Model a été spécifiquement mentionné comme exigence.

## Décision
Nous allons utiliser le C4 Model pour la modélisation de l'architecture de l'API FizzBuzz. Les diagrammes seront générés en utilisant la syntaxe C4-PlantUML, ce qui permettra de maintenir les diagrammes sous forme de code (Diagrams as Code) et de les intégrer facilement dans le processus de CI/CD pour une génération automatique.

## Conséquences
### Positives
*   **Clarté et compréhension** : Le C4 Model offre une approche hiérarchique (Contexte, Conteneurs, Composants, Code) qui facilite la compréhension de l'architecture à différents niveaux d'abstraction.
*   **Documentation as Code** : L'utilisation de PlantUML permet de versionner les diagrammes avec le code source, assurant ainsi que la documentation reste à jour.
*   **Automatisation** : Les diagrammes peuvent être générés automatiquement dans le pipeline CI/CD, réduisant l'effort manuel et les erreurs.
*   **Collaboration** : Le format texte de PlantUML facilite la revue de code et la collaboration sur les diagrammes.

### Négatives
*   **Courbe d'apprentissage** : Nécessite une familiarisation avec la syntaxe PlantUML et les concepts du C4 Model.
*   **Outils nécessaires** : Requiert l'installation de PlantUML et de ses dépendances pour la génération locale des diagrammes.
*   **Complexité pour les diagrammes très détaillés** : Pour le niveau 


Code, la complexité des diagrammes peut devenir importante et potentiellement difficile à maintenir.

## Alternatives considérées
*   **Diagrammes dessinés manuellement (ex: Lucidchart, Draw.io)** : Rejeté car ne permet pas la documentation as code et la génération automatique.
*   **Autres outils de modélisation (ex: UML standard avec des outils graphiques)** : Rejeté car le C4 Model a été spécifiquement demandé et PlantUML offre une bonne intégration avec le code.

