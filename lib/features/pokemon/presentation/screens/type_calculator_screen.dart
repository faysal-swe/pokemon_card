import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/pokemon_type_helper.dart';
import '../../../../core/utils/string_extensions.dart';
import '../../../../core/widgets/custom_loading_indicator.dart';
import '../providers/type_calculator_provider.dart';
import '../widgets/pokemon_type_badge.dart';

class TypeCalculatorScreen extends ConsumerWidget {
  const TypeCalculatorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(typeCalculatorNotifierProvider);
    final notifier = ref.read(typeCalculatorNotifierProvider.notifier);

    final availableTypes = PokemonTypeHelper.allTypes.where((t) => t != 'all').toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Type Matchup Calculator'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.r),
        children: [
          Text(
            'Select Dual Typing',
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 6.h),
          Text(
            'Pick primary and optional secondary type to calculate battle weaknesses and resistances dynamically from PokeAPI.',
            style: TextStyle(fontSize: 12.5.sp, color: Colors.grey),
          ),
          SizedBox(height: 16.h),

          // Type Pickers Row
          Row(
            children: [
              // Type 1 Selector
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Primary Type', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold)),
                    SizedBox(height: 6.h),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: AppColors.getTypeColor(state.type1)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: state.type1,
                          isExpanded: true,
                          items: availableTypes.map((t) {
                            return DropdownMenuItem(
                              value: t,
                              child: Row(
                                children: [
                                  Icon(PokemonTypeHelper.getTypeIcon(t), size: 16.sp, color: AppColors.getTypeColor(t)),
                                  SizedBox(width: 8.w),
                                  Text(t.capitalize(), style: const TextStyle(fontWeight: FontWeight.bold)),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) notifier.setType1(val);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12.w),

              // Type 2 Selector (Can be None)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Secondary Type', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold)),
                    SizedBox(height: 6.h),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: state.type2 != null
                              ? AppColors.getTypeColor(state.type2)
                              : Colors.grey.withOpacity(0.3),
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: state.type2 ?? 'none',
                          isExpanded: true,
                          items: [
                            const DropdownMenuItem(
                              value: 'none',
                              child: Text('None (Single Type)', style: TextStyle(color: Colors.grey)),
                            ),
                            ...availableTypes
                                .where((t) => t != state.type1)
                                .map((t) {
                              return DropdownMenuItem(
                                value: t,
                                child: Row(
                                  children: [
                                    Icon(PokemonTypeHelper.getTypeIcon(t), size: 16.sp, color: AppColors.getTypeColor(t)),
                                    SizedBox(width: 8.w),
                                    Text(t.capitalize(), style: const TextStyle(fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              );
                            }),
                          ],
                          onChanged: (val) => notifier.setType2(val),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 24.h),

          // Loading or Results
          if (state.isLoading)
            const Padding(
              padding: EdgeInsets.all(40),
              child: CustomLoadingIndicator(message: 'Calculating battle effectiveness...'),
            )
          else if (state.error != null)
            Center(child: Text('Error: ${state.error}'))
          else ...[
            _buildMultiplierSection(context, '4× Damage (Extreme Weakness)', 4.0, Colors.red, state.effectiveness[4.0] ?? []),
            _buildMultiplierSection(context, '2× Damage (Weakness)', 2.0, Colors.orange, state.effectiveness[2.0] ?? []),
            _buildMultiplierSection(context, '0.5× Damage (Resistant)', 0.5, Colors.green, state.effectiveness[0.5] ?? []),
            _buildMultiplierSection(context, '0.25× Damage (Double Resistant)', 0.25, Colors.teal, state.effectiveness[0.25] ?? []),
            _buildMultiplierSection(context, '0× Damage (Immune)', 0.0, Colors.blueGrey, state.effectiveness[0.0] ?? []),
          ],
        ],
      ),
    );
  }

  Widget _buildMultiplierSection(
    BuildContext context,
    String title,
    double mult,
    Color color,
    List<String> types,
  ) {
    if (types.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  '$mult×',
                  style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: color),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: types
                .map((t) => PokemonTypeBadge(
                      typeName: t,
                      fontSize: 11,
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}
