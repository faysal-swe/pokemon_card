import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/network_info.dart';
import '../../data/datasources/pokemon_local_data_source.dart';
import '../../data/datasources/pokemon_remote_data_source.dart';
import '../../data/repositories/pokemon_repository_impl.dart';
import '../../domain/repositories/pokemon_repository.dart';
import '../../domain/usecases/filter_pokemon_usecase.dart';
import '../../domain/usecases/get_evolution_chain_usecase.dart';
import '../../domain/usecases/get_pokemon_detail_usecase.dart';
import '../../domain/usecases/get_pokemon_list_usecase.dart';
import '../../domain/usecases/get_type_damage_relations_usecase.dart';
import '../../domain/usecases/manage_favorites_usecase.dart';
import '../../domain/usecases/manage_team_usecase.dart';
import '../../domain/usecases/mini_game_usecase.dart';
import '../../domain/usecases/search_pokemon_usecase.dart';

/// SharedPreferences instance provider (overridden in main.dart)
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden in ProviderScope');
});

/// Network Connectivity Provider
final networkInfoProvider = Provider<NetworkInfo>((ref) {
  return NetworkInfoImpl(InternetConnectionChecker());
});

/// Dio ApiClient Provider
final apiClientProvider = Provider<ApiClient>((ref) {
  final networkInfo = ref.watch(networkInfoProvider);
  return ApiClient(networkInfo: networkInfo);
});

/// Remote Data Source Provider
final pokemonRemoteDataSourceProvider = Provider<PokemonRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return PokemonRemoteDataSourceImpl(apiClient: apiClient);
});

/// Local Data Source Provider
final pokemonLocalDataSourceProvider = Provider<PokemonLocalDataSource>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return PokemonLocalDataSourceImpl(sharedPreferences: prefs);
});

/// Pokemon Repository Provider
final pokemonRepositoryProvider = Provider<PokemonRepository>((ref) {
  final remote = ref.watch(pokemonRemoteDataSourceProvider);
  final local = ref.watch(pokemonLocalDataSourceProvider);
  return PokemonRepositoryImpl(remoteDataSource: remote, localDataSource: local);
});

/// Use Cases Providers
final getPokemonListUseCaseProvider = Provider<GetPokemonListUseCase>((ref) {
  return GetPokemonListUseCase(ref.watch(pokemonRepositoryProvider));
});

final getPokemonDetailUseCaseProvider = Provider<GetPokemonDetailUseCase>((ref) {
  return GetPokemonDetailUseCase(ref.watch(pokemonRepositoryProvider));
});

final searchPokemonUseCaseProvider = Provider<SearchPokemonUseCase>((ref) {
  return SearchPokemonUseCase(ref.watch(pokemonRepositoryProvider));
});

final filterPokemonUseCaseProvider = Provider<FilterPokemonUseCase>((ref) {
  return FilterPokemonUseCase(ref.watch(pokemonRepositoryProvider));
});

final getEvolutionChainUseCaseProvider = Provider<GetEvolutionChainUseCase>((ref) {
  return GetEvolutionChainUseCase(ref.watch(pokemonRepositoryProvider));
});

final getTypeDamageRelationsUseCaseProvider = Provider<GetTypeDamageRelationsUseCase>((ref) {
  return GetTypeDamageRelationsUseCase(ref.watch(pokemonRepositoryProvider));
});

final manageFavoritesUseCaseProvider = Provider<ManageFavoritesUseCase>((ref) {
  return ManageFavoritesUseCase(ref.watch(pokemonRepositoryProvider));
});

final manageTeamUseCaseProvider = Provider<ManageTeamUseCase>((ref) {
  return ManageTeamUseCase(ref.watch(pokemonRepositoryProvider));
});

final miniGameUseCaseProvider = Provider<MiniGameUseCase>((ref) {
  return MiniGameUseCase(ref.watch(pokemonRepositoryProvider));
});
