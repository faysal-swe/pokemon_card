import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/error/exceptions.dart';
import '../models/pokemon_detail_model.dart';

abstract class PokemonLocalDataSource {
  Future<List<int>> getFavoritePokemonIds();
  Future<bool> toggleFavorite(int pokemonId);
  Future<bool> isFavorite(int pokemonId);

  Future<List<int?>> getTeamPokemonIds();
  Future<void> setTeamSlot(int slotIndex, int? pokemonId);

  Future<int> getBestStreak();
  Future<void> saveBestStreak(int streak);

  Future<void> cachePokemonDetail(PokemonDetailModel detail);
  Future<PokemonDetailModel?> getCachedPokemonDetail(int id);
}

class PokemonLocalDataSourceImpl implements PokemonLocalDataSource {
  final SharedPreferences sharedPreferences;

  static const String _favoritesKey = 'CACHED_FAVORITE_POKEMON_IDS';
  static const String _teamKey = 'CACHED_TEAM_POKEMON_IDS';
  static const String _streakKey = 'CACHED_MINI_GAME_BEST_STREAK';
  static const String _pokemonPrefix = 'CACHED_POKEMON_DETAIL_';

  PokemonLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<List<int>> getFavoritePokemonIds() async {
    try {
      final list = sharedPreferences.getStringList(_favoritesKey);
      if (list == null) return [];
      return list.map((idStr) => int.tryParse(idStr) ?? 0).where((id) => id > 0).toList();
    } catch (e) {
      throw CacheException('Failed to get favorites: $e');
    }
  }

  @override
  Future<bool> toggleFavorite(int pokemonId) async {
    try {
      final favorites = await getFavoritePokemonIds();
      final exists = favorites.contains(pokemonId);
      if (exists) {
        favorites.remove(pokemonId);
      } else {
        favorites.add(pokemonId);
      }
      await sharedPreferences.setStringList(
        _favoritesKey,
        favorites.map((id) => id.toString()).toList(),
      );
      return !exists;
    } catch (e) {
      throw CacheException('Failed to toggle favorite: $e');
    }
  }

  @override
  Future<bool> isFavorite(int pokemonId) async {
    final favorites = await getFavoritePokemonIds();
    return favorites.contains(pokemonId);
  }

  @override
  Future<List<int?>> getTeamPokemonIds() async {
    try {
      final list = sharedPreferences.getStringList(_teamKey);
      if (list == null || list.length != 6) {
        return List<int?>.filled(6, null);
      }
      return list.map((str) => str == 'null' ? null : int.tryParse(str)).toList();
    } catch (e) {
      return List<int?>.filled(6, null);
    }
  }

  @override
  Future<void> setTeamSlot(int slotIndex, int? pokemonId) async {
    try {
      final team = await getTeamPokemonIds();
      if (slotIndex < 0 || slotIndex >= 6) return;
      team[slotIndex] = pokemonId;
      await sharedPreferences.setStringList(
        _teamKey,
        team.map((id) => id == null ? 'null' : id.toString()).toList(),
      );
    } catch (e) {
      throw CacheException('Failed to update team: $e');
    }
  }

  @override
  Future<int> getBestStreak() async {
    return sharedPreferences.getInt(_streakKey) ?? 0;
  }

  @override
  Future<void> saveBestStreak(int streak) async {
    final current = await getBestStreak();
    if (streak > current) {
      await sharedPreferences.setInt(_streakKey, streak);
    }
  }

  @override
  Future<void> cachePokemonDetail(PokemonDetailModel detail) async {
    try {
      final jsonString = jsonEncode(detail.toJson());
      await sharedPreferences.setString('$_pokemonPrefix${detail.id}', jsonString);
    } catch (_) {}
  }

  @override
  Future<PokemonDetailModel?> getCachedPokemonDetail(int id) async {
    try {
      final jsonString = sharedPreferences.getString('$_pokemonPrefix$id');
      if (jsonString == null) return null;
      final map = jsonDecode(jsonString) as Map<String, dynamic>;
      return PokemonDetailModel.fromJson(map);
    } catch (_) {
      return null;
    }
  }
}
