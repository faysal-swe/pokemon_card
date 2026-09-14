import '../../../../core/utils/result.dart';
import '../entities/pokemon_detail.dart';
import '../repositories/pokemon_repository.dart';

class GetPokemonDetailUseCase {
  final PokemonRepository repository;

  GetPokemonDetailUseCase(this.repository);

  Future<Result<PokemonDetail>> call(String idOrName) {
    return repository.getPokemonDetail(idOrName);
  }
}
