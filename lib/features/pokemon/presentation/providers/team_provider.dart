import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/usecases/manage_team_usecase.dart';
import 'core_providers.dart';

class TeamState extends Equatable {
  final List<int?> slots; // exactly 6 slots
  final bool isLoading;

  const TeamState({
    this.slots = const [null, null, null, null, null, null],
    this.isLoading = false,
  });

  TeamState copyWith({
    List<int?>? slots,
    bool? isLoading,
  }) {
    return TeamState(
      slots: slots ?? this.slots,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [slots, isLoading];
}

class TeamNotifier extends StateNotifier<TeamState> {
  final ManageTeamUseCase _manageTeamUseCase;

  TeamNotifier(this._manageTeamUseCase) : super(const TeamState()) {
    loadTeam();
  }

  Future<void> loadTeam() async {
    state = state.copyWith(isLoading: true);
    final result = await _manageTeamUseCase.getTeamSlots();
    result.fold(
      onFailure: (_) => state = state.copyWith(isLoading: false),
      onSuccess: (slots) => state = state.copyWith(slots: slots, isLoading: false),
    );
  }

  Future<void> setSlot(int slotIndex, int? pokemonId) async {
    if (slotIndex < 0 || slotIndex >= 6) return;
    final newSlots = List<int?>.from(state.slots);
    newSlots[slotIndex] = pokemonId;
    state = state.copyWith(slots: newSlots);
    await _manageTeamUseCase.setSlot(slotIndex, pokemonId);
  }

  Future<bool> addPokemon(int pokemonId) async {
    // Check if already in team
    if (state.slots.contains(pokemonId)) return false;

    // Find first empty slot
    final emptyIndex = state.slots.indexOf(null);
    if (emptyIndex != -1) {
      await setSlot(emptyIndex, pokemonId);
      return true;
    }
    return false; // Team is full
  }

  Future<void> removeSlot(int slotIndex) async {
    await setSlot(slotIndex, null);
  }
}

final teamNotifierProvider = StateNotifierProvider<TeamNotifier, TeamState>((ref) {
  final useCase = ref.watch(manageTeamUseCaseProvider);
  return TeamNotifier(useCase);
});

/// Team Coverage Analysis Model
class TeamCoverageReport {
  final Map<String, int> weaknesses; // Type -> count of weak members
  final Map<String, int> resistances; // Type -> count of resistant members
  final Map<String, int> immunities; // Type -> count of immune members

  const TeamCoverageReport({
    required this.weaknesses,
    required this.resistances,
    required this.immunities,
  });
}

/// Computes dynamic team coverage (weaknesses and resistances) from PokeAPI damage relations
final teamCoverageProvider = FutureProvider<TeamCoverageReport>((ref) async {
  final teamState = ref.watch(teamNotifierProvider);
  final getDetailUseCase = ref.watch(getPokemonDetailUseCaseProvider);
  final getDamageRelationsUseCase = ref.watch(getTypeDamageRelationsUseCaseProvider);

  final activePokemonIds = teamState.slots.whereType<int>().toList();
  if (activePokemonIds.isEmpty) {
    return const TeamCoverageReport(weaknesses: {}, resistances: {}, immunities: {});
  }

  // Fetch details for all team members
  final teamDetails = await Future.wait(
    activePokemonIds.map((id) => getDetailUseCase(id.toString())),
  );

  final weaknesses = <String, int>{};
  final resistances = <String, int>{};
  final immunities = <String, int>{};

  for (final result in teamDetails) {
    if (result.isFailure) continue;
    final pokemon = result.dataOrNull!;

    // For each type of the Pokemon, fetch its damage relations
    final typeRelations = await Future.wait(
      pokemon.types.map((type) => getDamageRelationsUseCase(type)),
    );

    // Calculate effectiveness for each attacking type against this Pokemon
    final allAttackingTypes = <String>{};
    for (final relResult in typeRelations) {
      if (relResult.isSuccess) {
        final rel = relResult.dataOrNull!;
        allAttackingTypes.addAll(rel.doubleDamageFrom);
        allAttackingTypes.addAll(rel.halfDamageFrom);
        allAttackingTypes.addAll(rel.noDamageFrom);
      }
    }

    for (final attackingType in allAttackingTypes) {
      double multiplier = 1.0;
      for (final relResult in typeRelations) {
        if (relResult.isFailure) continue;
        final rel = relResult.dataOrNull!;
        if (rel.noDamageFrom.contains(attackingType)) {
          multiplier *= 0.0;
        } else if (rel.doubleDamageFrom.contains(attackingType)) {
          multiplier *= 2.0;
        } else if (rel.halfDamageFrom.contains(attackingType)) {
          multiplier *= 0.5;
        }
      }

      if (multiplier == 0.0) {
        immunities[attackingType] = (immunities[attackingType] ?? 0) + 1;
      } else if (multiplier > 1.0) {
        weaknesses[attackingType] = (weaknesses[attackingType] ?? 0) + 1;
      } else if (multiplier < 1.0) {
        resistances[attackingType] = (resistances[attackingType] ?? 0) + 1;
      }
    }
  }

  return TeamCoverageReport(
    weaknesses: weaknesses,
    resistances: resistances,
    immunities: immunities,
  );
});
