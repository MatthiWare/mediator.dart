import 'dart:async';

import 'package:dart_event_manager/src/event_handler.dart';
import 'package:dart_event_manager/src/event_subscription_builder.dart';

class EventManager {
  final _handlers = <Type, Set<EventHandler>>{};

  EventManager();

  /// The events
  ///
  /// Returns a [EventSubscriptionBuilder] that allows to build a specific
  /// subscription for the given event.
  EventSubscriptionBuilder<T> on<T>() => EventSubscriptionBuilder.create(this);

  /// Subscribes to a given [TEvent] using the [handler].
  void subscribe<TEvent>(EventHandler<TEvent> handler) {
    final handlers = _getHandlersFor<TEvent>();

    assert(
      !handlers.contains(handler),
      'subscribe<$TEvent> was called with an already registered handler',
    );

    handlers.add(handler);
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
