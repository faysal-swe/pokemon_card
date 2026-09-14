import '../../domain/entities/pokemon_detail.dart';
import '../../../../core/constants/api_constants.dart';

class PokemonDetailModel extends PokemonDetail {
  const PokemonDetailModel({
    required super.id,
    required super.name,
    required super.imageUrl,
    super.cryUrl,
    required super.height,
    required super.weight,
    required super.baseExperience,
    required super.types,
    required super.abilities,
    required super.stats,
    super.flavorText,
    super.genderRate,
    super.evolutionChainId,
    required super.moves,
  });

  factory PokemonDetailModel.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as int;
    final name = json['name'] as String;
    final height = json['height'] as int? ?? 0;
    final weight = json['weight'] as int? ?? 0;
    final baseExperience = json['base_experience'] as int? ?? 0;

    // Artwork
    String? imageUrl;
    try {
      imageUrl = json['sprites']?['other']?['official-artwork']?['front_default'] as String?;
    } catch (_) {}
    imageUrl ??= ApiConstants.getOfficialArtworkUrl(id);

    // Audio cry
    String? cryUrl;
    try {
      cryUrl = json['cries']?['latest'] as String?;
    } catch (_) {}
    cryUrl ??= ApiConstants.getPokemonCryUrl(id);

    // Types
    final typesList = (json['types'] as List<dynamic>?)
            ?.map((t) => t['type']['name'] as String)
            .toList() ??
        [];

    // Abilities
    final abilitiesList = (json['abilities'] as List<dynamic>?)?.map((a) {
          final abilityName = a['ability']['name'] as String;
          final isHidden = a['is_hidden'] as bool? ?? false;
          return PokemonAbility(name: abilityName, isHidden: isHidden);
        }).toList() ??
        [];

    // Stats
    final statsList = (json['stats'] as List<dynamic>?)?.map((s) {
          final statName = s['stat']['name'] as String;
          final baseStat = s['base_stat'] as int? ?? 0;
          return PokemonStat(name: statName, value: baseStat);
        }).toList() ??
        [];

    // Moves
    final movesList = (json['moves'] as List<dynamic>?)?.map((m) {
          final moveName = m['move']['name'] as String;
          final details = (m['version_group_details'] as List<dynamic>?)?.lastOrNull;
          final method = details?['move_learn_method']?['name'] as String? ?? 'other';
          final level = details?['level_learned_at'] as int? ?? 0;
          return PokemonMove(name: moveName, learnMethod: method, levelLearned: level);
        }).toList() ??
        [];

    return PokemonDetailModel(
      id: id,
      name: name,
      imageUrl: imageUrl,
      cryUrl: cryUrl,
      height: height,
      weight: weight,
      baseExperience: baseExperience,
      types: typesList,
      abilities: abilitiesList,
      stats: statsList,
      moves: movesList,
    );
  }

  PokemonDetailModel copyWithSpecies({
    String? flavorText,
    int? genderRate,
    int? evolutionChainId,
  }) {
    return PokemonDetailModel(
      id: id,
      name: name,
      imageUrl: imageUrl,
      cryUrl: cryUrl,
      height: height,
      weight: weight,
      baseExperience: baseExperience,
      types: types,
      abilities: abilities,
      stats: stats,
      flavorText: flavorText ?? this.flavorText,
      genderRate: genderRate ?? this.genderRate,
      evolutionChainId: evolutionChainId ?? this.evolutionChainId,
      moves: moves,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'cryUrl': cryUrl,
      'height': height,
      'weight': weight,
      'baseExperience': baseExperience,
      'types': types,
      'abilities': abilities.map((a) => {'name': a.name, 'isHidden': a.isHidden}).toList(),
      'stats': stats.map((s) => {'name': s.name, 'value': s.value}).toList(),
      'flavorText': flavorText,
      'genderRate': genderRate,
      'evolutionChainId': evolutionChainId,
      'moves': moves.map((m) => {
            'name': m.name,
            'learnMethod': m.learnMethod,
            'levelLearned': m.levelLearned,
          }).toList(),
    };
  }

  PokemonDetail toEntity() => this;
}
