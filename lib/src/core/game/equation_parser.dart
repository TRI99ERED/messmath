import 'cell_type.dart';

typedef EquationResult = ({
  bool valid,
  bool correct,
  String? reason,
  int? lhs,
  int? rhs,
});

class EquationParser {
  static EquationResult evaluate(List<CellType> tokens) {
    final p = _Parser(tokens);
    try {
      final lhs = p.parseExpression();
      if (!p.match(CellType.equal)) {
        return (
          valid: false,
          correct: false,
          reason: 'Missing "="',
          lhs: lhs,
          rhs: null,
        );
      }
      final rhs = p.parseExpression();
      if (!p.atEnd) {
        return (
          valid: false,
          correct: false,
          reason: 'Unexpected tokens after rhs',
          lhs: lhs,
          rhs: rhs,
        );
      }
      return (
        valid: true,
        correct: lhs == rhs,
        reason: null,
        lhs: lhs,
        rhs: rhs,
      );
    } on _ParseError catch (e) {
      return (
        valid: false,
        correct: false,
        reason: e.message,
        lhs: null,
        rhs: null,
      );
    }
  }
}

class _ParseError implements Exception {
  final String message;
  _ParseError(this.message);
}

class _Parser {
  final List<CellType> tokens;
  int _pos = 0;

  _Parser(this.tokens);

  bool get atEnd => _pos >= tokens.length;

  bool match(CellType type) {
    if (atEnd || tokens[_pos] != type) return false;
    _pos++;
    return true;
  }

  int parseExpression() {
    var value = parseTerm();
    while (!atEnd) {
      final op = tokens[_pos];
      if (op != CellType.plus && op != CellType.minus) break;
      _pos++;
      final rhs = parseTerm();
      value = op == CellType.plus ? value + rhs : value - rhs;
    }
    return value;
  }

  int parseTerm() {
    var value = parseFactor();
    while (!atEnd) {
      final op = tokens[_pos];
      if (op != CellType.multiply && op != CellType.divide) break;
      _pos++;
      final rhs = parseFactor();
      if (op == CellType.multiply) {
        value *= rhs;
      } else {
        if (rhs == 0) throw _ParseError('Division by zero');
        if (value % rhs != 0) {
          throw _ParseError('$value is not divisible by $rhs');
        }
        value ~/= rhs;
      }
    }
    return value;
  }

  int parseFactor() {
    var negative = false;
    if (!atEnd && tokens[_pos] == CellType.minus) {
      negative = true;
      _pos++;
    }
    final n = parseNumber();
    return negative ? -n : n;
  }

  int parseNumber() {
    if (atEnd || !_isDigit(tokens[_pos])) {
      throw _ParseError('Expected a number');
    }
    var value = 0;
    while (!atEnd && _isDigit(tokens[_pos])) {
      value = value * 10 + _digitValue(tokens[_pos]);
      _pos++;
    }
    return value;
  }

  static bool _isDigit(CellType t) =>
      t.index >= CellType.zero.index && t.index <= CellType.nine.index;

  static int _digitValue(CellType t) => t.index - CellType.zero.index;
}
