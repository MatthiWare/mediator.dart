import 'dart:async';

import 'package:dart_mediator/event_manager.dart';
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

  @override
  EventSubscription subscribe(EventHandler<R> handler) {
    final zipHandler = _ZipEventHandler(handler, events, zipper);
    final subscriptions = zipHandler.subscribe();

    return EventSubscription(() {
      for (final sub in subscriptions) {
        sub.cancel();
      }
    });
  }
}

class _ZipEventHandler<R> implements EventHandler<R> {
  final EventHandler<R> parent;
  final List<EventSubscriptionBuilder<dynamic>> events;
  final R Function(List<dynamic> events) zipper;
  late final lastValues = List<Object?>.filled(events.length, sentinel);
  late final emittedHandlersList = List<bool>.filled(events.length, false);

  _ZipEventHandler(
    this.parent,
    this.events,
    this.zipper,
  );

  @override
  FutureOr<void> handle(R event) {
    return parent.handle(event);
  }

  void reset() {
    for (var i = 0; i < events.length; i++) {
      lastValues[i] = sentinel;
      emittedHandlersList[i] = false;
    }
  }

  Future<void> handleEvent(dynamic event, int index) async {
    emittedHandlersList[index] = true;
    lastValues[index] = event;

    final allHandlersEmitted = emittedHandlersList.every((emitted) => emitted);

    if (!allHandlersEmitted) {
      return;
    }

    final result = zipper(lastValues);

    reset();

    await handle(result);
  }

  List<EventSubscription> subscribe() {
    final subscriptions = events.indexed.map((e) {
      final index = e.$1;
      final eventBuilder = e.$2;

      final internalSubscription = eventBuilder.subscribeFunction(
        (e) => handleEvent(e, index),
      );

      return internalSubscription;
    }).toList(growable: false);

    return subscriptions;
  }
}
