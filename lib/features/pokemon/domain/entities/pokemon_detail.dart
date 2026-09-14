import 'package:equatable/equatable.dart';
import 'pokemon.dart';

/// Full Pokemon Detail domain entity
class PokemonDetail extends Pokemon {
  final String? cryUrl;
  final int height; // in decimeters
  final int weight; // in hectograms
  final int baseExperience;
  final List<PokemonAbility> abilities;
  final List<PokemonStat> stats;
  final String? flavorText;
  final int? genderRate; // -1 = genderless, 0-8 represents 1/8ths female
  final int? evolutionChainId;
  final List<PokemonMove> moves;

  const PokemonDetail({
    required super.id,
    required super.name,
    required super.imageUrl,
    this.cryUrl,
    required this.height,
    required this.weight,
    required this.baseExperience,
    required super.types,
    required this.abilities,
    required this.stats,
    this.flavorText,
    this.genderRate,
    this.evolutionChainId,
    required this.moves,
  });



  /// Dynamically calculates total base stats (sum of all 6 base stats)
  int get totalStats => stats.fold(0, (sum, stat) => sum + stat.value);

  /// Helper to get gender distribution percentage
  String get genderRatioString {
    if (genderRate == null || genderRate == -1) return 'Genderless';
    final femalePercent = (genderRate! / 8.0) * 100;
    final malePercent = 100.0 - femalePercent;
    return '♂ ${malePercent.toStringAsFixed(1)}%  ♀ ${femalePercent.toStringAsFixed(1)}%';
  }

  @override
  List<Object?> get props => [
        id,
        name,
        imageUrl,
        cryUrl,
        height,
        weight,
        baseExperience,
        types,
        abilities,
        stats,
        flavorText,
        genderRate,
        evolutionChainId,
        moves,
      ];
}

class PokemonAbility extends Equatable {
  final String name;
  final bool isHidden;

  const PokemonAbility({
    required this.name,
    required this.isHidden,
  });

  @override
  List<Object?> get props => [name, isHidden];
}

class PokemonStat extends Equatable {
  final String name;
  final int value;

  const PokemonStat({
    required this.name,
    required this.value,
  });

  @override
  List<Object?> get props => [name, value];
}

class PokemonMove extends Equatable {
  final String name;
  final String learnMethod; // 'level-up', 'machine', 'tutor', 'egg', etc.
  final int levelLearned;

  const PokemonMove({
    required this.name,
    required this.learnMethod,
    required this.levelLearned,
  });

  @override
  List<Object?> get props => [name, learnMethod, levelLearned];
}
