import '../../../../core/utils/result.dart';
import '../entities/pokemon.dart';
import '../entities/pokemon_detail.dart';
import '../entities/evolution_chain.dart';
import '../entities/type_damage_relations.dart';

abstract class PokemonRepository {
  /// Fetches paginated list of Pokemon
  Future<Result<List<Pokemon>>> getPokemonList({int limit = 20, int offset = 0});

  /// Fetches a single Pokemon by ID or name
  Future<Result<PokemonDetail>> getPokemonDetail(String idOrName);

  /// Searches for a Pokemon by name or exact ID
  Future<Result<PokemonDetail>> searchPokemon(String query);

  /// Fetches Pokemon filtered by type
  Future<Result<List<Pokemon>>> getPokemonByType(String typeName);

  /// Fetches Pokemon filtered by generation
  Future<Result<List<Pokemon>>> getPokemonByGeneration(int generationId);

  /// Fetches the evolution chain for a given evolution chain ID
  Future<Result<EvolutionStage>> getEvolutionChain(int chainId);

  /// Fetches damage relations for a given type name
  Future<Result<TypeDamageRelations>> getTypeDamageRelations(String typeName);

  /// Local Storage: Favorites
  Future<Result<List<int>>> getFavoritePokemonIds();
  Future<Result<bool>> toggleFavorite(int pokemonId);
  Future<bool> isFavorite(int pokemonId);

  /// Local Storage: Team Builder (6 slots)
  Future<Result<List<int?>>> getTeamPokemonIds();
  Future<Result<void>> setTeamSlot(int slotIndex, int? pokemonId);

  /// Local Storage: Mini-game streak
  Future<int> getBestStreak();
  Future<void> saveBestStreak(int streak);
}
