import '../../../../core/utils/result.dart';
import '../entities/pokemon.dart';
import '../repositories/pokemon_repository.dart';

class GetPokemonListUseCase {
  final PokemonRepository repository;

  GetPokemonListUseCase(this.repository);

  Future<Result<List<Pokemon>>> call({int limit = 20, int offset = 0}) {
    return repository.getPokemonList(limit: limit, offset: offset);
  }
}
