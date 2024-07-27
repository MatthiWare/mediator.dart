import 'dart:async';

import 'package:dart_mediator/event_manager.dart';
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

  @override
  EventSubscription subscribe(EventHandler<T> handler) {
    final combineLatestEventHandler = _CombineLatestEventHandler(
      handler,
      events,
      combinator,
    );
    final subscriptions = combineLatestEventHandler.subscribe();

    return EventSubscription(() {
      for (final sub in subscriptions) {
        sub.cancel();
      }
    });
  }
}

class _CombineLatestEventHandler<T> implements EventHandler<T> {
  final EventHandler<T> parent;
  final List<EventSubscriptionBuilder<dynamic>> events;
  final T Function(List<dynamic> events) combinator;
  late final lastValues = List<Object?>.filled(events.length, sentinel);
  late final emittedHandlersList = List<bool>.filled(events.length, false);
  bool allHandlersEmitted = false;

  _CombineLatestEventHandler(this.parent, this.events, this.combinator);

  @override
  FutureOr<void> handle(T event) => parent.handle(event);

  Future<void> handleEvent(dynamic event, int index, bool first) async {
    if (first) {
      emittedHandlersList[index] = true;
    }

    lastValues[index] = event;

    if (!allHandlersEmitted) {
      allHandlersEmitted = !emittedHandlersList.any((x) => x == false);

      if (!allHandlersEmitted) {
        return;
      }
    }

    final result = combinator(lastValues);

    await handle(result);
  }

  List<EventSubscription> subscribe() {
    final subscriptions = events.indexed.map((e) {
      final index = e.$1;
      final eventBuilder = e.$2;

      bool firstEvent = true;

      final internalSubscription =
          eventBuilder.subscribeFunction((event) async {
        await handleEvent(event, index, firstEvent);

        if (firstEvent) {
          firstEvent = false;
        }
      });

      return internalSubscription;
    }).toList(growable: false);

    return subscriptions;
  }
}
