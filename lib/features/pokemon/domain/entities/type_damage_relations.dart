import 'package:equatable/equatable.dart';

class TypeDamageRelations extends Equatable {
  final String typeName;
  final List<String> doubleDamageFrom;
  final List<String> halfDamageFrom;
  final List<String> noDamageFrom;

  const TypeDamageRelations({
    required this.typeName,
    required this.doubleDamageFrom,
    required this.halfDamageFrom,
    required this.noDamageFrom,
  });

  @override
  List<Object?> get props => [
        typeName,
        doubleDamageFrom,
        halfDamageFrom,
        noDamageFrom,
      ];
}
