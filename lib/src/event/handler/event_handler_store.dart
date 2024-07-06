import 'dart:collection';

import 'package:dart_mediator/src/event/handler/event_handler.dart';

class EventHandlerStore {
  final _handlers = <Type, Set<EventHandler>>{};

  /// Registers the [handler] to a given [TEvent].
  void register<TEvent>(EventHandler<TEvent> handler) {
    final handlers = _getHandlersFor<TEvent>();

    assert(
      !handlers.contains(handler),
      'register<$TEvent> was called with an already registered handler',
    );

    // When the store is being modified, create a new copy.
    _handlers[TEvent] = <EventHandler<TEvent>>{
      ...handlers,
      handler,
    };
  }

  /// Unregisters the given [handler].
  void unregister<TEvent>(EventHandler<TEvent> handler) {
    final handlers = _getHandlersFor<TEvent>();

    assert(
      handlers.contains(handler),
      'unregister<$TEvent> was called for a handler that was never registered',
    );

    // When the store is being modified, create a new copy.
    final update = handlers.toSet()..remove(handler);

    _handlers[TEvent] = update;
  }

  /// Returns all registered [EventHandler]'s for [TEvent].
  Set<EventHandler<TEvent>> getHandlersFor<TEvent>() {
    final handlers = _getHandlersFor<TEvent>();

    return UnmodifiableSetView(handlers);
  }

  Set<EventHandler<TEvent>> _getHandlersFor<TEvent>() {
    final handlers = _handlers.putIfAbsent(
      TEvent,
      () => <EventHandler<TEvent>>{},
    ) as Set<EventHandler<TEvent>>;

    return handlers;
  }
}
