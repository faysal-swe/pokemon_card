import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/pokemon.dart';
import '../../domain/entities/pokemon_detail.dart';
import '../../domain/entities/evolution_chain.dart';
import '../../domain/entities/type_damage_relations.dart';
import '../../domain/repositories/pokemon_repository.dart';
import '../datasources/pokemon_local_data_source.dart';
import '../datasources/pokemon_remote_data_source.dart';

class PokemonRepositoryImpl implements PokemonRepository {
  final PokemonRemoteDataSource remoteDataSource;
  final PokemonLocalDataSource localDataSource;

  PokemonRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Result<List<Pokemon>>> getPokemonList({int limit = 20, int offset = 0}) async {
    try {
      final models = await remoteDataSource.getPokemonList(limit: limit, offset: offset);
      return Success(models.map((m) => m.toEntity()).toList());
    } on NoInternetException catch (e) {
      return Error(NoInternetFailure(e.message));
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message, statusCode: e.statusCode));
    } catch (e) {
      return Error(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<PokemonDetail>> getPokemonDetail(String idOrName) async {
    final parsedId = int.tryParse(idOrName);
    try {
      final model = await remoteDataSource.getPokemonDetail(idOrName);
      // Cache locally for offline availability
      await localDataSource.cachePokemonDetail(model);
      return Success(model.toEntity());
    } on NoInternetException catch (e) {
      // Check offline cache if we have an ID
      if (parsedId != null) {
        final cached = await localDataSource.getCachedPokemonDetail(parsedId);
        if (cached != null) {
          return Success(cached.toEntity());
        }
      }
      return Error(NoInternetFailure(e.message));
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message, statusCode: e.statusCode));
    } catch (e) {
      return Error(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<PokemonDetail>> searchPokemon(String query) async {
    return getPokemonDetail(query);
  }

  @override
  Future<Result<List<Pokemon>>> getPokemonByType(String typeName) async {
    try {
      final models = await remoteDataSource.getPokemonByType(typeName);
      return Success(models.map((m) => m.toEntity()).toList());
    } on NoInternetException catch (e) {
      return Error(NoInternetFailure(e.message));
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message, statusCode: e.statusCode));
    } catch (e) {
      return Error(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<Pokemon>>> getPokemonByGeneration(int generationId) async {
    try {
      final models = await remoteDataSource.getPokemonByGeneration(generationId);
      return Success(models.map((m) => m.toEntity()).toList());
    } on NoInternetException catch (e) {
      return Error(NoInternetFailure(e.message));
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message, statusCode: e.statusCode));
    } catch (e) {
      return Error(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<EvolutionStage>> getEvolutionChain(int chainId) async {
    try {
      final chain = await remoteDataSource.getEvolutionChain(chainId);
      return Success(chain);
    } on NoInternetException catch (e) {
      return Error(NoInternetFailure(e.message));
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message, statusCode: e.statusCode));
    } catch (e) {
      return Error(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<TypeDamageRelations>> getTypeDamageRelations(String typeName) async {
    try {
      final model = await remoteDataSource.getTypeDamageRelations(typeName);
      return Success(model.toEntity());
    } on NoInternetException catch (e) {
      return Error(NoInternetFailure(e.message));
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message, statusCode: e.statusCode));
    } catch (e) {
      return Error(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<int>>> getFavoritePokemonIds() async {
    try {
      final list = await localDataSource.getFavoritePokemonIds();
      return Success(list);
    } catch (e) {
      return Error(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Result<bool>> toggleFavorite(int pokemonId) async {
    try {
      final isFav = await localDataSource.toggleFavorite(pokemonId);
      return Success(isFav);
    } catch (e) {
      return Error(CacheFailure(e.toString()));
    }
  }

  @override
  Future<bool> isFavorite(int pokemonId) async {
    return localDataSource.isFavorite(pokemonId);
  }

  @override
  Future<Result<List<int?>>> getTeamPokemonIds() async {
    try {
      final list = await localDataSource.getTeamPokemonIds();
      return Success(list);
    } catch (e) {
      return Error(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> setTeamSlot(int slotIndex, int? pokemonId) async {
    try {
      await localDataSource.setTeamSlot(slotIndex, pokemonId);
      return const Success(null);
    } catch (e) {
      return Error(CacheFailure(e.toString()));
    }
  }

  @override
  Future<int> getBestStreak() async {
    return localDataSource.getBestStreak();
  }

  @override
  Future<void> saveBestStreak(int streak) async {
    await localDataSource.saveBestStreak(streak);
  }
}
