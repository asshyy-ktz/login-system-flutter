import 'package:equatable/equatable.dart';

/// Domain-level error type. Use cases and repositories return these (wrapped in
/// [Result]) instead of throwing, so the presentation layer handles a closed
/// set of outcomes.
sealed class Failure extends Equatable {
  const Failure(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure(super.message, {this.statusCode});
  final int? statusCode;

  @override
  List<Object?> get props => [message, statusCode];
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Cache error']);
}

class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

class InvalidCredentialsFailure extends Failure {
  const InvalidCredentialsFailure([super.message = 'Invalid email or password']);
}

class AccountLockedFailure extends Failure {
  const AccountLockedFailure([super.message = 'Account is locked']);
}

class NotVerifiedFailure extends Failure {
  const NotVerifiedFailure([super.message = 'Account is not verified']);
}

class CancelledFailure extends Failure {
  const CancelledFailure([super.message = 'Cancelled']);
}
