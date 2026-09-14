import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/pokemon_type_helper.dart';
import '../../../../core/utils/string_extensions.dart';
import '../providers/pokemon_list_provider.dart';

class TypeFilterBar extends ConsumerWidget {
  const TypeFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeType = ref.watch(
      pokemonListNotifierProvider.select((s) => s.activeTypeFilter),
    );

    return SizedBox(
      height: 38.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: PokemonTypeHelper.allTypes.length,
        separatorBuilder: (_, __) => SizedBox(width: 8.w),
        itemBuilder: (context, index) {
          final type = PokemonTypeHelper.allTypes[index];
          final isSelected = activeType.toLowerCase() == type.toLowerCase();
          final typeColor = type == 'all'
              ? AppColors.primaryRed
              : AppColors.getTypeColor(type);

          return GestureDetector(
            onTap: () {
              ref.read(pokemonListNotifierProvider.notifier).filterByType(type);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: isSelected ? typeColor : Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: isSelected ? typeColor : Colors.grey.withOpacity(0.2),
                  width: 1.2,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: typeColor.withOpacity(0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (type != 'all') ...[
                    Icon(
                      PokemonTypeHelper.getTypeIcon(type),
                      size: 14.sp,
                      color: isSelected ? Colors.white : typeColor,
                    ),
                    SizedBox(width: 5.w),
                  ],
                  Text(
                    type.capitalize(),
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? Colors.white
                          : Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
