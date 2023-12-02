import 'dart:async';

/// Represents the continuation for the next task to execute in the pipeline.
typedef RequestHandlerDelegate<TResponse> = FutureOr<TResponse> Function();

/// Pipeline behavior to surround the inner handler.
/// Implementations add additional behavior and await the next delegate.
abstract interface class PipelineBehavior<TResponse, TRequest> {
  /// Pipeline handler for [request].
  ///
  /// Perform any additional behavior and await the [next] delegate.
  FutureOr<TResponse> handle(
    TRequest request,
    RequestHandlerDelegate<TResponse> next,
  );
}
