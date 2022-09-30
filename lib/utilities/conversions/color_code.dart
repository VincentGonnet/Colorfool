import 'package:flutter/material.dart';

String getFormattedColorCode(Color color) {
  return color.value.toRadixString(16).substring(2);
}

Color getColorFromFormattedCode(String colorCode) {
  return Color(int.parse('ff$colorCode', radix: 16));
}
