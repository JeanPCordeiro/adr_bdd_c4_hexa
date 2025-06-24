const fizzBuzz = (number) => {
  if (typeof number !== 'number' || !Number.isInteger(number) || number < 1) {
    return "Nombre invalide";
  }

  if (number % 15 === 0) {
    return "FizzBuzz";
  }
  if (number % 3 === 0) {
    return "Fizz";
  }
  if (number % 5 === 0) {
    return "Buzz";
  }
  return String(number);
};

module.exports = fizzBuzz;

