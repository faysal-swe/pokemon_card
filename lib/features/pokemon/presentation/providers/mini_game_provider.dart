import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/usecases/mini_game_usecase.dart';
import 'core_providers.dart';

class MiniGameState extends Equatable {
  final MiniGameQuestion? question;
  final bool isLoading;
  final bool hasAnswered;
  final String? selectedOption;
  final bool? isCorrect;
  final int currentStreak;
  final int bestStreak;
  final String? errorMessage;

  const MiniGameState({
    this.question,
    this.isLoading = false,
    this.hasAnswered = false,
    this.selectedOption,
    this.isCorrect,
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.errorMessage,
  });

  MiniGameState copyWith({
    MiniGameQuestion? question,
    bool? isLoading,
    bool? hasAnswered,
    String? Function()? selectedOption,
    bool? Function()? isCorrect,
    int? currentStreak,
    int? bestStreak,
    String? Function()? errorMessage,
  }) {
    return MiniGameState(
      question: question ?? this.question,
      isLoading: isLoading ?? this.isLoading,
      hasAnswered: hasAnswered ?? this.hasAnswered,
      selectedOption: selectedOption != null ? selectedOption() : this.selectedOption,
      isCorrect: isCorrect != null ? isCorrect() : this.isCorrect,
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        question,
        isLoading,
        hasAnswered,
        selectedOption,
        isCorrect,
        currentStreak,
        bestStreak,
        errorMessage,
      ];
}

class MiniGameNotifier extends StateNotifier<MiniGameState> {
  final MiniGameUseCase _useCase;

  MiniGameNotifier(this._useCase) : super(const MiniGameState()) {
    init();
  }

  Future<void> init() async {
    final best = await _useCase.getBestStreak();
    state = state.copyWith(bestStreak: best);
    await nextQuestion();
  }

  Future<void> nextQuestion() async {
    state = state.copyWith(
      isLoading: true,
      hasAnswered: false,
      selectedOption: () => null,
      isCorrect: () => null,
      errorMessage: () => null,
    );

    final result = await _useCase.generateQuestion();

    result.fold(
      onFailure: (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: () => failure.message,
        );
      },
      onSuccess: (question) {
        state = state.copyWith(
          isLoading: false,
          question: question,
        );
      },
    );
  }

  Future<void> answer(String option) async {
    if (state.hasAnswered || state.question == null) return;

    final correct = option.toLowerCase() == state.question!.correctAnswer.toLowerCase();
    final newStreak = correct ? state.currentStreak + 1 : 0;
    final newBest = newStreak > state.bestStreak ? newStreak : state.bestStreak;

    if (newBest > state.bestStreak) {
      await _useCase.saveBestStreak(newBest);
    }

    state = state.copyWith(
      hasAnswered: true,
      selectedOption: () => option,
      isCorrect: () => correct,
      currentStreak: newStreak,
      bestStreak: newBest,
    );
  }
}

final miniGameNotifierProvider = StateNotifierProvider<MiniGameNotifier, MiniGameState>((ref) {
  final useCase = ref.watch(miniGameUseCaseProvider);
  return MiniGameNotifier(useCase);
});
