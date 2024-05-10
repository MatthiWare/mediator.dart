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

    handlers.add(handler);
  }

  /// Unregisters the given [handler].
  void unregister<TEvent>(EventHandler<TEvent> handler) {
    final handlers = _getHandlersFor<TEvent>();

    assert(
      handlers.contains(handler),
      'unregister<$TEvent> was called for a handler that was never registered',
    );

    handlers.remove(handler);
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
