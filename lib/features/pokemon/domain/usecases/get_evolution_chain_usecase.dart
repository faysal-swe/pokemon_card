import '../../../../core/utils/result.dart';
import '../entities/evolution_chain.dart';
import '../repositories/pokemon_repository.dart';

class GetEvolutionChainUseCase {
  final PokemonRepository repository;

  GetEvolutionChainUseCase(this.repository);

  Future<Result<EvolutionStage>> call(int chainId) {
    return repository.getEvolutionChain(chainId);
  }
}
