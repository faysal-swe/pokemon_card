import '../../../../core/utils/result.dart';
import '../entities/pokemon.dart';
import '../repositories/pokemon_repository.dart';

class FilterPokemonUseCase {
  final PokemonRepository repository;

  FilterPokemonUseCase(this.repository);

  Future<Result<List<Pokemon>>> byType(String typeName) {
    if (typeName.toLowerCase() == 'all') {
      return repository.getPokemonList(limit: 20, offset: 0);
    }
    return repository.getPokemonByType(typeName);
  }

  Future<Result<List<Pokemon>>> byGeneration(int generationId) {
    return repository.getPokemonByGeneration(generationId);
  }
}
