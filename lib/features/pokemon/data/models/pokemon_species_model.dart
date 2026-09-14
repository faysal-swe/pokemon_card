class PokemonSpeciesModel {
  final String? flavorText;
  final int? genderRate;
  final int? evolutionChainId;

  const PokemonSpeciesModel({
    this.flavorText,
    this.genderRate,
    this.evolutionChainId,
  });

  factory PokemonSpeciesModel.fromJson(Map<String, dynamic> json) {
    // Extract flavor text (English)
    String? flavorText;
    final flavorEntries = json['flavor_text_entries'] as List<dynamic>?;
    if (flavorEntries != null) {
      for (final entry in flavorEntries) {
        if (entry['language']?['name'] == 'en') {
          flavorText = (entry['flavor_text'] as String?)
              ?.replaceAll('\n', ' ')
              .replaceAll('\f', ' ')
              .replaceAll(RegExp(r'\s+'), ' ')
              .trim();
          break;
        }
      }
    }

    // Gender rate
    final genderRate = json['gender_rate'] as int?;

    // Evolution chain ID
    int? evolutionChainId;
    final chainUrl = json['evolution_chain']?['url'] as String?;
    if (chainUrl != null) {
      final cleanUrl = chainUrl.endsWith('/') ? chainUrl.substring(0, chainUrl.length - 1) : chainUrl;
      evolutionChainId = int.tryParse(cleanUrl.split('/').last);
    }

    return PokemonSpeciesModel(
      flavorText: flavorText,
      genderRate: genderRate,
      evolutionChainId: evolutionChainId,
    );
  }
}
