import 'dart:async';

import 'package:dart_mediator/src/request/request.dart';
import 'package:meta/meta.dart';

/// Factory to create a [RequestHandler].
typedef RequestHandlerFactory<TResponse, TRequest extends Request<TResponse>>
    = RequestHandler<TResponse, TRequest> Function();

/// Handler for [TRequest].
@internal
abstract interface class RequestHandler<TResponse,
    TRequest extends Request<TResponse>> {
  /// Function based [RequestHandler].
  const factory RequestHandler.function(
    FutureOr<TResponse> Function(TRequest) handler,
  ) = _FunctionRequestHandler;

  /// Factory based [RequestHandler].
  const factory RequestHandler.factory(
    RequestHandlerFactory<TResponse, TRequest> factory,
  ) = _FactoryRequestHandler;

  /// Handles the given [request].
  FutureOr<TResponse> handle(TRequest request);
}

/// Command handler for [TCommand].
abstract interface class CommandHandler<TCommand extends Command>
    implements RequestHandler<void, TCommand> {}

/// Query handler for [TQuery].
abstract interface class QueryHandler<TResponse extends Object,
        TQuery extends Query<TResponse>>
    implements RequestHandler<TResponse, TQuery> {}

@immutable
class _FunctionRequestHandler<TResponse, TRequest extends Request<TResponse>>
    implements RequestHandler<TResponse, TRequest> {
  final FutureOr<TResponse> Function(TRequest) handler;

  const _FunctionRequestHandler(this.handler);

  @override
  FutureOr<TResponse> handle(TRequest request) => handler(request);

  @override
  int get hashCode => Object.hash(runtimeType, handler);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _FunctionRequestHandler<TResponse, TRequest> &&
            other.handler == handler);
  }
}

@immutable
class _FactoryRequestHandler<TResponse, TRequest extends Request<TResponse>>
    implements RequestHandler<TResponse, TRequest> {
  final RequestHandlerFactory<TResponse, TRequest> factory;

  const _FactoryRequestHandler(this.factory);

  @override
  FutureOr<TResponse> handle(TRequest request) {
    final handler = factory();
    return handler.handle(request);
  }

  @override
  int get hashCode => Object.hash(runtimeType, factory);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _FactoryRequestHandler<TResponse, TRequest> &&
            other.factory == factory);
  }
}
