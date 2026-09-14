import '../../../../core/utils/result.dart';
import '../repositories/pokemon_repository.dart';

class ManageFavoritesUseCase {
  final PokemonRepository repository;

  ManageFavoritesUseCase(this.repository);

  Future<Result<List<int>>> getFavoriteIds() {
    return repository.getFavoritePokemonIds();
  }

  Future<Result<bool>> toggleFavorite(int pokemonId) {
    return repository.toggleFavorite(pokemonId);
  }

  Future<bool> isFavorite(int pokemonId) {
    return repository.isFavorite(pokemonId);
  }
}
