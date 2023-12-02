import 'dart:async';

/// Handler for [TRequest].
abstract interface class RequestHandler<TResponse, TRequest> {
  /// Handles the given [request].
  FutureOr<TResponse> handle(TRequest request);
}
