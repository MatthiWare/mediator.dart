import 'dart:async';

import 'package:dart_mediator/event_manager.dart';

EventSubscriptionBuilder<R> merge<R>(
  List<EventSubscriptionBuilder<R>> events,
) {
  if (events.isEmpty) {
    throw ArgumentError.value(
      events,
      'events',
      'Cannot be empty',
    );
  }

  final builder = _MergeEventSubscriptionBuilder<R>(
    events: events,
  );

  return builder;
}

class _MergeEventSubscriptionBuilder<T> extends EventSubscriptionBuilder<T> {
  final List<EventSubscriptionBuilder<T>> events;

  _MergeEventSubscriptionBuilder({
    required this.events,
  });

  @override
  EventSubscription subscribe(EventHandler<T> handler) {
    final mergeEventHandler = _MergeEventHandler(handler, events);
    final subscriptions = mergeEventHandler.subscribe();

    return EventSubscription(() {
      for (final sub in subscriptions) {
        sub.cancel();
      }
    });
  }
}

class _MergeEventHandler<T> implements EventHandler<T> {
  final EventHandler<T> parent;
  final List<EventSubscriptionBuilder<T>> events;

  _MergeEventHandler(
    this.parent,
    this.events,
  );

  List<EventSubscription> subscribe() {
    final subscriptions = events.map((eventBuilder) {
      return eventBuilder.subscribeFunction(handle);
    }).toList(growable: false);

    return subscriptions;
  }

  @override
  FutureOr<void> handle(T event) => parent.handle(event);
}
