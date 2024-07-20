import 'dart:async';

import 'package:dart_mediator/event_manager.dart';
import 'package:dart_mediator/src/event/interfaces/event_manager_provider.dart';
import 'package:dart_mediator/src/event/reactive/utils/asserts.dart';
import 'package:dart_mediator/src/event/reactive/utils/wrapped_event.dart';

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

  assert(() {
    assertEventManagersTheSame(events);
    return true;
  }());

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

  List<EventSubscription> _subscribeToEvents(EventHandler<T> handler) {
    Future<void> emit(T event) async {
      await handler.handle(event);
    }

    final subscriptions = events.map((eventBuilder) {
      return eventBuilder.subscribeFunction(emit);
    }).toList(growable: false);

    return subscriptions;
  }

  @override
  EventSubscription subscribe(EventHandler<T> handler) {
    final subscriptions = _subscribeToEvents(handler);

    return EventSubscription(() {
      for (final sub in subscriptions) {
        sub.cancel();
      }
    });
  }
}
