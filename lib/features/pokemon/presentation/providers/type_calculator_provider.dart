import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/pokemon_type_helper.dart';
import 'core_providers.dart';

class TypeCalculatorState extends Equatable {
  final String type1;
  final String? type2;
  final bool isLoading;
  final Map<double, List<String>> effectiveness; // e.g. 4.0 -> ['electric'], 2.0 -> ['rock']
  final String? error;

  const TypeCalculatorState({
    this.type1 = 'water',
    this.type2 = 'flying',
    this.isLoading = false,
    this.effectiveness = const {},
    this.error,
  });

  TypeCalculatorState copyWith({
    String? type1,
    String? Function()? type2,
    bool? isLoading,
    Map<double, List<String>>? effectiveness,
    String? Function()? error,
  }) {
    return TypeCalculatorState(
      type1: type1 ?? this.type1,
      type2: type2 != null ? type2() : this.type2,
      isLoading: isLoading ?? this.isLoading,
      effectiveness: effectiveness ?? this.effectiveness,
      error: error != null ? error() : this.error,
    );
  }

  @override
  List<Object?> get props => [type1, type2, isLoading, effectiveness, error];
}

class TypeCalculatorNotifier extends StateNotifier<TypeCalculatorState> {
  final Ref _ref;

  TypeCalculatorNotifier(this._ref) : super(const TypeCalculatorState()) {
    calculateMatchup();
  }

  void setType1(String type) {
    if (state.type1.toLowerCase() == type.toLowerCase()) return;
    state = state.copyWith(type1: type.toLowerCase());
    calculateMatchup();
  }

  void setType2(String? type) {
    final cleanType = type == 'none' || type == null || type.isEmpty ? null : type.toLowerCase();
    if (state.type2 == cleanType) return;
    state = state.copyWith(type2: () => cleanType);
    calculateMatchup();
  }

  Future<void> calculateMatchup() async {
    state = state.copyWith(isLoading: true, error: () => null);

    final getDamageRelations = _ref.read(getTypeDamageRelationsUseCaseProvider);

    try {
      final t1Result = await getDamageRelations(state.type1);
      if (t1Result.isFailure) {
        state = state.copyWith(isLoading: false, error: () => t1Result.failureOrNull?.message);
        return;
      }

      final rel1 = t1Result.dataOrNull!;
      final rel2 = (state.type2 != null && state.type2 != state.type1)
          ? (await getDamageRelations(state.type2!)).dataOrNull
          : null;

      final allAttackTypes = PokemonTypeHelper.allTypes.where((t) => t != 'all').toList();
      final Map<double, List<String>> grouped = {
        4.0: [],
        2.0: [],
        1.0: [],
        0.5: [],
        0.25: [],
        0.0: [],
      };

      for (final atkType in allAttackTypes) {
        double mult = 1.0;

        // Relation for type 1
        if (rel1.noDamageFrom.contains(atkType)) {
          mult *= 0.0;
        } else if (rel1.doubleDamageFrom.contains(atkType)) {
          mult *= 2.0;
        } else if (rel1.halfDamageFrom.contains(atkType)) {
          mult *= 0.5;
        }

        // Relation for type 2 (if present)
        if (rel2 != null && mult != 0.0) {
          if (rel2.noDamageFrom.contains(atkType)) {
            mult *= 0.0;
          } else if (rel2.doubleDamageFrom.contains(atkType)) {
            mult *= 2.0;
          } else if (rel2.halfDamageFrom.contains(atkType)) {
            mult *= 0.5;
          }
        }

        if (grouped.containsKey(mult)) {
          grouped[mult]!.add(atkType);
        } else {
          grouped[1.0]!.add(atkType);
        }
      }

      state = state.copyWith(
        isLoading: false,
        effectiveness: grouped,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: () => e.toString());
    }
  }
}

final typeCalculatorNotifierProvider =
    StateNotifierProvider<TypeCalculatorNotifier, TypeCalculatorState>((ref) {
  return TypeCalculatorNotifier(ref);
});
