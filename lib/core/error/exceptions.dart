/// Thrown when the remote API returns an error response.
class ServerException implements Exception {
  final String message;
  final int? statusCode;

  const ServerException(this.message, {this.statusCode});

  @override
  String toString() => 'ServerException: $message (code: $statusCode)';
}

/// Thrown when device has no internet connection prior to making a call.
class NoInternetException implements Exception {
  final String message;

  const NoInternetException([this.message = 'No active internet connection']);

  @override
  String toString() => 'NoInternetException: $message';
}

/// Thrown when an error occurs reading or writing local data.
class CacheException implements Exception {
  final String message;

  const CacheException([this.message = 'Cache operation failed']);

  @override
  String toString() => 'CacheException: $message';
}
