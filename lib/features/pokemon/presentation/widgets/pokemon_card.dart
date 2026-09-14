import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/string_extensions.dart';
import '../../domain/entities/pokemon.dart';
import '../providers/favorites_provider.dart';
import 'pokemon_type_badge.dart';

class PokemonCard extends ConsumerWidget {
  final Pokemon pokemon;

  const PokemonCard({
    super.key,
    required this.pokemon,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typeColor = AppColors.getTypeColor(pokemon.primaryType);
    final isFavorite = ref.watch(
      favoritesProvider.select((favs) => favs.contains(pokemon.id)),
    );

    return InkWell(
      onTap: () => context.push('/pokemon/${pokemon.id}'),
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          gradient: LinearGradient(
            colors: [
              typeColor.withOpacity(0.18),
              Theme.of(context).cardTheme.color ?? Colors.white,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: typeColor.withOpacity(0.3),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: typeColor.withOpacity(0.12),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Pokeball background watermark
            Positioned(
              right: -15.w,
              bottom: -15.h,
              child: Opacity(
                opacity: 0.08,
                child: Icon(
                  Icons.catching_pokemon,
                  size: 110.r,
                  color: typeColor,
                ),
              ),
            ),

            // Card Content
            Padding(
              padding: EdgeInsets.all(12.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ID and Favorite Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        pokemon.id.toPokedexId(),
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w800,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          ref.read(favoritesProvider.notifier).toggleFavorite(pokemon.id);
                        },
                        child: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          size: 18.sp,
                          color: isFavorite ? AppColors.primaryRed : Colors.grey,
                        ),
                      ),
                    ],
                  ),

                  // Image Center
                  Expanded(
                    child: Center(
                      child: Hero(
                        tag: 'pokemon-img-${pokemon.id}',
                        child: CachedNetworkImage(
                          imageUrl: pokemon.imageUrl,
                          fit: BoxFit.contain,
                          memCacheHeight: 250,
                          placeholder: (context, url) => Center(
                            child: SizedBox(
                              width: 24.r,
                              height: 24.r,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: typeColor,
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Icon(
                            Icons.broken_image,
                            size: 40.r,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Pokemon Name
                  SizedBox(height: 6.h),
                  Text(
                    pokemon.name.formatName(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.3,
                    ),
                  ),

                  // Type Badges
                  SizedBox(height: 6.h),
                  Wrap(
                    spacing: 4.w,
                    runSpacing: 4.h,
                    children: pokemon.types
                        .take(2)
                        .map((type) => PokemonTypeBadge(
                              typeName: type,
                              fontSize: 9.5,
                              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
