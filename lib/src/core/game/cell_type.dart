import 'dart:ui';

import 'package:messmath/src/features/themes/palette.dart';

enum CellType {
  empty,
  player,
  zero,
  one,
  two,
  three,
  four,
  five,
  six,
  seven,
  eight,
  nine,
  plus,
  minus,
  multiply,
  divide,
  equal;

  String toDisplayString() {
    switch (this) {
      case CellType.empty:
        return '';
      case CellType.player:
        return 'P';
      case CellType.zero:
        return '0';
      case CellType.one:
        return '1';
      case CellType.two:
        return '2';
      case CellType.three:
        return '3';
      case CellType.four:
        return '4';
      case CellType.five:
        return '5';
      case CellType.six:
        return '6';
      case CellType.seven:
        return '7';
      case CellType.eight:
        return '8';
      case CellType.nine:
        return '9';
      case CellType.plus:
        return '+';
      case CellType.minus:
        return '-';
      case CellType.multiply:
        return '*';
      case CellType.divide:
        return '/';
      case CellType.equal:
        return '=';
    }
  }

  Color toColor() {
    switch (this) {
      case CellType.empty:
        return Palette.color20.color;
      case CellType.player:
        return Palette.color27.color;
      case CellType.zero:
        return Palette.color8.color;
      case CellType.one:
        return Palette.color9.color;
      case CellType.two:
        return Palette.color10.color;
      case CellType.three:
        return Palette.color11.color;
      case CellType.four:
        return Palette.color12.color;
      case CellType.five:
        return Palette.color13.color;
      case CellType.six:
        return Palette.color14.color;
      case CellType.seven:
        return Palette.color15.color;
      case CellType.eight:
        return Palette.color18.color;
      case CellType.nine:
        return Palette.color19.color;
      case CellType.plus:
      case CellType.minus:
      case CellType.multiply:
      case CellType.divide:
      case CellType.equal:
        return Palette.color23.color;
    }
  }
}
