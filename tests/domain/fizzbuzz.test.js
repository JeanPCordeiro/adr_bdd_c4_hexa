const fizzBuzz = require("../../src/domain/fizzbuzz");

describe("FizzBuzz Domain Logic", () => {
  test("should return 'FizzBuzz' for numbers divisible by 3 and 5", () => {
    expect(fizzBuzz(15)).toBe("FizzBuzz");
    expect(fizzBuzz(30)).toBe("FizzBuzz");
  });

  test("should return 'Fizz' for numbers divisible by 3", () => {
    expect(fizzBuzz(3)).toBe("Fizz");
    expect(fizzBuzz(9)).toBe("Fizz");
  });

  test("should return 'Buzz' for numbers divisible by 5", () => {
    expect(fizzBuzz(5)).toBe("Buzz");
    expect(fizzBuzz(10)).toBe("Buzz");
  });

  test("should return the number as a string for numbers not divisible by 3 or 5", () => {
    expect(fizzBuzz(1)).toBe("1");
    expect(fizzBuzz(7)).toBe("7");
  });

  test("should return 'Nombre invalide' for negative numbers", () => {
    expect(fizzBuzz(-3)).toBe("Nombre invalide");
    expect(fizzBuzz(-15)).toBe("Nombre invalide");
  });

  test("should return 'Nombre invalide' for non-integer numbers", () => {
    expect(fizzBuzz(3.5)).toBe("Nombre invalide");
    expect(fizzBuzz(0.1)).toBe("Nombre invalide");
  });

  test("should return 'Nombre invalide' for non-numeric input", () => {
    expect(fizzBuzz("abc")).toBe("Nombre invalide");
    expect(fizzBuzz(null)).toBe("Nombre invalide");
    expect(fizzBuzz(undefined)).toBe("Nombre invalide");
  });
});

