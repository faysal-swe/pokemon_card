import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/string_extensions.dart';
import '../../../../core/widgets/custom_loading_indicator.dart';
import '../providers/mini_game_provider.dart';
import '../widgets/pokemon_type_badge.dart';

class MiniGameScreen extends ConsumerStatefulWidget {
  const MiniGameScreen({super.key});

  @override
  ConsumerState<MiniGameScreen> createState() => _MiniGameScreenState();
}

class _MiniGameScreenState extends ConsumerState<MiniGameScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _onAnswerSelected(String option, String? cryUrl) {
    ref.read(miniGameNotifierProvider.notifier).answer(option);
    if (cryUrl != null && cryUrl.isNotEmpty) {
      _audioPlayer.play(UrlSource(cryUrl));
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(miniGameNotifierProvider);
    final notifier = ref.read(miniGameNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Who's That Pokémon?"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'New Pokémon',
            onPressed: () => notifier.nextQuestion(),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CustomLoadingIndicator(message: 'Generating next Pokémon...'))
          : state.question == null
              ? Center(
                  child: ElevatedButton(
                    onPressed: () => notifier.nextQuestion(),
                    child: const Text('Start Game'),
                  ),
                )
              : _buildGameBody(context, state, notifier),
    );
  }

  Widget _buildGameBody(
    BuildContext context,
    MiniGameState state,
    MiniGameNotifier notifier,
  ) {
    final question = state.question!;
    final pokemon = question.targetPokemon;
    final hasAnswered = state.hasAnswered;

    return SingleChildScrollView(
      padding: EdgeInsets.all(20.r),
      child: Column(
        children: [
          // Streak Counter Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildScoreBadge('🔥 Streak', state.currentStreak.toString(), Colors.orange),
              _buildScoreBadge('🏆 Best', state.bestStreak.toString(), Colors.amber),
            ],
          ),
          SizedBox(height: 24.h),

          // Silhouette / Revealed Artwork Card
          Container(
            height: 220.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: hasAnswered
                  ? AppColors.getTypeColor(pokemon.primaryType).withOpacity(0.15)
                  : Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(24.r),
              border: Border.all(
                color: hasAnswered
                    ? AppColors.getTypeColor(pokemon.primaryType).withOpacity(0.4)
                    : Colors.grey.withOpacity(0.2),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Pokeball watermark
                Opacity(
                  opacity: 0.1,
                  child: Icon(Icons.catching_pokemon, size: 200.r),
                ),

                // Artwork (Silhouette when unanswered, Full color when answered)
                ColorFiltered(
                  colorFilter: hasAnswered
                      ? const ColorFilter.mode(Colors.transparent, BlendMode.dst)
                      : const ColorFilter.mode(Colors.black, BlendMode.srcIn),
                  child: CachedNetworkImage(
                    imageUrl: pokemon.imageUrl,
                    height: 180.h,
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),

          // Answer result header
          if (hasAnswered) ...[
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: (state.isCorrect ?? false)
                    ? Colors.green.withOpacity(0.12)
                    : Colors.red.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    (state.isCorrect ?? false) ? Icons.check_circle_rounded : Icons.cancel_rounded,
                    color: (state.isCorrect ?? false) ? Colors.green : Colors.red,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    (state.isCorrect ?? false)
                        ? 'Correct! It\'s ${pokemon.name.formatName()}!'
                        : 'Wrong! It\'s ${pokemon.name.formatName()}.',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      color: (state.isCorrect ?? false) ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12.h),

            // Types badges
            Wrap(
              spacing: 6.w,
              children: pokemon.types.map((t) => PokemonTypeBadge(typeName: t)).toList(),
            ),
            SizedBox(height: 16.h),
          ],

          // 4 Multiple Choice Option Buttons
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 2.3,
            crossAxisSpacing: 10.w,
            mainAxisSpacing: 10.h,
            children: question.options.map((option) {
              final isSelected = state.selectedOption == option;
              final isCorrectOption = option.toLowerCase() == question.correctAnswer.toLowerCase();

              Color btnColor = Theme.of(context).cardColor;
              Color textColor = Theme.of(context).colorScheme.onSurface;
              BorderSide border = BorderSide(color: Colors.grey.withOpacity(0.25));

              if (hasAnswered) {
                if (isCorrectOption) {
                  btnColor = Colors.green;
                  textColor = Colors.white;
                  border = const BorderSide(color: Colors.green);
                } else if (isSelected && !isCorrectOption) {
                  btnColor = Colors.red;
                  textColor = Colors.white;
                  border = const BorderSide(color: Colors.red);
                }
              }

              return InkWell(
                onTap: hasAnswered ? null : () => _onAnswerSelected(option, pokemon.cryUrl),
                borderRadius: BorderRadius.circular(14.r),
                child: Container(
                  decoration: BoxDecoration(
                    color: btnColor,
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.fromBorderSide(border),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      option.formatName(),
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          // Next Button when answered
          if (hasAnswered) ...[
            SizedBox(height: 20.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => context.push('/pokemon/${pokemon.id}'),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                    ),
                    child: const Text('View Pokédex Entry'),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => notifier.nextQuestion(),
                    icon: const Icon(Icons.arrow_forward_rounded),
                    label: const Text('Next Pokémon'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryRed,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildScoreBadge(String label, String value, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Text(label, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold)),
          SizedBox(width: 8.w),
          Text(
            value,
            style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w900, color: color),
          ),
        ],
      ),
    );
  }
}
