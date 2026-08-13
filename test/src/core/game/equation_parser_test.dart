import 'package:flutter_test/flutter_test.dart';
import 'package:messmath/src/core/game/cell_type.dart';
import 'package:messmath/src/core/game/equation_parser.dart';

List<CellType> tokens(String s) {
  return s.split('').map((c) {
    return switch (c) {
      '0' => CellType.zero,
      '1' => CellType.one,
      '2' => CellType.two,
      '3' => CellType.three,
      '4' => CellType.four,
      '5' => CellType.five,
      '6' => CellType.six,
      '7' => CellType.seven,
      '8' => CellType.eight,
      '9' => CellType.nine,
      '+' => CellType.plus,
      '-' => CellType.minus,
      '*' => CellType.multiply,
      '/' => CellType.divide,
      '=' => CellType.equal,
      _ => throw ArgumentError('Unknown cell token: $c'),
    };
  }).toList();
}

void main() {
  group('EquationParser correct equations', () {
    test('simple addition', () {
      final result = EquationParser.evaluate(tokens('1+2=3'));
      expect(result.valid, isTrue);
      expect(result.correct, isTrue);
      expect(result.lhs, 3);
      expect(result.rhs, 3);
    });

    test('respects operator precedence', () {
      final result = EquationParser.evaluate(tokens('2+3*4=14'));
      expect(result.valid, isTrue);
      expect(result.correct, isTrue);
      expect(result.lhs, 14);
      expect(result.rhs, 14);
    });

    test('unary minus at the start', () {
      final result = EquationParser.evaluate(tokens('-3+4=1'));
      expect(result.valid, isTrue);
      expect(result.correct, isTrue);
    });

    test('multi-digit numbers and exact division', () {
      final result = EquationParser.evaluate(tokens('12/3=4'));
      expect(result.valid, isTrue);
      expect(result.correct, isTrue);
      expect(result.lhs, 4);
    });

    test('unary minus after an operator', () {
      final result = EquationParser.evaluate(tokens('2*-3=-6'));
      expect(result.valid, isTrue);
      expect(result.correct, isTrue);
      expect(result.lhs, -6);
    });

    test('double minus', () {
      final result = EquationParser.evaluate(tokens('2--3=5'));
      expect(result.valid, isTrue);
      expect(result.correct, isTrue);
    });
  });

  group('EquationParser invalid equations', () {
    test('missing operand after operator', () {
      final result = EquationParser.evaluate(tokens('2+=3'));
      expect(result.valid, isFalse);
      expect(result.correct, isFalse);
    });

    test('multiple equal signs', () {
      expect(EquationParser.evaluate(tokens('5=5=5')).valid, isFalse);
    });

    test('empty left side', () {
      expect(EquationParser.evaluate(tokens('=5')).valid, isFalse);
    });

    test('empty right side', () {
      expect(EquationParser.evaluate(tokens('5=')).valid, isFalse);
    });

    test('non-exact division', () {
      final result = EquationParser.evaluate(tokens('10/3=3'));
      expect(result.valid, isFalse);
      expect(result.reason, '10 is not divisible by 3');
    });

    test('division by zero', () {
      final result = EquationParser.evaluate(tokens('5/0=0'));
      expect(result.valid, isFalse);
      expect(result.reason, 'Division by zero');
    });

    test('leading operator', () {
      expect(EquationParser.evaluate(tokens('*5=5')).valid, isFalse);
    });

    test('consecutive operators', () {
      expect(EquationParser.evaluate(tokens('2++3=5')).valid, isFalse);
    });

    test('double equal signs', () {
      expect(EquationParser.evaluate(tokens('5==5')).valid, isFalse);
    });

    test('missing equal sign', () {
      final result = EquationParser.evaluate(tokens('1+2'));
      expect(result.valid, isFalse);
      expect(result.reason, 'Missing "="');
    });

    test('empty input', () {
      expect(EquationParser.evaluate(tokens('')).valid, isFalse);
    });
  });

  group('EquationParser valid but incorrect', () {
    test('wrong result', () {
      final result = EquationParser.evaluate(tokens('1+2=4'));
      expect(result.valid, isTrue);
      expect(result.correct, isFalse);
      expect(result.lhs, 3);
      expect(result.rhs, 4);
    });
  });
}
