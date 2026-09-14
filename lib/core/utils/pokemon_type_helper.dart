import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class PokemonTypeHelper {
  static const List<String> allTypes = [
    'all',
    'normal',
    'fire',
    'water',
    'electric',
    'grass',
    'ice',
    'fighting',
    'poison',
    'ground',
    'flying',
    'psychic',
    'bug',
    'rock',
    'ghost',
    'dragon',
    'dark',
    'steel',
    'fairy',
  ];

  static const List<GenerationInfo> generations = [
    GenerationInfo(id: 1, name: 'Generation I', region: 'Kanto', offset: 0, limit: 151),
    GenerationInfo(id: 2, name: 'Generation II', region: 'Johto', offset: 151, limit: 100),
    GenerationInfo(id: 3, name: 'Generation III', region: 'Hoenn', offset: 251, limit: 135),
    GenerationInfo(id: 4, name: 'Generation IV', region: 'Sinnoh', offset: 386, limit: 107),
    GenerationInfo(id: 5, name: 'Generation V', region: 'Unova', offset: 493, limit: 156),
    GenerationInfo(id: 6, name: 'Generation VI', region: 'Kalos', offset: 649, limit: 72),
    GenerationInfo(id: 7, name: 'Generation VII', region: 'Alola', offset: 721, limit: 88),
    GenerationInfo(id: 8, name: 'Generation VIII', region: 'Galar', offset: 809, limit: 96),
    GenerationInfo(id: 9, name: 'Generation IX', region: 'Paldea', offset: 905, limit: 120),
  ];

  static Color getTypeColor(String? type) {
    return AppColors.getTypeColor(type);
  }

  static IconData getTypeIcon(String? type) {
    switch (type?.toLowerCase()) {
      case 'fire':
        return Icons.local_fire_department;
      case 'water':
        return Icons.water_drop;
      case 'grass':
        return Icons.grass;
      case 'electric':
        return Icons.bolt;
      case 'ice':
        return Icons.ac_unit;
      case 'fighting':
        return Icons.sports_martial_arts;
      case 'poison':
        return Icons.science;
      case 'ground':
        return Icons.landscape;
      case 'flying':
        return Icons.air;
      case 'psychic':
        return Icons.auto_awesome;
      case 'bug':
        return Icons.bug_report;
      case 'rock':
        return Icons.terrain;
      case 'ghost':
        return Icons.bedtime;
      case 'dragon':
        return Icons.whatshot;
      case 'dark':
        return Icons.dark_mode;
      case 'steel':
        return Icons.shield;
      case 'fairy':
        return Icons.flare;
      default:
        return Icons.circle;
    }
  }
}

class GenerationInfo {
  final int id;
  final String name;
  final String region;
  final int offset;
  final int limit;

  const GenerationInfo({
    required this.id,
    required this.name,
    required this.region,
    required this.offset,
    required this.limit,
  });

  String get displayName => '$name — $region';
}
