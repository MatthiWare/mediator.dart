import 'dart:async';

import 'package:dart_mediator/event_manager.dart';
import 'package:dart_mediator/src/utils/sentinel.dart';

/// Combines the latest items emitted by the given [events] into a single
/// [EventHandler] using the [combinator] function.
///
/// [Interactive marble diagram](http://rxmarbles.com/#combineLatest)
///
/// Consider using the typed version [combineLatest2] - [combineLatest9].
///
/// ### Example
///
/// ```dart
/// combineLatest(
///  [
///    eventManager.on<EventA>(), // emits ['a']
///    eventManager.on<EventB>(), // emits ['b']
///    eventManager.on<EventC>(), // emits ['c', 'C']
///  ],
///  (values) => values.join(' '),
/// ).subscribeFunction(print); // prints ['a b c', 'a b C']
/// ```
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

/// Combines the latest values of each provided event using the [combinator]
/// into a single output [EventHandler].
///
/// See [combineLatest].
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

/// Combines the latest values of each provided event using the [combinator]
/// into a single output [EventHandler].
///
/// See [combineLatest].
EventSubscriptionBuilder<R> combineLatest3<R, A, B, C>(
  EventSubscriptionBuilder<A> eventA,
  EventSubscriptionBuilder<B> eventB,
  EventSubscriptionBuilder<C> eventC,
  R Function(A a, B b, C c) combinator,
) {
  return combineLatest(
    [eventA, eventB, eventC],
    (values) {
      final a = values[0] as A;
      final b = values[1] as B;
      final c = values[2] as C;

      return combinator(a, b, c);
    },
  );
}

/// Combines the latest values of each provided event using the [combinator]
/// into a single output [EventHandler].
///
/// See [combineLatest].
EventSubscriptionBuilder<R> combineLatest4<R, A, B, C, D>(
  EventSubscriptionBuilder<A> eventA,
  EventSubscriptionBuilder<B> eventB,
  EventSubscriptionBuilder<C> eventC,
  EventSubscriptionBuilder<D> eventD,
  R Function(A a, B b, C c, D d) combinator,
) {
  return combineLatest(
    [eventA, eventB, eventC, eventD],
    (values) {
      final a = values[0] as A;
      final b = values[1] as B;
      final c = values[2] as C;
      final d = values[3] as D;

      return combinator(a, b, c, d);
    },
  );
}

/// Combines the latest values of each provided event using the [combinator]
/// into a single output [EventHandler].
///
/// See [combineLatest].
EventSubscriptionBuilder<R> combineLatest5<R, A, B, C, D, E>(
  EventSubscriptionBuilder<A> eventA,
  EventSubscriptionBuilder<B> eventB,
  EventSubscriptionBuilder<C> eventC,
  EventSubscriptionBuilder<D> eventD,
  EventSubscriptionBuilder<E> eventE,
  R Function(A a, B b, C c, D d, E e) combinator,
) {
  return combineLatest(
    [eventA, eventB, eventC, eventD, eventE],
    (values) {
      final a = values[0] as A;
      final b = values[1] as B;
      final c = values[2] as C;
      final d = values[3] as D;
      final e = values[4] as E;

      return combinator(a, b, c, d, e);
    },
  );
}

/// Combines the latest values of each provided event using the [combinator]
/// into a single output [EventHandler].
///
/// See [combineLatest].
EventSubscriptionBuilder<R> combineLatest6<R, A, B, C, D, E, F>(
  EventSubscriptionBuilder<A> eventA,
  EventSubscriptionBuilder<B> eventB,
  EventSubscriptionBuilder<C> eventC,
  EventSubscriptionBuilder<D> eventD,
  EventSubscriptionBuilder<E> eventE,
  EventSubscriptionBuilder<F> eventF,
  R Function(A a, B b, C c, D d, E e, F f) combinator,
) {
  return combineLatest(
    [eventA, eventB, eventC, eventD, eventE, eventF],
    (values) {
      final a = values[0] as A;
      final b = values[1] as B;
      final c = values[2] as C;
      final d = values[3] as D;
      final e = values[4] as E;
      final f = values[5] as F;

      return combinator(a, b, c, d, e, f);
    },
  );
}

