extension StringExtensions on String {
  /// Capitalizes the first letter of the string (e.g., "pikachu" -> "Pikachu").
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Capitalizes each word separated by hyphen or space (e.g., "special-attack" -> "Special Attack").
  String formatName() {
    if (isEmpty) return this;
    return split(RegExp(r'[-_ ]'))
        .map((str) => str.capitalize())
        .join(' ');
  }
}

extension IntExtensions on int {
  /// Formats Pokemon ID into Pokédex style #001, #025, #1000
  String toPokedexId() {
    return '#${toString().padLeft(3, '0')}';
  }

  /// Converts PokeAPI decimeters to meters and feet string (e.g., 7 -> "0.7 m (2'04\")")
  String toHeightString() {
    final meters = this / 10.0;
    final totalInches = (meters * 39.3701).round();
    final feet = totalInches ~/ 12;
    final inches = totalInches % 12;
    return '${meters.toStringAsFixed(1)} m ($feet\'${inches.toString().padLeft(2, '0')}")';
  }

  /// Converts PokeAPI hectograms to kg and lbs string (e.g., 69 -> "6.9 kg (15.2 lbs)")
  String toWeightString() {
    final kg = this / 10.0;
    final lbs = kg * 2.20462;
    return '${kg.toStringAsFixed(1)} kg (${lbs.toStringAsFixed(1)} lbs)';
  }
}
