import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/usecases/manage_favorites_usecase.dart';
import 'core_providers.dart';

class FavoritesNotifier extends StateNotifier<List<int>> {
  final ManageFavoritesUseCase _useCase;

  FavoritesNotifier(this._useCase) : super([]) {
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    final result = await _useCase.getFavoriteIds();
    result.fold(
      onFailure: (_) => state = [],
      onSuccess: (ids) => state = ids,
    );
  }

  Future<void> toggleFavorite(int pokemonId) async {
    final result = await _useCase.toggleFavorite(pokemonId);
    result.fold(
      onFailure: (_) {},
      onSuccess: (isFav) {
        if (isFav) {
          state = [...state, pokemonId];
        } else {
          state = state.where((id) => id != pokemonId).toList();
        }
      },
    );
  }

  bool isFavorite(int pokemonId) {
    return state.contains(pokemonId);
  }
}

final favoritesProvider = StateNotifierProvider<FavoritesNotifier, List<int>>((ref) {
  final useCase = ref.watch(manageFavoritesUseCaseProvider);
  return FavoritesNotifier(useCase);
});
