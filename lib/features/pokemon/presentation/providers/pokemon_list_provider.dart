import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/pokemon.dart';
import '../../domain/usecases/filter_pokemon_usecase.dart';
import '../../domain/usecases/get_pokemon_list_usecase.dart';
import 'core_providers.dart';

class PokemonListState extends Equatable {
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasReachedMax;
  final List<Pokemon> pokemonList;
  final int currentOffset;
  final String activeTypeFilter;
  final int? activeGenerationId;
  final String? errorMessage;

  const PokemonListState({
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasReachedMax = false,
    this.pokemonList = const [],
    this.currentOffset = 0,
    this.activeTypeFilter = 'all',
    this.activeGenerationId,
    this.errorMessage,
  });

  PokemonListState copyWith({
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasReachedMax,
    List<Pokemon>? pokemonList,
    int? currentOffset,
    String? activeTypeFilter,
    int? Function()? activeGenerationId,
    String? Function()? errorMessage,
  }) {
    return PokemonListState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      pokemonList: pokemonList ?? this.pokemonList,
      currentOffset: currentOffset ?? this.currentOffset,
      activeTypeFilter: activeTypeFilter ?? this.activeTypeFilter,
      activeGenerationId: activeGenerationId != null ? activeGenerationId() : this.activeGenerationId,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        isLoadingMore,
        hasReachedMax,
        pokemonList,
        currentOffset,
        activeTypeFilter,
        activeGenerationId,
        errorMessage,
      ];
}

class PokemonListNotifier extends StateNotifier<PokemonListState> {
  final GetPokemonListUseCase getListUseCase;
  final FilterPokemonUseCase filterUseCase;

  static const int _pageSize = 20;

  PokemonListNotifier({
    required this.getListUseCase,
    required this.filterUseCase,
  }) : super(const PokemonListState()) {
    loadInitial();
  }

  /// Initial fetch of Pokémon
  Future<void> loadInitial() async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: () => null,
      currentOffset: 0,
      hasReachedMax: false,
    );

    final result = await getListUseCase(limit: _pageSize, offset: 0);

    result.fold(
      onFailure: (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: () => failure.message,
        );
      },
      onSuccess: (data) {
        state = state.copyWith(
          isLoading: false,
          pokemonList: data,
          currentOffset: _pageSize,
          hasReachedMax: data.length < _pageSize,
        );
      },
    );
  }

  /// Paginated infinite scroll: loads next page without clearing existing list
  Future<void> loadMore() async {
    if (state.isLoading || state.isLoadingMore || state.hasReachedMax) return;
    // Don't paginate if a specific type or generation filter is active
    if (state.activeTypeFilter != 'all' || state.activeGenerationId != null) return;

    state = state.copyWith(isLoadingMore: true);

    final result = await getListUseCase(
      limit: _pageSize,
      offset: state.currentOffset,
    );

    result.fold(
      onFailure: (failure) {
        state = state.copyWith(
          isLoadingMore: false,
          errorMessage: () => failure.message,
        );
      },
      onSuccess: (newPokemon) {
        if (newPokemon.isEmpty) {
          state = state.copyWith(
            isLoadingMore: false,
            hasReachedMax: true,
          );
        } else {
          state = state.copyWith(
            isLoadingMore: false,
            pokemonList: [...state.pokemonList, ...newPokemon],
            currentOffset: state.currentOffset + _pageSize,
            hasReachedMax: newPokemon.length < _pageSize,
          );
        }
      },
    );
  }

  /// Filters list by Pokémon type
  Future<void> filterByType(String type) async {
    if (state.activeTypeFilter.toLowerCase() == type.toLowerCase() && state.activeGenerationId == null) {
      return;
    }

    if (type.toLowerCase() == 'all') {
      state = state.copyWith(
        activeTypeFilter: 'all',
        activeGenerationId: () => null,
      );
      await loadInitial();
      return;
    }

    state = state.copyWith(
      isLoading: true,
      activeTypeFilter: type,
      activeGenerationId: () => null,
      errorMessage: () => null,
    );

    final result = await filterUseCase.byType(type);

    result.fold(
      onFailure: (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: () => failure.message,
        );
      },
      onSuccess: (data) {
        state = state.copyWith(
          isLoading: false,
          pokemonList: data,
          hasReachedMax: true, // Type endpoints return the full list for that type
        );
      },
    );
  }

  /// Filters list by Pokémon Generation (1-9)
  Future<void> filterByGeneration(int? generationId) async {
    if (state.activeGenerationId == generationId && state.activeTypeFilter == 'all') {
      return;
    }

    if (generationId == null) {
      state = state.copyWith(
        activeGenerationId: () => null,
        activeTypeFilter: 'all',
      );
      await loadInitial();
      return;
    }

    state = state.copyWith(
      isLoading: true,
      activeGenerationId: () => generationId,
      activeTypeFilter: 'all',
      errorMessage: () => null,
    );

    final result = await filterUseCase.byGeneration(generationId);

    result.fold(
      onFailure: (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: () => failure.message,
        );
      },
      onSuccess: (data) {
        state = state.copyWith(
          isLoading: false,
          pokemonList: data,
          hasReachedMax: true,
        );
      },
    );
  }

  /// Pull-to-refresh
  Future<void> refresh() async {
    if (state.activeGenerationId != null) {
      await filterByGeneration(state.activeGenerationId);
    } else if (state.activeTypeFilter != 'all') {
      await filterByType(state.activeTypeFilter);
    } else {
      await loadInitial();
    }
  }
}

final pokemonListNotifierProvider = StateNotifierProvider<PokemonListNotifier, PokemonListState>((ref) {
  final getListUseCase = ref.watch(getPokemonListUseCaseProvider);
  final filterUseCase = ref.watch(filterPokemonUseCaseProvider);
  return PokemonListNotifier(
    getListUseCase: getListUseCase,
    filterUseCase: filterUseCase,
  );
});
