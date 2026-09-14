import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/pokemon_detail.dart';
import 'core_providers.dart';

/// The active text search query
final pokemonSearchQueryProvider = StateProvider<String>((ref) => '');

/// Asynchronous search result provider based on search query
final pokemonSearchResultProvider = FutureProvider.autoDispose<PokemonDetail?>((ref) async {
  final query = ref.watch(pokemonSearchQueryProvider).trim();
  if (query.isEmpty) return null;

  final searchUseCase = ref.watch(searchPokemonUseCaseProvider);
  final result = await searchUseCase(query);

  return result.fold(
    onFailure: (failure) => throw failure.message,
    onSuccess: (detail) => detail,
  );
});
