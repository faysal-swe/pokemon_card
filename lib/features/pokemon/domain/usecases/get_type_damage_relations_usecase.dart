import '../../../../core/utils/result.dart';
import '../entities/type_damage_relations.dart';
import '../repositories/pokemon_repository.dart';

class GetTypeDamageRelationsUseCase {
  final PokemonRepository repository;

  GetTypeDamageRelationsUseCase(this.repository);

  Future<Result<TypeDamageRelations>> call(String typeName) {
    return repository.getTypeDamageRelations(typeName);
  }
}
