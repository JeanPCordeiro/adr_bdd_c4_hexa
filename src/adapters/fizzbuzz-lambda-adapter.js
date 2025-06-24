const FizzBuzzApplicationService = require('../application/fizzbuzz-application-service');

// Adaptateur Lambda - Interface d'entrée pour AWS Lambda
class FizzBuzzLambdaAdapter {
  constructor() {
    this.fizzBuzzApplicationService = new FizzBuzzApplicationService();
  }

  // Handler principal pour AWS Lambda
  async handler(event, context) {
    try {
      console.log('Event reçu:', JSON.stringify(event, null, 2));
      
      // Gestion des différents types d'événements (API Gateway, ALB, etc.)
      const request = this.parseEvent(event);
      const response = await this.processRequest(request);
      
      return this.formatResponse(response, event);
    } catch (error) {
      console.error('Erreur dans le handler Lambda:', error);
      return this.formatErrorResponse(error, event);
    }
  }

  // Parse l'événement Lambda pour extraire les informations de requête
  parseEvent(event) {
    // API Gateway v2.0 (HTTP API)
    if (event.version === '2.0' && event.requestContext && event.requestContext.http) {
      return {
        method: event.requestContext.http.method,
        path: event.requestContext.http.path,
        pathParameters: event.pathParameters || {},
        queryStringParameters: event.queryStringParameters || {},
        body: event.body ? (event.isBase64Encoded ? Buffer.from(event.body, 'base64').toString() : event.body) : null,
        headers: event.headers || {},
        isApiGateway: true,
        version: '2.0'
      };
    }
    
    // API Gateway v1.0 (REST API)
    if (event.requestContext && event.requestContext.requestId) {
      return {
        method: event.httpMethod,
        path: event.path,
        pathParameters: event.pathParameters || {},
        queryStringParameters: event.queryStringParameters || {},
        body: event.body ? (event.isBase64Encoded ? Buffer.from(event.body, 'base64').toString() : event.body) : null,
        headers: event.headers || {},
        isApiGateway: true,
        version: '1.0'
      };
    }
    
    // Application Load Balancer
    if (event.requestContext && event.requestContext.elb) {
      return {
        method: event.httpMethod,
        path: event.path,
        pathParameters: this.extractPathParameters(event.path),
        queryStringParameters: event.queryStringParameters || {},
        body: event.body ? (event.isBase64Encoded ? Buffer.from(event.body, 'base64').toString() : event.body) : null,
        headers: event.headers || {},
        isApiGateway: false,
        isALB: true
      };
    }
    
    // Événement direct (pour les tests)
    return {
      method: event.method || 'GET',
      path: event.path || '/',
      pathParameters: event.pathParameters || {},
      queryStringParameters: event.queryStringParameters || {},
      body: event.body || null,
      headers: event.headers || {},
      isApiGateway: false,
      isDirect: true
    };
  }

  // Extrait les paramètres de chemin pour ALB
  extractPathParameters(path) {
    const pathParts = path.split('/');
    const parameters = {};
    
    // Pattern simple pour /api/fizzbuzz/:number
    if (pathParts.length >= 4 && pathParts[1] === 'api' && pathParts[2] === 'fizzbuzz') {
      parameters.number = pathParts[3];
    }
    
    return parameters;
  }

