import 'dart:collection';

import 'package:dart_mediator/src/event/handler/event_handler.dart';

class EventHandlerStore {
  final _handlers = <Type, Set<EventHandler>>{};

  /// Registers the [handler] to a given [TEvent].
  void register<TEvent>(EventHandler<TEvent> handler) {
    final handlers = _getHandlersFor(TEvent);

    assert(
      !handlers.contains(handler),
      'register<$TEvent> was called with an already registered handler',
    );

    // When the store is being modified, create a new copy.
    _handlers[TEvent] = <EventHandler>{
      ...handlers,
      handler,
    };
  }

  /// Unregisters the given [handler].
  void unregister<TEvent>(EventHandler<TEvent> handler) {
    final handlers = _getHandlersFor(TEvent);

    assert(
      handlers.contains(handler),
      'unregister<$TEvent> was called for a handler that was never registered',
    );

    // When the store is being modified, create a new copy.
    final update = handlers.toSet()..remove(handler);

    _handlers[TEvent] = update;
  }

  /// Returns all registered [EventHandler]'s for [eventType].
  Set<EventHandler> getHandlersFor(Type eventType) {
    final handlers = _getHandlersFor(eventType);

    return UnmodifiableSetView(handlers);
  }

  Set<EventHandler> _getHandlersFor(Type eventType) {
    final handlers = _handlers.putIfAbsent(
      eventType,
      () => <EventHandler>{},
    );

    return handlers;
  }
}
