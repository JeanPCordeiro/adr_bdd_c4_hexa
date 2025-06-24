const express = require('express');

// Adaptateur REST - Interface d'entrée pour l'API
class FizzBuzzRestAdapter {
  constructor(fizzBuzzApplicationService) {
    this.fizzBuzzApplicationService = fizzBuzzApplicationService;
    this.router = express.Router();
    this.setupRoutes();
  }

  setupRoutes() {
    // Endpoint GET pour calculer FizzBuzz
    this.router.get('/fizzbuzz/:number', (req, res) => {
      try {
        const input = req.params.number;
        const result = this.fizzBuzzApplicationService.calculateFizzBuzz(input);
        
        res.json({
          input: input,
          result: result,
          timestamp: new Date().toISOString()
        });
      } catch (error) {
        res.status(500).json({
          error: 'Erreur interne du serveur',
          message: error.message,
          timestamp: new Date().toISOString()
        });
      }
    });

    // Endpoint POST pour calculer FizzBuzz (alternative avec body)
    this.router.post('/fizzbuzz', (req, res) => {
      try {
        const input = req.body.number;
        if (input === undefined) {
          return res.status(400).json({
            error: 'Paramètre manquant',
            message: 'Le paramètre "number" est requis dans le body de la requête',
            timestamp: new Date().toISOString()
          });
        }

        const result = this.fizzBuzzApplicationService.calculateFizzBuzz(input);
        
        res.json({
          input: input,
          result: result,
          timestamp: new Date().toISOString()
        });
      } catch (error) {
        res.status(500).json({
          error: 'Erreur interne du serveur',
          message: error.message,
          timestamp: new Date().toISOString()
        });
      }
    });

    // Endpoint de santé
    this.router.get('/health', (req, res) => {
      res.json({
        status: 'OK',
        service: 'FizzBuzz API',
        timestamp: new Date().toISOString()
      });
    });
  }

  getRouter() {
    return this.router;
  }
}

module.exports = FizzBuzzRestAdapter;

