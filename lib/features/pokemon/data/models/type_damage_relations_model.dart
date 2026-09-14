import '../../domain/entities/type_damage_relations.dart';

class TypeDamageRelationsModel extends TypeDamageRelations {
  final List<String> pokemonNames;

  const TypeDamageRelationsModel({
    required super.typeName,
    required super.doubleDamageFrom,
    required super.halfDamageFrom,
    required super.noDamageFrom,
    this.pokemonNames = const [],
  });

  factory TypeDamageRelationsModel.fromJson(Map<String, dynamic> json) {
    final typeName = json['name'] as String;
    final damageRelations = json['damage_relations'] as Map<String, dynamic>;

    final doubleDamage = (damageRelations['double_damage_from'] as List<dynamic>?)
            ?.map((e) => e['name'] as String)
            .toList() ??
        [];

    final halfDamage = (damageRelations['half_damage_from'] as List<dynamic>?)
            ?.map((e) => e['name'] as String)
            .toList() ??
        [];

    final noDamage = (damageRelations['no_damage_from'] as List<dynamic>?)
            ?.map((e) => e['name'] as String)
            .toList() ??
        [];

    // Extract list of Pokemon belonging to this type
    final pokemonList = (json['pokemon'] as List<dynamic>?)
            ?.map((p) => p['pokemon']?['name'] as String)
            .whereType<String>()
            .toList() ??
        [];

    return TypeDamageRelationsModel(
      typeName: typeName,
      doubleDamageFrom: doubleDamage,
      halfDamageFrom: halfDamage,
      noDamageFrom: noDamage,
      pokemonNames: pokemonList,
    );
  }

  TypeDamageRelations toEntity() => this;
}
