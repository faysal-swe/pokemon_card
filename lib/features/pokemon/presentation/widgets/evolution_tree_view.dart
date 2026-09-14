import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/string_extensions.dart';
import '../../domain/entities/evolution_chain.dart';

class EvolutionTreeView extends StatelessWidget {
  final EvolutionStage chain;

  const EvolutionTreeView({super.key, required this.chain});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: _buildStageNode(context, chain),
      ),
    );
  }

  Widget _buildStageNode(BuildContext context, EvolutionStage stage) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Current stage card
        _buildPokemonCard(context, stage),

        if (stage.evolvesTo.isNotEmpty) ...[
          // Evolution arrow / trigger column
          Column(
            mainAxisSize: MainAxisSize.min,
            children: stage.evolvesTo.map((child) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                child: Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 20.sp,
                            color: AppColors.primaryRed,
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            child.minLevel != null
                                ? 'Lv. ${child.minLevel}'
                                : child.item != null
                                    ? child.item!.formatName()
                                    : child.trigger != null
                                        ? child.trigger!.formatName()
                                        : 'Evolves',
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryRed,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildStageNode(context, child),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildPokemonCard(BuildContext context, EvolutionStage stage) {
    return InkWell(
      onTap: () => context.push('/pokemon/${stage.pokemonId}'),
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.all(10.r),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: Colors.grey.withOpacity(0.15),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CachedNetworkImage(
              imageUrl: stage.imageUrl,
              width: 70.r,
              height: 70.r,
              fit: BoxFit.contain,
              placeholder: (_, __) => SizedBox(
                width: 70.r,
                height: 70.r,
                child: const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              errorWidget: (_, __, ___) => Icon(Icons.catching_pokemon, size: 40.r),
            ),
            SizedBox(height: 4.h),
            Text(
              stage.pokemonName.formatName(),
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              stage.pokemonId.toPokedexId(),
              style: TextStyle(
                fontSize: 10.sp,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
