import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/pokemon/presentation/screens/favorites_team_screen.dart';
import '../../features/pokemon/presentation/screens/home_screen.dart';
import '../../features/pokemon/presentation/screens/mini_game_screen.dart';
import '../../features/pokemon/presentation/screens/pokemon_detail_screen.dart';
import '../../features/pokemon/presentation/screens/type_calculator_screen.dart';
import '../constants/app_colors.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

class MainNavigationScaffold extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainNavigationScaffold({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        indicatorColor: AppColors.primaryRed.withOpacity(0.18),
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.catching_pokemon_outlined),
            selectedIcon: Icon(Icons.catching_pokemon, color: AppColors.primaryRed),
            label: 'Pokédex',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border_rounded),
            selectedIcon: Icon(Icons.favorite_rounded, color: AppColors.primaryRed),
            label: 'Team & Favs',
          ),
          NavigationDestination(
            icon: Icon(Icons.calculate_outlined),
            selectedIcon: Icon(Icons.calculate_rounded, color: AppColors.primaryRed),
            label: 'Calculator',
          ),
          NavigationDestination(
            icon: Icon(Icons.help_outline_rounded),
            selectedIcon: Icon(Icons.help_rounded, color: AppColors.primaryRed),
            label: 'Mini Game',
          ),
        ],
      ),
    );
  }
}

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    // Bottom navigation branches
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainNavigationScaffold(navigationShell: navigationShell);
      },
      branches: [
        // Tab 1: Home
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),

        // Tab 2: Favorites & Team Builder
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/favorites',
              builder: (context, state) => const FavoritesTeamScreen(),
            ),
          ],
        ),

        // Tab 3: Type Calculator
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/type-calculator',
              builder: (context, state) => const TypeCalculatorScreen(),
            ),
          ],
        ),

        // Tab 4: Mini Game
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/mini-game',
              builder: (context, state) => const MiniGameScreen(),
            ),
          ],
        ),
      ],
    ),

    // Detail Screen (Pushed on top of navigation shell)
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/pokemon/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '1';
        return PokemonDetailScreen(pokemonId: id);
      },
    ),
  ],
);
