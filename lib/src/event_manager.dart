import 'dart:async';

import 'package:dart_event_manager/src/dispatch_strategy.dart';
import 'package:dart_event_manager/src/event_handler/event_handler.dart';
import 'package:dart_event_manager/src/event_handler/event_handler_store.dart';
import 'package:dart_event_manager/src/event_subscription_builder.dart';
import 'package:dart_event_manager/src/request_handler/request_handler_store.dart';

class EventManager {
  final EventHandlerStore _eventHandlerStore;
  final RequestHandlerStore _requestHandlerStore;
  final DispatchStrategy _defaultDispatchStrategy;

  EventManager(
    this._eventHandlerStore,
    this._requestHandlerStore,
    this._defaultDispatchStrategy,
  );

  Future<TResponse> send<TResponse, TRequest>(TRequest request) async {
    final handler = _requestHandlerStore.getHandlerFor<TResponse, TRequest>();

    return await handler.handle(request);
  }

  /// Subscribe on the given [T] event.
  ///
  /// Returns a [EventSubscriptionBuilder] that allows to build a specific
  /// subscription.
  EventSubscriptionBuilder<T> on<T>() =>
      EventSubscriptionBuilder.create(_eventHandlerStore);

  /// Dispatches the given [event] to the registered [EventHandler]'s.
  Future<void> dispatch<TEvent>(
    TEvent event, [
    DispatchStrategy? dispatchStrategy,
  ]) async {
    final handlers = _eventHandlerStore.getHandlersFor<TEvent>();

    assert(
      handlers.isNotEmpty,
      'dispatch<$TEvent> was invoked but no handlers are registered to handle this',
    );

    await (dispatchStrategy ?? _defaultDispatchStrategy)
        .execute(handlers, event);
  }
}
