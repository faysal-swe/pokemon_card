import '../../domain/entities/pokemon.dart';
import '../../../../core/constants/api_constants.dart';

class PokemonSummaryModel extends Pokemon {
  const PokemonSummaryModel({
    required super.id,
    required super.name,
    required super.imageUrl,
    required super.types,
  });

  /// Factory to parse standard PokeAPI `/pokemon?limit=20` item
  /// which returns `{ "name": "bulbasaur", "url": "https://pokeapi.co/api/v2/pokemon/1/" }`
  factory PokemonSummaryModel.fromNamedApiResource(Map<String, dynamic> json) {
    final name = json['name'] as String;
    final url = json['url'] as String;

    // Extract ID from URL (e.g., ".../pokemon/25/")
    final id = _extractIdFromUrl(url);
    final imageUrl = ApiConstants.getOfficialArtworkUrl(id);

    return PokemonSummaryModel(
      id: id,
      name: name,
      imageUrl: imageUrl,
      types: const [], // Types will be loaded or populated when detail is retrieved or cached
    );
  }

  /// Factory to parse when full detail JSON is available
  factory PokemonSummaryModel.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as int;
    final name = json['name'] as String;

    // Types
    final typesList = (json['types'] as List<dynamic>?)
            ?.map((t) => t['type']['name'] as String)
            .toList() ??
        [];

    // High-res official artwork
    String? imageUrl;
    try {
      imageUrl = json['sprites']?['other']?['official-artwork']?['front_default'] as String?;
    } catch (_) {}
    imageUrl ??= ApiConstants.getOfficialArtworkUrl(id);

    return PokemonSummaryModel(
      id: id,
      name: name,
      imageUrl: imageUrl,
      types: typesList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'types': types,
    };
  }

  Pokemon toEntity() => this;

  static int _extractIdFromUrl(String url) {
    final cleanUrl = url.endsWith('/') ? url.substring(0, url.length - 1) : url;
    final parts = cleanUrl.split('/');
    return int.tryParse(parts.last) ?? 0;
  }
}
