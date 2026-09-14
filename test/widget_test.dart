import 'package:flutter_test/flutter_test.dart';
import 'package:pokemon_card/core/utils/string_extensions.dart';
import 'package:pokemon_card/features/pokemon/domain/entities/pokemon.dart';
import 'package:pokemon_card/features/pokemon/domain/entities/pokemon_detail.dart';

void main() {
  group('Pokemon Domain & Utility Tests', () {
    test('String formatting extensions work correctly', () {
      expect('pikachu'.capitalize(), 'Pikachu');
      expect('special-attack'.formatName(), 'Special Attack');
      expect(1.toPokedexId(), '#001');
      expect(25.toPokedexId(), '#025');
      expect(1025.toPokedexId(), '#1025');
    });

    test('Pokemon entity returns correct primary and secondary types', () {
      const pokemon = Pokemon(
        id: 1,
        name: 'bulbasaur',
        imageUrl: 'https://example.com/1.png',
        types: ['grass', 'poison'],
      );

      expect(pokemon.primaryType, 'grass');
      expect(pokemon.secondaryType, 'poison');
    });

    test('PokemonDetail dynamically calculates total base stats correctly', () {
      const detail = PokemonDetail(
        id: 25,
        name: 'pikachu',
        imageUrl: 'https://example.com/25.png',
        height: 4,
        weight: 60,
        baseExperience: 112,
        types: ['electric'],
        abilities: [PokemonAbility(name: 'static', isHidden: false)],
        stats: [
          PokemonStat(name: 'hp', value: 35),
          PokemonStat(name: 'attack', value: 55),
          PokemonStat(name: 'defense', value: 40),
          PokemonStat(name: 'special-attack', value: 50),
          PokemonStat(name: 'special-defense', value: 50),
          PokemonStat(name: 'speed', value: 90),
        ],
        moves: [],
      );

      // 35 + 55 + 40 + 50 + 50 + 90 = 320
      expect(detail.totalStats, 320);
    });

    test('Height and weight converters compute proper metric and imperial values', () {
      // 7 decimeters = 0.7 m
      expect(7.toHeightString(), contains('0.7 m'));
      // 69 hectograms = 6.9 kg
      expect(69.toWeightString(), contains('6.9 kg'));
    });
  });
}
