class ApiConstants {
  static const String baseUrl = 'https://pokeapi.co/api/v2/';

  // Endpoints
  static const String pokemon = 'pokemon';
  static const String pokemonSpecies = 'pokemon-species';
  static const String evolutionChain = 'evolution-chain';
  static const String type = 'type';
  static const String generation = 'generation';

  // Network Timeouts (in milliseconds)
  static const int connectTimeout = 15000;
  static const int receiveTimeout = 15000;
  static const int sendTimeout = 15000;

  // Pagination default
  static const int defaultLimit = 20;

  // Helper to construct official artwork URL directly from Pokemon ID
  static String getOfficialArtworkUrl(int id) {
    return 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';
  }

  // Helper to construct Pokemon cry audio URL
  static String getPokemonCryUrl(int id) {
    return 'https://raw.githubusercontent.com/PokeAPI/cries/main/cries/pokemon/latest/$id.ogg';
  }
}
