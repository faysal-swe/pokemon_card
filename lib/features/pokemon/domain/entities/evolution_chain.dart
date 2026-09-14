import 'package:equatable/equatable.dart';

class EvolutionStage extends Equatable {
  final int pokemonId;
  final String pokemonName;
  final String imageUrl;
  final int? minLevel;
  final String? item;
  final String? trigger;
  final List<EvolutionStage> evolvesTo;

  const EvolutionStage({
    required this.pokemonId,
    required this.pokemonName,
    required this.imageUrl,
    this.minLevel,
    this.item,
    this.trigger,
    this.evolvesTo = const [],
  });

  @override
  List<Object?> get props => [
        pokemonId,
        pokemonName,
        imageUrl,
        minLevel,
        item,
        trigger,
        evolvesTo,
      ];
}
