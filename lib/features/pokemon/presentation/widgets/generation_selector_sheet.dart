import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/pokemon_type_helper.dart';
import '../providers/pokemon_list_provider.dart';

class GenerationSelectorSheet extends ConsumerWidget {
  const GenerationSelectorSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const GenerationSelectorSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeGen = ref.watch(
      pokemonListNotifierProvider.select((s) => s.activeGenerationId),
    );

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Select Generation',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (activeGen != null)
                TextButton(
                  onPressed: () {
                    ref.read(pokemonListNotifierProvider.notifier).filterByGeneration(null);
                    Navigator.pop(context);
                  },
                  child: const Text('Clear Filter', style: TextStyle(color: AppColors.primaryRed)),
                ),
            ],
          ),
          SizedBox(height: 12.h),
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 400.h),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: PokemonTypeHelper.generations.length,
              separatorBuilder: (_, __) => SizedBox(height: 8.h),
              itemBuilder: (context, index) {
                final gen = PokemonTypeHelper.generations[index];
                final isSelected = activeGen == gen.id;

                return InkWell(
                  onTap: () {
                    ref.read(pokemonListNotifierProvider.notifier).filterByGeneration(gen.id);
                    Navigator.pop(context);
                  },
                  borderRadius: BorderRadius.circular(14.r),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primaryRed.withOpacity(0.12)
                          : Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primaryRed
                            : Colors.grey.withOpacity(0.15),
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              gen.name,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? AppColors.primaryRed : null,
                              ),
                            ),
                            Text(
                              '${gen.region} Region • ${gen.limit} Pokémon',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                              ),
                            ),
                          ],
                        ),
                        if (isSelected)
                          const Icon(
                            Icons.check_circle_rounded,
                            color: AppColors.primaryRed,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }
}
