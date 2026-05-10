import 'dart:ui';

import 'package:flutter/material.dart';

const Color white = Color(0xFFFFFFFF);
const Color lightWhite = Color(0xFFF9F9F9);
const Color smokyWhite = Color(0xFFF6F6F6);
const Color smokyBorough = Color(0xFFF3F2F2);
const Color gainsborough = Color(0xFFE7E7E7);
const Color semiBlack = Color(0x42000000);
const Color whiteAluminum = Color(0xFFB0B0B0);
const Color dullGray = Color(0xFF6D6D6D);
const Color signalBlack = Color(0xFF2A2A2A);
const Color blackBlue = Color(0xFF1B1B1D);
const Color black = Color(0xFF000000);
const Color paleMallow = Color(0xFFE6E7F8);
const Color lightMallow = Color(0xFFDBDCFC);
const Color slateBlue = Color(0xFF7678E5);
const Color cyan = Color(0xFF00FFFF);
const Color limeGreen = Color(0xFF00FF00);
const Color green = Color(0xFF4CAF50);
const Color gold = Color(0xFFFFD700);
const Color yellow = Color(0xFFFFFF00);
const Color lightPink = Color(0xFFFFB6C1);
const Color orange = Color(0xFFFFA500);
const Color redPurple = Color(0xFF68174D);
const Color red = Color(0xFFDF2E38);

const colors = [
  Color(0xFFe17076), // red
  Color(0xFFf4a261), // orange
  Color(0xFFe9c46a), // yellow
  Color(0xFF2a9d8f), // teal
  Color(0xFF4d96ff), // blue
  Color(0xFF9b5de5), // purple
  Color(0xFFf15bb5), // pink
  Color(0xFF00bcd4), // cyan
];

Color getAvatarColor(String input) {
  final hash = input.runes.fold(0, (prev, el) => prev * 31 + el);
  final index = hash.abs() % colors.length;

  final saturation = 0.35 + ((hash >> 8) % 40) / 100; // 0.35–0.75
  final lightness = 0.55 + ((hash >> 16) % 20) / 100; // 0.55–0.75

  final hsl = HSLColor.fromColor(colors[index]);
  return hsl.withSaturation(saturation).withLightness(lightness).toColor();
}
