import 'dart:async';

import 'package:dart_event_manager/src/event_handler/event_handler.dart';
import 'package:dart_event_manager/src/event_handler/event_handler_store.dart';
import 'package:dart_event_manager/src/event_subscription_builder.dart';

class EventManager {
  final EventHandlerStore _store;

  EventManager(this._store);

  /// Subscribe on the given [T] event.
  ///
  /// Returns a [EventSubscriptionBuilder] that allows to build a specific
  /// subscription.
  EventSubscriptionBuilder<T> on<T>() =>
      EventSubscriptionBuilder.create(_store);

  /// Dispatches the given [event] to the registered [EventHandler]'s.
  Future<void> dispatch<TEvent>(TEvent event) async {
    final handlers = _store.getHandlersFor<TEvent>();

    assert(
      handlers.isNotEmpty,
      'dispatch<$TEvent> was invoked but no handlers are registered to handle this',
    );

    for (final handler in handlers) {
      await handler.handle(event);
    }
  }
}
