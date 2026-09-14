import 'dart:math';
import '../../../../core/utils/result.dart';
import '../entities/pokemon_detail.dart';
import '../repositories/pokemon_repository.dart';

class MiniGameQuestion {
  final PokemonDetail targetPokemon;
  final List<String> options; // 4 options, 1 correct
  final String correctAnswer;

  const MiniGameQuestion({
    required this.targetPokemon,
    required this.options,
    required this.correctAnswer,
  });
}

class MiniGameUseCase {
  final PokemonRepository repository;
  final Random _random = Random();

  // Common Pokemon names for decoy options
  static const List<String> _decoyPool = [
    'Pikachu', 'Charizard', 'Bulbasaur', 'Squirtle', 'Eevee', 'Mewtwo', 'Lucario',
    'Gengar', 'Snorlax', 'Dragonite', 'Gardevoir', 'Blaziken', 'Rayquaza', 'Greninja',
    'Garchomp', 'Tyranitar', 'Lapras', 'Arcanine', 'Alakazam', 'Machamp', 'Gyarados',
    'Vaporeon', 'Jolteon', 'Flareon', 'Espeon', 'Umbreon', 'Scizor', 'Heracross',
    'Salamence', 'Metagross', 'Infernape', 'Togekiss', 'Sylveon', 'Decidueye', 'Cinderace'
  ];

  MiniGameUseCase(this.repository);

  Future<Result<MiniGameQuestion>> generateQuestion() async {
    // Random ID between 1 and 1025 (Gen 1-9)
    final randomId = _random.nextInt(1025) + 1;
    final result = await repository.getPokemonDetail(randomId.toString());

    return result.fold(
      onFailure: (failure) => Error(failure),
      onSuccess: (pokemon) {
        final correct = pokemon.name;
        final decoys = <String>{};

        while (decoys.length < 3) {
          final candidate = _decoyPool[_random.nextInt(_decoyPool.length)].toLowerCase();
          if (candidate != correct.toLowerCase()) {
            decoys.add(candidate);
          }
        }

        final options = [correct, ...decoys]..shuffle();

        return Success(
          MiniGameQuestion(
            targetPokemon: pokemon,
            options: options,
            correctAnswer: correct,
          ),
        );
      },
    );
  }

  Future<int> getBestStreak() => repository.getBestStreak();
  Future<void> saveBestStreak(int streak) => repository.saveBestStreak(streak);
}
