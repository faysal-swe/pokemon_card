import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/custom_loading_indicator.dart';
import '../providers/pokemon_list_provider.dart';
import '../providers/pokemon_search_provider.dart';
import '../widgets/generation_selector_sheet.dart';
import '../widgets/pokemon_card.dart';
import '../widgets/pokemon_search_bar.dart';
import '../widgets/type_filter_bar.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Check if user is within 300 pixels from the bottom
    if (_scrollController.hasClients) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      if (maxScroll - currentScroll <= 300) {
        ref.read(pokemonListNotifierProvider.notifier).loadMore();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final searchQuery = ref.watch(pokemonSearchQueryProvider);
    final isSearching = searchQuery.trim().isNotEmpty;
    log("build");
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primaryRed,
          onRefresh: () =>
              ref.read(pokemonListNotifierProvider.notifier).refresh(),
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Modern App Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Pokédex',
                                style: TextStyle(
                                  fontSize: 28.sp,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.8,
                                ),
                              ),
                              Text(
                                'Explore Pokémon & Battle Strategies',
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withOpacity(0.5),
                                ),
                              ),
                            ],
                          ),
                          // Generation selector action button
                          Consumer(
                            builder: (context, ref, _) {
                              final activeGen = ref.watch(
                                pokemonListNotifierProvider.select(
                                  (s) => s.activeGenerationId,
                                ),
                              );
                              return OutlinedButton.icon(
                                onPressed: () =>
                                    GenerationSelectorSheet.show(context),
                                icon: Icon(
                                  Icons.public,
                                  size: 16.sp,
                                  color: AppColors.primaryRed,
                                ),
                                label: Text(
                                  activeGen != null
                                      ? 'Gen $activeGen'
                                      : 'Region',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryRed,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                    color: AppColors.primaryRed,
                                    width: 1.2,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.r),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12.w,
                                    vertical: 6.h,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 14.h),
                      const PokemonSearchBar(),
                    ],
                  ),
                ),
              ),

              // Filter Chips Bar (hidden while active text search is happening)
              if (!isSearching) ...[
                const SliverToBoxAdapter(child: TypeFilterBar()),
                SliverToBoxAdapter(child: SizedBox(height: 12.h)),
              ],

              // Content Area: Either Search Results or Main Paginated Grid
              if (isSearching)
                _buildSearchResultsSliver(context, ref)
              else
                _buildMainGridSliver(context, ref),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResultsSliver(BuildContext context, WidgetRef ref) {
    final searchAsync = ref.watch(pokemonSearchResultProvider);

    return searchAsync.when(
      loading: () => const SliverFillRemaining(
        child: CustomLoadingIndicator(message: 'Searching Pokémon...'),
      ),
      error: (err, _) => SliverFillRemaining(
        child: AppErrorWidget(
          message: err.toString(),
          icon: Icons.search_off_rounded,
        ),
      ),
      data: (detail) {
        if (detail == null) {
          return const SliverFillRemaining(
            child: Center(child: Text('Type a Pokémon name or ID to search')),
          );
        }

        final pokemonSummary = detail;
        return SliverPadding(
          padding: EdgeInsets.all(16.r),
          sliver: SliverToBoxAdapter(
            child: SizedBox(
              height: 220.h,
              child: PokemonCard(pokemon: pokemonSummary),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMainGridSliver(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(
      pokemonListNotifierProvider.select((s) => s.isLoading),
    );
    final errorMessage = ref.watch(
      pokemonListNotifierProvider.select((s) => s.errorMessage),
    );
    final pokemonList = ref.watch(
      pokemonListNotifierProvider.select((s) => s.pokemonList),
    );
    final isLoadingMore = ref.watch(
      pokemonListNotifierProvider.select((s) => s.isLoadingMore),
    );
    final hasReachedMax = ref.watch(
      pokemonListNotifierProvider.select((s) => s.hasReachedMax),
    );

    if (isLoading && pokemonList.isEmpty) {
      return const SliverFillRemaining(
        child: CustomLoadingIndicator(message: 'Catching Pokémon...'),
      );
    }

    if (errorMessage != null && pokemonList.isEmpty) {
      return SliverFillRemaining(
        child: AppErrorWidget(
          message: errorMessage,
          onRetry: () =>
              ref.read(pokemonListNotifierProvider.notifier).loadInitial(),
        ),
      );
    }

    if (pokemonList.isEmpty) {
      return const SliverFillRemaining(
        child: Center(child: Text('No Pokémon found in this category.')),
      );
    }

    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      sliver: SliverMainAxisGroup(
        slivers: [
          SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.78,
              crossAxisSpacing: 12.w,
              mainAxisSpacing: 12.h,
            ),
            delegate: SliverChildBuilderDelegate((context, index) {
              return PokemonCard(pokemon: pokemonList[index]);
            }, childCount: pokemonList.length),
          ),

          // Pagination Footer Indicator
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20.h),
              child: Center(
                child: isLoadingMore
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 18.r,
                            height: 18.r,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: AppColors.primaryRed,
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Text(
                            'Loading more Pokémon...',
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      )
                    : hasReachedMax
                    ? Text(
                        '🎉 You\'ve reached the end of the Pokédex!',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.5),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
