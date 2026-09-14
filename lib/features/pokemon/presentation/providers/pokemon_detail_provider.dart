import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/evolution_chain.dart';
import '../../domain/entities/pokemon_detail.dart';
import 'core_providers.dart';

/// Family provider fetching full Pokemon detail by ID or name
final pokemonDetailFamily = FutureProvider.family<PokemonDetail, String>((ref, idOrName) async {
  final getDetailUseCase = ref.watch(getPokemonDetailUseCaseProvider);
  final result = await getDetailUseCase(idOrName);

  return result.fold(
    onFailure: (failure) => throw failure.message,
    onSuccess: (detail) => detail,
  );
});

/// Family provider fetching evolution chain by evolution chain ID
final evolutionChainFamily = FutureProvider.family<EvolutionStage, int>((ref, chainId) async {
  final getEvolutionChainUseCase = ref.watch(getEvolutionChainUseCaseProvider);
  final result = await getEvolutionChainUseCase(chainId);

  return result.fold(
    onFailure: (failure) => throw failure.message,
    onSuccess: (chain) => chain,
  );
});
