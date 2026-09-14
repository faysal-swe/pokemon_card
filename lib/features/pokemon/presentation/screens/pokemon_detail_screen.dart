import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/toast_utils.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/string_extensions.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/custom_loading_indicator.dart';
import '../../domain/entities/pokemon_detail.dart';
import '../providers/favorites_provider.dart';
import '../providers/pokemon_detail_provider.dart';
import '../widgets/evolution_tree_view.dart';
import '../widgets/pokemon_type_badge.dart';
import '../widgets/stat_bar.dart';

class PokemonDetailScreen extends ConsumerStatefulWidget {
  final String pokemonId;

  const PokemonDetailScreen({super.key, required this.pokemonId});

  @override
  ConsumerState<PokemonDetailScreen> createState() => _PokemonDetailScreenState();
}

class _PokemonDetailScreenState extends ConsumerState<PokemonDetailScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlayingCry = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playCry(String? cryUrl) async {
    if (cryUrl == null || cryUrl.isEmpty) {
      AppToast.show('No audio cry available for this Pokémon.', context: context);
      return;
    }

    try {
      setState(() => _isPlayingCry = true);
      await _audioPlayer.stop();
      await _audioPlayer.play(UrlSource(cryUrl));
    } catch (e) {
      if (mounted) {
        AppToast.show('Unable to play cry sound.', context: context);
      }
    } finally {
      if (mounted) setState(() => _isPlayingCry = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(pokemonDetailFamily(widget.pokemonId));

    return Scaffold(
      body: detailAsync.when(
        loading: () => const Scaffold(
          body: Center(
            child: CustomLoadingIndicator(message: 'Loading Pokémon details...'),
          ),
        ),
        error: (err, _) => Scaffold(
          appBar: AppBar(),
          body: AppErrorWidget(
            message: err.toString(),
            onRetry: () => ref.refresh(pokemonDetailFamily(widget.pokemonId)),
          ),
        ),
        data: (pokemon) => _buildContent(context, pokemon),
      ),
    );
  }

  Widget _buildContent(BuildContext context, PokemonDetail pokemon) {
    final typeColor = AppColors.getTypeColor(pokemon.primaryType);
    final isFavorite = ref.watch(
      favoritesProvider.select((favs) => favs.contains(pokemon.id)),
    );

    return Column(
      children: [
        // Hero Header with primary type gradient
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                typeColor,
                typeColor.withOpacity(0.85),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Stack(
              children: [
                // Pokeball watermark
                Positioned(
                  right: -30.w,
                  bottom: -30.h,
                  child: Opacity(
                    opacity: 0.15,
                    child: Icon(
                      Icons.catching_pokemon,
                      size: 220.r,
                      color: Colors.white,
                    ),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
                  child: Column(
                    children: [
                      // Top Bar (Back, Cry, Favorite)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                            onPressed: () => context.pop(),
                          ),
                          Row(
                            children: [
                              // Audio Cry Button
                              IconButton(
                                icon: _isPlayingCry
                                    ? SizedBox(
                                        width: 20.r,
                                        height: 20.r,
                                        child: const CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(Icons.volume_up_rounded, color: Colors.white),
                                tooltip: 'Play Pokémon Cry',
                                onPressed: () => _playCry(pokemon.cryUrl),
                              ),
                              // Favorite Button
                              IconButton(
                                icon: Icon(
                                  isFavorite ? Icons.favorite : Icons.favorite_border,
                                  color: isFavorite ? Colors.redAccent : Colors.white,
                                ),
                                onPressed: () {
                                  ref.read(favoritesProvider.notifier).toggleFavorite(pokemon.id);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),

                      // Name, ID & Type Badges Row
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.w),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  pokemon.name.formatName(),
                                  style: TextStyle(
                                    fontSize: 26.sp,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                SizedBox(height: 6.h),
                                Wrap(
                                  spacing: 6.w,
                                  children: pokemon.types
                                      .map((type) => PokemonTypeBadge(typeName: type))
                                      .toList(),
                                ),
                              ],
                            ),
                            Text(
                              pokemon.id.toPokedexId(),
                              style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w900,
                                color: Colors.white.withOpacity(0.85),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Artwork with Hero
                      SizedBox(height: 10.h),
                      SizedBox(
                        height: 160.h,
                        child: Hero(
                          tag: 'pokemon-img-${pokemon.id}',
                          child: CachedNetworkImage(
                            imageUrl: pokemon.imageUrl,
                            fit: BoxFit.contain,
                            placeholder: (_, __) => const Center(
                              child: CircularProgressIndicator(color: Colors.white),
                            ),
                            errorWidget: (_, __, ___) => const Icon(
                              Icons.broken_image,
                              size: 60,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Detail Sections Card Container with Tabs
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            ),
            child: Column(
              children: [
                SizedBox(height: 8.h),
                TabBar(
                  controller: _tabController,
                  labelColor: typeColor,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: typeColor,
                  indicatorWeight: 3,
                  labelStyle: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold),
                  tabs: const [
                    Tab(text: 'About'),
                    Tab(text: 'Base Stats'),
                    Tab(text: 'Evolution'),
                    Tab(text: 'Moves'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildAboutTab(context, pokemon),
                      _buildStatsTab(context, pokemon),
                      _buildEvolutionTab(context, pokemon),
                      _buildMovesTab(context, pokemon),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAboutTab(BuildContext context, PokemonDetail pokemon) {
    return ListView(
      padding: EdgeInsets.all(20.r),
      children: [
        if (pokemon.flavorText != null) ...[
          Container(
            padding: EdgeInsets.all(14.r),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: Colors.grey.withOpacity(0.15)),
            ),
            child: Text(
              pokemon.flavorText!,
              style: TextStyle(
                fontSize: 13.5.sp,
                fontStyle: FontStyle.italic,
                height: 1.4,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
          ),
          SizedBox(height: 16.h),
        ],

        _buildInfoRow('Height', pokemon.height.toHeightString()),
        _buildInfoRow('Weight', pokemon.weight.toWeightString()),
        _buildInfoRow('Base Experience', '${pokemon.baseExperience} XP'),
        _buildInfoRow('Gender Ratio', pokemon.genderRatioString),
        _buildInfoRow(
          'Abilities',
          pokemon.abilities.map((a) => '${a.name.formatName()}${a.isHidden ? ' (Hidden)' : ''}').join(', '),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130.w,
            child: Text(
              title,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsTab(BuildContext context, PokemonDetail pokemon) {
    return ListView(
      padding: EdgeInsets.all(20.r),
      children: [
        ...pokemon.stats.map((stat) => StatBar(label: stat.name, value: stat.value)),
        SizedBox(height: 12.h),
        Divider(color: Colors.grey.withOpacity(0.2)),
        SizedBox(height: 8.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total Stats',
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              pokemon.totalStats.toString(),
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w900,
                color: AppColors.getTypeColor(pokemon.primaryType),
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Text(
          'Sum of all six core base stats calculated dynamically.',
          style: TextStyle(
            fontSize: 11.sp,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildEvolutionTab(BuildContext context, PokemonDetail pokemon) {
    if (pokemon.evolutionChainId == null) {
      return const Center(child: Text('No evolution data available for this Pokémon.'));
    }

    final chainAsync = ref.watch(evolutionChainFamily(pokemon.evolutionChainId!));

    return chainAsync.when(
      loading: () => const Center(
        child: CustomLoadingIndicator(message: 'Loading evolution chain...'),
      ),
      error: (err, _) => AppErrorWidget(
        message: 'Could not load evolution chain: $err',
      ),
      data: (chain) => SingleChildScrollView(
        padding: EdgeInsets.all(20.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Evolution Chain',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            EvolutionTreeView(chain: chain),
          ],
        ),
      ),
    );
  }

  Widget _buildMovesTab(BuildContext context, PokemonDetail pokemon) {
    final levelUpMoves = pokemon.moves.where((m) => m.learnMethod == 'level-up').toList()
      ..sort((a, b) => a.levelLearned.compareTo(b.levelLearned));
    final machineMoves = pokemon.moves.where((m) => m.learnMethod == 'machine').toList();
    final otherMoves = pokemon.moves.where((m) => m.learnMethod != 'level-up' && m.learnMethod != 'machine').toList();

    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          TabBar(
            labelColor: AppColors.primaryRed,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppColors.primaryRed,
            labelStyle: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold),
            tabs: [
              Tab(text: 'Level Up (${levelUpMoves.length})'),
              Tab(text: 'TM / HM (${machineMoves.length})'),
              Tab(text: 'Other (${otherMoves.length})'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildMoveList(levelUpMoves, isLevelUp: true),
                _buildMoveList(machineMoves),
                _buildMoveList(otherMoves),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoveList(List<PokemonMove> moves, {bool isLevelUp = false}) {
    if (moves.isEmpty) {
      return const Center(child: Text('No moves in this category'));
    }

    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      itemCount: moves.length,
      separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey.withOpacity(0.12)),
      itemBuilder: (context, index) {
        final move = moves[index];
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 10.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                move.name.formatName(),
                style: TextStyle(
                  fontSize: 13.5.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (isLevelUp)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: AppColors.primaryRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    'Lv. ${move.levelLearned}',
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryRed,
                    ),
                  ),
                )
              else
                Text(
                  move.learnMethod.formatName(),
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Colors.grey,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
