import 'package:dart_mediator/src/request/request.dart';
import 'package:dart_mediator/src/request/handler/request_handler.dart';

class RequestHandlerStore {
  final _handlers = <Type, RequestHandler>{};
  final _handlerFactories = <Type, RequestHandlerFactory>{};

  /// Registers the [handler] to a given [TRequest].
  void register<TResponse, TRequest extends Request<TResponse>>(
    RequestHandler<TResponse, TRequest> handler,
  ) {
    assert(
      !_handlers.containsKey(TRequest),
      'register<$TResponse, $TRequest> was called with an already registered handler',
    );

    assert(
      !_handlerFactories.containsKey(TRequest),
      'register<$TRequest> was called with an already registered factory',
    );

    _handlers[TRequest] = handler;
  }

  /// Registers the [factory] to a given [TRequest].
  void registerFactory<TResponse, TRequest extends Request<TResponse>>(
    RequestHandlerFactory<TResponse, TRequest> factory,
  ) {
    assert(
      !_handlers.containsKey(TRequest),
      'registerFactory<$TResponse, $TRequest> was called with an already registered handler',
    );

    assert(
      !_handlerFactories.containsKey(TRequest),
      'registerFactory<$TRequest> was called with an already registered factory',
    );

    _handlerFactories[TRequest] = factory;
  }

  /// Unregisters the given [handler].
  void unregister<TResponse, TRequest extends Request<TResponse>>(
    RequestHandler<TResponse, TRequest> handler,
  ) {
    assert(
      _handlers.containsKey(TRequest),
      'unregister<$TResponse, $TRequest> was called for a handler that was never subscribed to',
    );

    _handlers.remove(TRequest);
  }

  /// Returns the registered [RequestHandler]'s for [TRequest].
  RequestHandler<TResponse, TRequest>
      getHandlerFor<TResponse, TRequest extends Request<TResponse>>() {
    final handler = _handlers[TRequest] ?? _handlerFactories[TRequest]?.call();

    assert(
      handler != null,
      'getHandlerFor<$TResponse, $TRequest> did not have a registered handler. '
      'Make sure to register the request handler first.',
    );

    assert(
      handler is RequestHandler<TResponse, TRequest>,
      'The registered handler is of the wrong type got $handler but was '
      'expecting a type of RequestHandler<$TResponse, $TRequest>',
    );

    return handler as RequestHandler<TResponse, TRequest>;
  }
}
