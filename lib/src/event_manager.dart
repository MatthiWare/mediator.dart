import 'package:dart_event_manager/src/event_handler.dart';
import 'package:dart_event_manager/src/event_subscription.dart';

class EventManager {
  final _handlers = <Type, Set<EventHandler>>{};

  EventManager();

  /// Subscribes to a given [TEvent] using the [handler].
  EventSubscription subscribe<TEvent>(EventHandler<TEvent> handler) {
    final handlers = _getHandlersFor<TEvent>();

    assert(
      !handlers.contains(handler),
      'subscribe<$TEvent> was called with an already registered handler',
    );

    final subscription = EventSubscription(() => unsubscribe(handler));

    handlers.add(handler);

    return subscription;
  }

  /// Unsubscribes the given [handler].
  void unsubscribe<TEvent>(EventHandler<TEvent> handler) {
    final handlers = _getHandlersFor<TEvent>();

    assert(
      handlers.contains(handler),
      'unsubscribe<$TEvent> was called for a handler that was never subscribed to',
    );

    handlers.remove(handler);
  }

  /// Dispatches the given [event] to the registered [EventHandler]'s.
  Future<void> dispatch<TEvent>(TEvent event) async {
    final handlers = _getHandlersFor<TEvent>();

    assert(
      handlers.isNotEmpty,
      'dispatch<$TEvent> was invoked but no handlers are registered to handle this',
    );

    for (final handler in handlers) {
      await handler.handle(event);
    }
  }

  Set<EventHandler<TEvent>> _getHandlersFor<TEvent>() {
    final handlers = _handlers.putIfAbsent(
      TEvent,
      () => <EventHandler<TEvent>>{},
    ) as Set<EventHandler<TEvent>>;

    return handlers;
  }
}
