import 'package:flutter/material.dart';

class AppColors {
  // App General Palette
  static const Color primaryRed = Color(0xFFE3350D);
  static const Color darkRed = Color(0xFFB31818);
  static const Color backgroundLight = Color(0xFFF7F8FA);
  static const Color backgroundDark = Color(0xFF141419);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF1F2029);

  static const Color textPrimaryLight = Color(0xFF1F2029);
  static const Color textSecondaryLight = Color(0xFF7A7D85);
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFA0A3BD);

  // Pokemon Type Colors
  static const Map<String, Color> typeColors = {
    'normal': Color(0xFFA8A878),
    'fire': Color(0xFFF08030),
    'water': Color(0xFF6890F0),
    'electric': Color(0xFFF8D030),
    'grass': Color(0xFF78C850),
    'ice': Color(0xFF98D8D8),
    'fighting': Color(0xFFC03028),
    'poison': Color(0xFFA040A0),
    'ground': Color(0xFFE0C068),
    'flying': Color(0xFFA890F0),
    'psychic': Color(0xFFF85888),
    'bug': Color(0xFFA8B820),
    'rock': Color(0xFFB8A038),
    'ghost': Color(0xFF705898),
    'dragon': Color(0xFF7038F8),
    'dark': Color(0xFF705848),
    'steel': Color(0xFFB8B8D0),
    'fairy': Color(0xFFEE99AC),
  };

  // Stat Bar Colors
  static const Color statHp = Color(0xFFFF5959);
  static const Color statAttack = Color(0xFFF5AC78);
  static const Color statDefense = Color(0xFFFAE078);
  static const Color statSpAtk = Color(0xFF9DB7F5);
  static const Color statSpDef = Color(0xFFA7DB8D);
  static const Color statSpeed = Color(0xFFFA92B2);

  // Helper method for safely getting type color
  static Color getTypeColor(String? typeName) {
    if (typeName == null) return const Color(0xFF777777);
    return typeColors[typeName.toLowerCase()] ?? const Color(0xFF777777);
  }
}
