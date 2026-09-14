import '../../../../core/utils/result.dart';
import '../entities/pokemon_detail.dart';
import '../repositories/pokemon_repository.dart';

class SearchPokemonUseCase {
  final PokemonRepository repository;

  SearchPokemonUseCase(this.repository);

  Future<Result<PokemonDetail>> call(String query) {
    // Strip leading zeroes if it is a number (e.g., "025" -> "25")
    final trimmed = query.trim().toLowerCase();
    final number = int.tryParse(trimmed);
    final sanitized = number != null ? number.toString() : trimmed;
    return repository.searchPokemon(sanitized);
  }
}
