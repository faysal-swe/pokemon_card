import 'package:equatable/equatable.dart';

/// Base Failure class representing an error in the domain layer.
abstract class Failure extends Equatable {
  final String message;
  final int? statusCode;

  const Failure(this.message, {this.statusCode});

  @override
  List<Object?> get props => [message, statusCode];
}

/// Server returned an error (4xx, 5xx).
class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.statusCode});
}

/// Device has no internet connection.
class NoInternetFailure extends Failure {
  const NoInternetFailure([super.message = 'No internet connection. Please check your network.']);
}

/// Network timeout or socket error.
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Network error occurred. Please try again.']);
}

/// Cache or local storage error.
class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Failed to load local data.']);
}

/// Unexpected or unknown failure.
class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'An unexpected error occurred. Please try again.']);
}
