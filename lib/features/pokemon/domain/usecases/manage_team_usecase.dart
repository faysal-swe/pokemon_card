import '../../../../core/utils/result.dart';
import '../repositories/pokemon_repository.dart';

class ManageTeamUseCase {
  final PokemonRepository repository;

  ManageTeamUseCase(this.repository);

  Future<Result<List<int?>>> getTeamSlots() {
    return repository.getTeamPokemonIds();
  }

  Future<Result<void>> setSlot(int slotIndex, int? pokemonId) {
    return repository.setTeamSlot(slotIndex, pokemonId);
  }
}
