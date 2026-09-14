import 'package:equatable/equatable.dart';

/// Represents basic Pokemon summary data used for grid items and previews.
class Pokemon extends Equatable {
  final int id;
  final String name;
  final String imageUrl;
  final List<String> types;

  const Pokemon({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.types,
  });

  String get primaryType => types.isNotEmpty ? types.first : 'normal';
  String? get secondaryType => types.length > 1 ? types[1] : null;

  @override
  List<Object?> get props => [id, name, imageUrl, types];
}
