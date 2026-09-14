import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/pokemon_summary_model.dart';
import '../models/pokemon_detail_model.dart';
import '../models/pokemon_species_model.dart';
import '../models/evolution_chain_model.dart';
import '../models/type_damage_relations_model.dart';
import '../../domain/entities/evolution_chain.dart';

abstract class PokemonRemoteDataSource {
  Future<List<PokemonSummaryModel>> getPokemonList({int limit = 20, int offset = 0});
  Future<PokemonDetailModel> getPokemonDetail(String idOrName);
  Future<List<PokemonSummaryModel>> getPokemonByType(String typeName);
  Future<List<PokemonSummaryModel>> getPokemonByGeneration(int generationId);
  Future<EvolutionStage> getEvolutionChain(int chainId);
  Future<TypeDamageRelationsModel> getTypeDamageRelations(String typeName);
}

class PokemonRemoteDataSourceImpl implements PokemonRemoteDataSource {
  final ApiClient apiClient;

  // In-memory cache for fast reuse and avoiding duplicate calls
  final Map<String, PokemonDetailModel> _detailCache = {};
  final Map<String, List<String>> _typesCache = {};

  PokemonRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<PokemonSummaryModel>> getPokemonList({int limit = 20, int offset = 0}) async {
    final response = await apiClient.get(
      ApiConstants.pokemon,
      queryParameters: {'limit': limit, 'offset': offset},
    );

    final results = response['results'] as List<dynamic>;

    // Convert raw named resources
    final summaries = results.map((item) {
      return PokemonSummaryModel.fromNamedApiResource(item as Map<String, dynamic>);
    }).toList();

    // Fetch types in parallel for cards to display their type badges
    final enrichedSummaries = await Future.wait(
      summaries.map((summary) async {
        final cachedTypes = _typesCache[summary.name];
        if (cachedTypes != null) {
          return PokemonSummaryModel(
            id: summary.id,
            name: summary.name,
            imageUrl: summary.imageUrl,
            types: cachedTypes,
          );
        }

        try {
          final detailResponse = await apiClient.get('${ApiConstants.pokemon}/${summary.id}');
          final detailModel = PokemonDetailModel.fromJson(detailResponse as Map<String, dynamic>);
          _typesCache[summary.name] = detailModel.types;
          _detailCache[summary.name.toLowerCase()] = detailModel;
          _detailCache[summary.id.toString()] = detailModel;

          return PokemonSummaryModel(
            id: summary.id,
            name: summary.name,
            imageUrl: summary.imageUrl,
            types: detailModel.types,
          );
        } catch (_) {
          return summary;
        }
      }),
    );

    return enrichedSummaries;
  }

  @override
  Future<PokemonDetailModel> getPokemonDetail(String idOrName) async {
    final key = idOrName.toLowerCase().trim();
    if (_detailCache.containsKey(key)) {
      final cached = _detailCache[key]!;
      // If cached already has species info (flavorText/evolutionChainId), return directly
      if (cached.flavorText != null) {
        return cached;
      }
    }

    // 1. Fetch main pokemon data
    final pokemonJson = await apiClient.get('${ApiConstants.pokemon}/$key');
    var detail = PokemonDetailModel.fromJson(pokemonJson as Map<String, dynamic>);

    // 2. Fetch species data for flavor text, gender rate, evolution chain url
    try {
      final speciesJson = await apiClient.get('${ApiConstants.pokemonSpecies}/${detail.id}');
      final species = PokemonSpeciesModel.fromJson(speciesJson as Map<String, dynamic>);
      detail = detail.copyWithSpecies(
        flavorText: species.flavorText,
        genderRate: species.genderRate,
        evolutionChainId: species.evolutionChainId,
      );
    } catch (_) {
      // Species might fail for some alternative forms, gracefully keep base detail
    }

    // Cache by both name and ID
    _detailCache[detail.name.toLowerCase()] = detail;
    _detailCache[detail.id.toString()] = detail;
    _typesCache[detail.name.toLowerCase()] = detail.types;

    return detail;
  }

  @override
  Future<List<PokemonSummaryModel>> getPokemonByType(String typeName) async {
    final response = await apiClient.get('${ApiConstants.type}/${typeName.toLowerCase()}');
    final pokemonEntries = (response['pokemon'] as List<dynamic>?) ?? [];

    final summaries = <PokemonSummaryModel>[];
    for (final entry in pokemonEntries) {
      final p = entry['pokemon'] as Map<String, dynamic>;
      final summary = PokemonSummaryModel.fromNamedApiResource(p);
      // We already know this Pokemon has this type
      summaries.add(PokemonSummaryModel(
        id: summary.id,
        name: summary.name,
        imageUrl: summary.imageUrl,
        types: [typeName.toLowerCase()],
      ));
    }
    return summaries;
  }

  @override
  Future<List<PokemonSummaryModel>> getPokemonByGeneration(int generationId) async {
    final response = await apiClient.get('${ApiConstants.generation}/$generationId');
    final speciesList = (response['pokemon_species'] as List<dynamic>?) ?? [];

    final summaries = speciesList.map((item) {
      return PokemonSummaryModel.fromNamedApiResource(item as Map<String, dynamic>);
    }).toList();

    // Sort by ID
    summaries.sort((a, b) => a.id.compareTo(b.id));
    return summaries;
  }

  @override
  Future<EvolutionStage> getEvolutionChain(int chainId) async {
    final response = await apiClient.get('${ApiConstants.evolutionChain}/$chainId');
    return EvolutionChainModel.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<TypeDamageRelationsModel> getTypeDamageRelations(String typeName) async {
    final response = await apiClient.get('${ApiConstants.type}/${typeName.toLowerCase()}');
    return TypeDamageRelationsModel.fromJson(response as Map<String, dynamic>);
  }
}
