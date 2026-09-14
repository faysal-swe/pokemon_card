import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/toast_utils.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/string_extensions.dart';
import '../../../../core/widgets/custom_loading_indicator.dart';
import '../providers/favorites_provider.dart';
import '../providers/pokemon_detail_provider.dart';
import '../providers/pokemon_list_provider.dart';
import '../providers/team_provider.dart';
import '../widgets/pokemon_card.dart';
import '../widgets/pokemon_type_badge.dart';

class FavoritesTeamScreen extends ConsumerStatefulWidget {
  const FavoritesTeamScreen({super.key});

  @override
  ConsumerState<FavoritesTeamScreen> createState() => _FavoritesTeamScreenState();
}

class _FavoritesTeamScreenState extends ConsumerState<FavoritesTeamScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved & Teams'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primaryRed,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.primaryRed,
          indicatorWeight: 3,
          tabs: const [
            Tab(icon: Icon(Icons.favorite_rounded), text: 'Favorites'),
            Tab(icon: Icon(Icons.shield_rounded), text: 'Team Builder'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFavoritesTab(context, ref),
          _buildTeamTab(context, ref),
        ],
      ),
    );
  }

  Widget _buildFavoritesTab(BuildContext context, WidgetRef ref) {
    final favoriteIds = ref.watch(favoritesProvider);

    if (favoriteIds.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(32.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.favorite_border_rounded, size: 70.r, color: Colors.grey.withOpacity(0.5)),
              SizedBox(height: 16.h),
              Text(
                'No Favorites Yet',
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.h),
              Text(
                'Tap the heart icon on any Pokémon card or detail screen to save it here for offline viewing.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13.sp, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return GridView.builder(
      padding: EdgeInsets.all(16.r),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.78,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
      ),
      itemCount: favoriteIds.length,
      itemBuilder: (context, index) {
        final id = favoriteIds[index];
        final detailAsync = ref.watch(pokemonDetailFamily(id.toString()));

        return detailAsync.when(
          loading: () => Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ),
          error: (_, __) => Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Center(
              child: Text(
                '#$id',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          data: (detail) => PokemonCard(pokemon: detail),
        );
      },
    );
  }

  Widget _buildTeamTab(BuildContext context, WidgetRef ref) {
    final teamState = ref.watch(teamNotifierProvider);

    return ListView(
      padding: EdgeInsets.all(16.r),
      children: [
        Text(
          'Battle Team (Max 6)',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 4.h),
        Text(
          'Select up to 6 Pokémon to inspect combined type coverage and weaknesses.',
          style: TextStyle(fontSize: 12.5.sp, color: Colors.grey),
        ),
        SizedBox(height: 16.h),

        // 6 Team Slots Grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.15,
            crossAxisSpacing: 12.w,
            mainAxisSpacing: 12.h,
          ),
          itemCount: 6,
          itemBuilder: (context, slotIndex) {
            final pokemonId = teamState.slots[slotIndex];
            return _buildTeamSlotCard(context, ref, slotIndex, pokemonId);
          },
        ),

        SizedBox(height: 24.h),
        // Dynamic Team Coverage Widget
        _buildTeamCoverageWidget(context, ref),
      ],
    );
  }

  Widget _buildTeamSlotCard(
    BuildContext context,
    WidgetRef ref,
    int slotIndex,
    int? pokemonId,
  ) {
    if (pokemonId == null) {
      // Empty Slot
      return InkWell(
        onTap: () => _showAddPokemonDialog(context, ref, slotIndex),
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: Colors.grey.withOpacity(0.3),
              style: BorderStyle.solid,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add_circle_outline_rounded, size: 28.sp, color: AppColors.primaryRed),
                SizedBox(height: 6.h),
                Text(
                  'Slot ${slotIndex + 1}\nEmpty',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Filled Slot
    final detailAsync = ref.watch(pokemonDetailFamily(pokemonId.toString()));

    return detailAsync.when(
      loading: () => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      error: (_, __) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Center(child: Text('#$pokemonId')),
      ),
      data: (pokemon) {
        final typeColor = AppColors.getTypeColor(pokemon.primaryType);

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            gradient: LinearGradient(
              colors: [typeColor.withOpacity(0.2), Theme.of(context).cardColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: typeColor.withOpacity(0.3)),
          ),
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.all(10.r),
                child: Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: CachedNetworkImage(
                        imageUrl: pokemon.imageUrl,
                        fit: BoxFit.contain,
                        placeholder: (_, __) => const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      flex: 5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            pokemon.name.formatName(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            pokemon.id.toPokedexId(),
                            style: TextStyle(fontSize: 10.sp, color: Colors.grey),
                          ),
                          SizedBox(height: 4.h),
                          PokemonTypeBadge(
                            typeName: pokemon.primaryType,
                            fontSize: 8.5,
                            showIcon: false,
                            padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 4.h,
                right: 4.w,
                child: IconButton(
                  icon: Icon(Icons.close_rounded, size: 16.sp, color: Colors.grey),
                  onPressed: () {
                    ref.read(teamNotifierProvider.notifier).removeSlot(slotIndex);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddPokemonDialog(BuildContext context, WidgetRef ref, int slotIndex) {
    final list = ref.read(pokemonListNotifierProvider).pokemonList;
    final favIds = ref.read(favoritesProvider);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (ctx) {
        return Container(
          padding: EdgeInsets.all(16.r),
          height: 450.h,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add to Team Slot ${slotIndex + 1}',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12.h),
              Expanded(
                child: ListView.separated(
                  itemCount: list.length,
                  separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey.withOpacity(0.1)),
                  itemBuilder: (c, i) {
                    final p = list[i];
                    final isFav = favIds.contains(p.id);

                    return ListTile(
                      leading: CachedNetworkImage(
                        imageUrl: p.imageUrl,
                        width: 40.r,
                        height: 40.r,
                      ),
                      title: Text(p.name.formatName(), style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(p.id.toPokedexId()),
                      trailing: isFav ? const Icon(Icons.favorite, color: AppColors.primaryRed, size: 16) : null,
                      onTap: () {
                        ref.read(teamNotifierProvider.notifier).setSlot(slotIndex, p.id);
                        Navigator.pop(ctx);
                        AppToast.show('${p.name.formatName()} added to Team!', context: context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTeamCoverageWidget(BuildContext context, WidgetRef ref) {
    final coverageAsync = ref.watch(teamCoverageProvider);

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Team Coverage Analysis',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
              Icon(Icons.analytics_rounded, color: AppColors.primaryRed, size: 20.sp),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            'Dynamic calculation of attacking types based on team composition',
            style: TextStyle(fontSize: 11.5.sp, color: Colors.grey),
          ),
          SizedBox(height: 14.h),

          coverageAsync.when(
            loading: () => const Center(
              child: CustomLoadingIndicator(message: 'Calculating coverage...'),
            ),
            error: (e, _) => Text('Error calculating coverage: $e'),
            data: (report) {
              if (report.weaknesses.isEmpty && report.resistances.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: Text('Add Pokémon to the team to inspect defensive coverage.'),
                  ),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Weaknesses Section
                  Text(
                    '⚠ Team Weaknesses',
                    style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: Colors.orange),
                  ),
                  SizedBox(height: 6.h),
                  Wrap(
                    spacing: 6.w,
                    runSpacing: 6.h,
                    children: report.weaknesses.entries.map((entry) {
                      final typeColor = AppColors.getTypeColor(entry.key);
                      return Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: typeColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(color: typeColor.withOpacity(0.4)),
                        ),
                        child: Text(
                          '${entry.key.capitalize()} (${entry.value} weak)',
                          style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: typeColor),
                        ),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 14.h),

                  // Resistances Section
                  Text(
                    '✓ Team Resistances',
                    style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                  SizedBox(height: 6.h),
                  Wrap(
                    spacing: 6.w,
                    runSpacing: 6.h,
                    children: report.resistances.entries.map((entry) {
                      final typeColor = AppColors.getTypeColor(entry.key);
                      return Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: typeColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(color: typeColor.withOpacity(0.4)),
                        ),
                        child: Text(
                          '${entry.key.capitalize()} (${entry.value} resist)',
                          style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: typeColor),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
