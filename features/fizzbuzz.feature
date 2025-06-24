Fonctionnalité: Calculer la séquence FizzBuzz
  En tant qu'utilisateur de l'API
  Je veux obtenir la séquence FizzBuzz pour un nombre donné
  Afin de vérifier la logique FizzBuzz

  Scénario: Calculer FizzBuzz pour un nombre divisible par 3 et 5
    Étant donné que le nombre est 15
    Quand je demande la séquence FizzBuzz
    Alors la réponse devrait être "FizzBuzz"

  Scénario: Calculer FizzBuzz pour un nombre divisible par 3
    Étant donné que le nombre est 9
    Quand je demande la séquence FizzBuzz
    Alors la réponse devrait être "Fizz"

  Scénario: Calculer FizzBuzz pour un nombre divisible par 5
    Étant donné que le nombre est 10
    Quand je demande la séquence FizzBuzz
    Alors la réponse devrait être "Buzz"

  Scénario: Calculer FizzBuzz pour un nombre non divisible par 3 ou 5
    Étant donné que le nombre est 7
    Quand je demande la séquence FizzBuzz
    Alors la réponse devrait être "7"

  Scénario: Calculer FizzBuzz pour un nombre négatif
    Étant donné que le nombre est -3
    Quand je demande la séquence FizzBuzz
    Alors la réponse devrait être "Nombre invalide"

  Scénario: Calculer FizzBuzz pour un nombre non entier
    Étant donné que le nombre est 3.5
    Quand je demande la séquence FizzBuzz
    Alors la réponse devrait être "Nombre invalide"

  Scénario: Calculer FizzBuzz pour une entrée non numérique
    Étant donné que l'entrée est "abc"
    Quand je demande la séquence FizzBuzz
    Alors la réponse devrait être "Nombre invalide"


