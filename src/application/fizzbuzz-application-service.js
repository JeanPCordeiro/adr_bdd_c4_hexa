const FizzBuzzApplicationPort = require('./fizzbuzz-application-port');
const fizzBuzz = require('../domain/fizzbuzz');

// Service d'application - Implémente le port d'application
class FizzBuzzApplicationService extends FizzBuzzApplicationPort {
  /**
   * Calcule la séquence FizzBuzz pour un nombre donné
   * @param {*} input - L'entrée à traiter (peut être n'importe quel type)
   * @returns {string} - Le résultat FizzBuzz
   */
  calculateFizzBuzz(input) {
    // Conversion de l'entrée en nombre si c'est une chaîne numérique
    let number = input;
    if (typeof input === 'string' && !isNaN(input) && !isNaN(parseFloat(input))) {
      number = parseFloat(input);
    }
    
    // Délégation à la logique métier du domaine
    return fizzBuzz(number);
  }
}

module.exports = FizzBuzzApplicationService;

