import 'package:dart_event_manager/src/request/request.dart';
import 'package:dart_event_manager/src/request/handler/request_handler.dart';

class RequestHandlerStore {
  final _handlers = <Type, RequestHandler>{};

  /// Registers the [handler] to a given [TEvent].
  void register<TResponse, TRequest extends Request<TResponse>>(
    RequestHandler<TResponse, TRequest> handler,
  ) {
    assert(
      !_handlers.containsKey(TRequest),
      'register<$TResponse, $TRequest> was called with an already registered handler',
    );

    _handlers[TRequest] = handler;
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
    final handler = _handlers[TRequest];

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
