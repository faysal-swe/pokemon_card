import '../../domain/entities/evolution_chain.dart';
import '../../../../core/constants/api_constants.dart';

class EvolutionChainModel {
  static EvolutionStage fromJson(Map<String, dynamic> json) {
    final chain = json['chain'] as Map<String, dynamic>;
    return _parseStage(chain);
  }

  static EvolutionStage _parseStage(Map<String, dynamic> stageJson) {
    final species = stageJson['species'] as Map<String, dynamic>;
    final name = species['name'] as String;
    final url = species['url'] as String;

    // Extract ID
    final cleanUrl = url.endsWith('/') ? url.substring(0, url.length - 1) : url;
    final id = int.tryParse(cleanUrl.split('/').last) ?? 1;

    // Evolution details
    final detailsList = stageJson['evolution_details'] as List<dynamic>?;
    final detail = detailsList?.firstOrNull;

    int? minLevel;
    String? item;
    String? trigger;

    if (detail != null) {
      minLevel = detail['min_level'] as int?;
      item = detail['item']?['name'] as String?;
      trigger = detail['trigger']?['name'] as String?;
    }

    // Children (evolves_to) - can be multiple for branching evolutions!
    final evolvesToList = stageJson['evolves_to'] as List<dynamic>? ?? [];
    final children = evolvesToList.map((c) => _parseStage(c as Map<String, dynamic>)).toList();

    return EvolutionStage(
      pokemonId: id,
      pokemonName: name,
      imageUrl: ApiConstants.getOfficialArtworkUrl(id),
      minLevel: minLevel,
      item: item,
      trigger: trigger,
      evolvesTo: children,
    );
  }
}