  // Traite la requête et retourne une réponse
  async processRequest(request) {
    const { method, path, pathParameters, queryStringParameters, body, headers } = request;
    
    // Route de santé
    if (path === '/api/health' || path === '/health') {
      return {
        statusCode: 200,
        body: {
          status: 'OK',
          service: 'FizzBuzz API (Lambda)',
          timestamp: new Date().toISOString(),
          version: '1.0.0'
        }
      };
    }
    
    // Route racine
    if (path === '/' || path === '') {
      return {
        statusCode: 200,
        body: {
          message: 'API FizzBuzz - Architecture Hexagonale (Lambda)',
          version: '1.0.0',
          endpoints: [
            'GET /api/health - Vérification de l\'état de l\'API',
            'GET /api/fizzbuzz/{number} - Calcul FizzBuzz via paramètre URL',
            'POST /api/fizzbuzz - Calcul FizzBuzz via body JSON'
          ],
          timestamp: new Date().toISOString()
        }
      };
    }
    
    // Route FizzBuzz GET
    if (method === 'GET' && (path.startsWith('/api/fizzbuzz/') || pathParameters.number)) {
      const number = pathParameters.number || path.split('/').pop();
      const result = this.fizzBuzzApplicationService.calculateFizzBuzz(number);
      
      return {
        statusCode: 200,
        body: {
          input: number,
          result: result,
          timestamp: new Date().toISOString()
        }
      };
    }
    
    // Route FizzBuzz POST
    if (method === 'POST' && (path === '/api/fizzbuzz' || path === '/fizzbuzz')) {
      if (!body) {
        return {
          statusCode: 400,
          body: {
            error: 'Paramètre manquant',
            message: 'Le paramètre "number" est requis dans le body de la requête',
            timestamp: new Date().toISOString()
          }
        };
      }
      
      let requestBody;
      try {
        requestBody = typeof body === 'string' ? JSON.parse(body) : body;
      } catch (error) {
        return {
          statusCode: 400,
          body: {
            error: 'Body JSON invalide',
            message: 'Le body de la requête doit être un JSON valide',
            timestamp: new Date().toISOString()
          }
        };
      }
      
      if (requestBody.number === undefined) {
        return {
          statusCode: 400,
          body: {
            error: 'Paramètre manquant',
            message: 'Le paramètre "number" est requis dans le body de la requête',
            timestamp: new Date().toISOString()
          }
        };
      }
      
      const result = this.fizzBuzzApplicationService.calculateFizzBuzz(requestBody.number);
      
      return {
        statusCode: 200,
        body: {
          input: requestBody.number,
          result: result,
          timestamp: new Date().toISOString()
        }
      };
    }
    
    // Route non trouvée
    return {
      statusCode: 404,
      body: {
        error: 'Endpoint non trouvé',
        message: `L'endpoint ${method} ${path} n'existe pas`,
        timestamp: new Date().toISOString()
      }
    };
  }

  // Formate la réponse selon le type d'événement
  formatResponse(response, event) {
    const { statusCode, body } = response;
    
    // API Gateway v2.0
    if (event.version === '2.0') {
      return {
        statusCode: statusCode,
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
          'Access-Control-Allow-Headers': 'Content-Type, Authorization'
        },
        body: JSON.stringify(body)
      };
    }
    
    // API Gateway v1.0
    if (event.requestContext && event.requestContext.requestId) {
      return {
        statusCode: statusCode,
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
          'Access-Control-Allow-Headers': 'Content-Type, Authorization'
        },
        body: JSON.stringify(body)
      };
    }
    
    // Application Load Balancer
    if (event.requestContext && event.requestContext.elb) {
      return {
        statusCode: statusCode,
        statusDescription: `${statusCode} ${this.getStatusText(statusCode)}`,
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify(body)
      };
    }
    
    // Événement direct
    return {
      statusCode: statusCode,
      body: body
    };
  }

  // Formate la réponse d'erreur
  formatErrorResponse(error, event) {
    console.error('Erreur:', error);
    
    const errorResponse = {
      statusCode: 500,
      body: {
        error: 'Erreur interne du serveur',
        message: error.message,
        timestamp: new Date().toISOString()
      }
    };
    
    return this.formatResponse(errorResponse, event);
  }

  // Retourne le texte de statut HTTP
  getStatusText(statusCode) {
    const statusTexts = {
      200: 'OK',
      400: 'Bad Request',
      404: 'Not Found',
      500: 'Internal Server Error'
    };
    return statusTexts[statusCode] || 'Unknown';
  }
}

module.exports = FizzBuzzLambdaAdapter;

