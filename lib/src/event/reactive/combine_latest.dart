import 'dart:async';

import 'package:dart_mediator/event_manager.dart';
import 'package:dart_mediator/src/event/interfaces/event_manager_provider.dart';
import 'package:dart_mediator/src/event/reactive/utils/asserts.dart';
import 'package:dart_mediator/src/event/reactive/utils/wrapped_event.dart';
import 'package:dart_mediator/src/utils/sentinel.dart';

EventSubscriptionBuilder<R> combineLatest<R>(
  List<EventSubscriptionBuilder<dynamic>> events,
  R Function(List<dynamic> events) combinator,
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

  final builder = _CombineLatestEventSubscriptionBuilder<R>(
    combinator: combinator,
    events: events,
  );

  return builder;
}

EventSubscriptionBuilder<R> combineLatest2<R, A, B>(
  EventSubscriptionBuilder<A> eventA,
  EventSubscriptionBuilder<B> eventB,
  R Function(A a, B b) combinator,
) {
  return combineLatest(
    [eventA, eventB],
    (values) {
      final a = values[0] as A;
      final b = values[1] as B;

      return combinator(a, b);
    },
  );
}

class _CombineLatestEventSubscriptionBuilder<T>
    extends EventSubscriptionBuilder<T> {
  final List<EventSubscriptionBuilder<dynamic>> events;
  final T Function(List<dynamic> events) combinator;

  _CombineLatestEventSubscriptionBuilder({
    required this.events,
    required this.combinator,
  });

  List<EventSubscription> _subscribeToEvents(EventHandler<T> handler) {
    final lastValues = List<Object?>.filled(events.length, sentinel);
    final emittedHandlersList = List<bool>.filled(events.length, false);

    bool allHandlersEmitted = false;

    Future<void> emit() async {
      if (!allHandlersEmitted) {
        allHandlersEmitted = !emittedHandlersList.any((x) => x == false);

        if (!allHandlersEmitted) {
          return;
        }
      }

      final result = combinator(lastValues);

      await handler.handle(result);
    }

    final subscriptions = events.indexed.map((e) {
      final index = e.$1;
      final eventBuilder = e.$2;

      bool firstEvent = true;

      final internalSubscription = eventBuilder
          .map((e) => e as dynamic)
          .subscribeFunction((event) async {
        if (firstEvent) {
          firstEvent = false;
          emittedHandlersList[index] = true;
        }

        lastValues[index] = event;

        await emit();
      });

      return internalSubscription;
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
