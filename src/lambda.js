const FizzBuzzLambdaAdapter = require('./adapters/fizzbuzz-lambda-adapter');

// Point d'entrée pour AWS Lambda
const lambdaAdapter = new FizzBuzzLambdaAdapter();

// Export du handler pour Lambda
exports.handler = async (event, context) => {
  return await lambdaAdapter.handler(event, context);
};

