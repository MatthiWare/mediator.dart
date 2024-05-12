import 'dart:async';

import 'package:meta/meta.dart';

/// Represents the continuation for the next task to execute in the pipeline.
typedef RequestHandlerDelegate<TResponse> = FutureOr<TResponse> Function();

/// Factory to create a [PipelineBehavior].
typedef PipelineBehaviorFactory<TRequest, TResponse>
    = PipelineBehavior<TRequest, TResponse> Function();

typedef PipelineHandler<TResponse, TRequest> = FutureOr<TResponse> Function(
    TRequest, RequestHandlerDelegate<TResponse>);

/// Pipeline behavior to surround the inner handler.
/// Implementations add additional behavior and await the next delegate.
abstract interface class PipelineBehavior<TResponse, TRequest> {
  /// Function based [PipelineBehavior].
  const factory PipelineBehavior.function(
    PipelineHandler<TResponse, TRequest> handler,
  ) = _FunctionPipelineBehavior;

  /// Factory based [PipelineBehavior].
  const factory PipelineBehavior.factory(
    PipelineBehaviorFactory<TResponse, TRequest> factory,
  ) = _FactoryPipelineBehavior;

  /// Pipeline handler for [request].
  ///
  /// Perform any additional behavior and await the [next] delegate.
  FutureOr<TResponse> handle(
    TRequest request,
    RequestHandlerDelegate<TResponse> next,
  );
}

@immutable
class _FunctionPipelineBehavior<TResponse, TRequest>
    implements PipelineBehavior<TResponse, TRequest> {
  final PipelineHandler<TResponse, TRequest> handler;

  const _FunctionPipelineBehavior(this.handler);

  @override
  FutureOr<TResponse> handle(
    TRequest request,
    RequestHandlerDelegate<TResponse> next,
  ) =>
      handler(request, next);

  @override
  int get hashCode => Object.hash(runtimeType, handler);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _FunctionPipelineBehavior<TResponse, TRequest> &&
            other.handler == handler);
  }
}

@immutable
class _FactoryPipelineBehavior<TResponse, TRequest>
    implements PipelineBehavior<TResponse, TRequest> {
  final PipelineBehaviorFactory<TResponse, TRequest> factory;

  const _FactoryPipelineBehavior(this.factory);

  @override
  FutureOr<TResponse> handle(
    TRequest request,
    RequestHandlerDelegate<TResponse> next,
  ) {
    final behavior = factory();
    return behavior.handle(request, next);
  }

  @override
  int get hashCode => Object.hash(runtimeType, factory);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _FactoryPipelineBehavior<TResponse, TRequest> &&
            other.factory == factory);
  }
}
