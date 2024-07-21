import 'dart:async';

import 'package:dart_mediator/event_manager.dart';
import 'package:dart_mediator/src/event/reactive/utils/asserts.dart';
import 'package:dart_mediator/src/utils/sentinel.dart';

EventSubscriptionBuilder<R> zip<R>(
  List<EventSubscriptionBuilder<dynamic>> events,
  R Function(List<dynamic> events) zipper,
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

  final builder = _ZipEventSubscriptionBuilder<R>(
    zipper: zipper,
    events: events,
  );

  return builder;
}

EventSubscriptionBuilder<R> zip2<R, A, B>(
  EventSubscriptionBuilder<A> eventA,
  EventSubscriptionBuilder<B> eventB,
  R Function(A a, B b) zipper,
) {
  return zip(
    [eventA, eventB],
    (values) {
      final a = values[0] as A;
      final b = values[1] as B;

      return zipper(a, b);
    },
  );
}

class _ZipEventSubscriptionBuilder<R> extends EventSubscriptionBuilder<R> {
  final List<EventSubscriptionBuilder<dynamic>> events;
  final R Function(List<dynamic> events) zipper;

  _ZipEventSubscriptionBuilder({
    required this.events,
    required this.zipper,
  });

  List<EventSubscription> _subscribeToEvents(EventHandler<R> handler) {
    final lastValues = List<Object?>.filled(events.length, sentinel);
    final emittedHandlersList = List<bool>.filled(events.length, false);

    bool allHandlersEmitted = false;

    void reset() {
      allHandlersEmitted = false;
      for (var i = 0; i < events.length; i++) {
        lastValues[i] = sentinel;
        emittedHandlersList[i] = false;
      }
    }

    Future<void> emit() async {
      if (!allHandlersEmitted) {
        allHandlersEmitted = !emittedHandlersList.any((x) => x == false);

        if (!allHandlersEmitted) {
          return;
        }
      }

      final result = zipper(lastValues);

      reset();

      await handler.handle(result);
    }

    final subscriptions = events.indexed.map((e) {
      final index = e.$1;
      final eventBuilder = e.$2;

      final internalSubscription = eventBuilder
          .map((e) => e as dynamic)
          .subscribeFunction((event) async {
        emittedHandlersList[index] = true;
        lastValues[index] = event;

        await emit();
      });

      return internalSubscription;
    }).toList(growable: false);

    return subscriptions;
  }

  @override
  EventSubscription subscribe(EventHandler<R> handler) {
    final subscriptions = _subscribeToEvents(handler);

    return EventSubscription(() {
      for (final sub in subscriptions) {
        sub.cancel();
      }
    });
  }
}
