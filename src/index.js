const express = require('express');
const FizzBuzzApplicationService = require('./application/fizzbuzz-application-service');
const FizzBuzzRestAdapter = require('./interfaces/fizzbuzz-rest-adapter');

// Configuration de l'application Express
const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Configuration CORS pour permettre les requêtes cross-origin
app.use((req, res, next) => {
  res.header('Access-Control-Allow-Origin', '*');
  res.header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
  res.header('Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept, Authorization');
  
  if (req.method === 'OPTIONS') {
    res.sendStatus(200);
  } else {
    next();
  }
});

// Injection de dépendances - Architecture hexagonale
const fizzBuzzApplicationService = new FizzBuzzApplicationService();
const fizzBuzzRestAdapter = new FizzBuzzRestAdapter(fizzBuzzApplicationService);

// Routes
app.use('/api', fizzBuzzRestAdapter.getRouter());

// Route racine
app.get('/', (req, res) => {
  res.json({
    message: 'API FizzBuzz - Architecture Hexagonale',
    version: '1.0.0',
    endpoints: [
      'GET /api/health - Vérification de l\'état de l\'API',
      'GET /api/fizzbuzz/:number - Calcul FizzBuzz via paramètre URL',
      'POST /api/fizzbuzz - Calcul FizzBuzz via body JSON'
    ],
    timestamp: new Date().toISOString()
  });
});

// Gestion des erreurs 404
app.use('*', (req, res) => {
  res.status(404).json({
    error: 'Endpoint non trouvé',
    message: `L'endpoint ${req.method} ${req.originalUrl} n'existe pas`,
    timestamp: new Date().toISOString()
  });
});

// Gestion globale des erreurs
app.use((error, req, res, next) => {
  console.error('Erreur non gérée:', error);
  res.status(500).json({
    error: 'Erreur interne du serveur',
    message: error.message,
    timestamp: new Date().toISOString()
  });
});

// Démarrage du serveur
if (require.main === module) {
  app.listen(PORT, '0.0.0.0', () => {
    console.log(`Serveur FizzBuzz API démarré sur le port ${PORT}`);
    console.log(`Accès local: http://localhost:${PORT}`);
    console.log(`Documentation des endpoints: http://localhost:${PORT}/`);
  });
}

module.exports = app;

