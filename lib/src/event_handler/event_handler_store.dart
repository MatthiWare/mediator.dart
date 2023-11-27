import 'package:dart_event_manager/src/event_handler/event_handler.dart';

class EventHandlerStore {
  final _handlers = <Type, Set<EventHandler>>{};

  /// Registers the [handler] to a given [TEvent].
  void register<TEvent>(EventHandler<TEvent> handler) {
    final handlers = getHandlersFor<TEvent>();

    assert(
      !handlers.contains(handler),
      'register<$TEvent> was called with an already registered handler',
    );

    handlers.add(handler);
  }

  /// Unregisters the given [handler].
  void unregister<TEvent>(EventHandler<TEvent> handler) {
    final handlers = getHandlersFor<TEvent>();

    assert(
      handlers.contains(handler),
      'unregister<$TEvent> was called for a handler that was never subscribed to',
    );

    handlers.remove(handler);
  }

  /// Returns all registered [EventHandler]'s for [TEvent].
  Set<EventHandler<TEvent>> getHandlersFor<TEvent>() {
    final handlers = _handlers.putIfAbsent(
      TEvent,
      () => <EventHandler<TEvent>>{},
    ) as Set<EventHandler<TEvent>>;

    return handlers;
  }
}