/// Combines the latest values of each provided event using the [combinator]
/// into a single output [EventHandler].
///
/// See [combineLatest].
EventSubscriptionBuilder<R> combineLatest7<R, A, B, C, D, E, F, G>(
  EventSubscriptionBuilder<A> eventA,
  EventSubscriptionBuilder<B> eventB,
  EventSubscriptionBuilder<C> eventC,
  EventSubscriptionBuilder<D> eventD,
  EventSubscriptionBuilder<E> eventE,
  EventSubscriptionBuilder<F> eventF,
  EventSubscriptionBuilder<G> eventG,
  R Function(A a, B b, C c, D d, E e, F f, G g) combinator,
) {
  return combineLatest(
    [eventA, eventB, eventC, eventD, eventE, eventF, eventG],
    (values) {
      final a = values[0] as A;
      final b = values[1] as B;
      final c = values[2] as C;
      final d = values[3] as D;
      final e = values[4] as E;
      final f = values[5] as F;
      final g = values[6] as G;

      return combinator(a, b, c, d, e, f, g);
    },
  );
}

/// Combines the latest values of each provided event using the [combinator]
/// into a single output [EventHandler].
///
/// See [combineLatest].
EventSubscriptionBuilder<R> combineLatest8<R, A, B, C, D, E, F, G, H>(
  EventSubscriptionBuilder<A> eventA,
  EventSubscriptionBuilder<B> eventB,
  EventSubscriptionBuilder<C> eventC,
  EventSubscriptionBuilder<D> eventD,
  EventSubscriptionBuilder<E> eventE,
  EventSubscriptionBuilder<F> eventF,
  EventSubscriptionBuilder<G> eventG,
  EventSubscriptionBuilder<H> eventH,
  R Function(A a, B b, C c, D d, E e, F f, G g, H h) combinator,
) {
  return combineLatest(
    [eventA, eventB, eventC, eventD, eventE, eventF, eventG, eventH],
    (values) {
      final a = values[0] as A;
      final b = values[1] as B;
      final c = values[2] as C;
      final d = values[3] as D;
      final e = values[4] as E;
      final f = values[5] as F;
      final g = values[6] as G;
      final h = values[7] as H;

      return combinator(a, b, c, d, e, f, g, h);
    },
  );
}

/// Combines the latest values of each provided event using the [combinator]
/// into a single output [EventHandler].
///
/// See [combineLatest].
EventSubscriptionBuilder<R> combineLatest9<R, A, B, C, D, E, F, G, H, I>(
  EventSubscriptionBuilder<A> eventA,
  EventSubscriptionBuilder<B> eventB,
  EventSubscriptionBuilder<C> eventC,
  EventSubscriptionBuilder<D> eventD,
  EventSubscriptionBuilder<E> eventE,
  EventSubscriptionBuilder<F> eventF,
  EventSubscriptionBuilder<G> eventG,
  EventSubscriptionBuilder<H> eventH,
  EventSubscriptionBuilder<I> eventI,
  R Function(A a, B b, C c, D d, E e, F f, G g, H h, I i) combinator,
) {
  return combineLatest(
    [eventA, eventB, eventC, eventD, eventE, eventF, eventG, eventH, eventI],
    (values) {
      final a = values[0] as A;
      final b = values[1] as B;
      final c = values[2] as C;
      final d = values[3] as D;
      final e = values[4] as E;
      final f = values[5] as F;
      final g = values[6] as G;
      final h = values[7] as H;
      final i = values[8] as I;

      return combinator(a, b, c, d, e, f, g, h, i);
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
          eventBuilder.cast<dynamic>().subscribeFunction((event) async {
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
