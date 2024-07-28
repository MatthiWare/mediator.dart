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

EventSubscriptionBuilder<R> zip3<R, A, B, C>(
  EventSubscriptionBuilder<A> eventA,
  EventSubscriptionBuilder<B> eventB,
  EventSubscriptionBuilder<C> eventC,
  R Function(A a, B b, C c) zipper,
) {
  return zip(
    [eventA, eventB, eventC],
    (values) {
      final a = values[0] as A;
      final b = values[1] as B;
      final c = values[2] as C;

      return zipper(a, b, c);
    },
  );
}

EventSubscriptionBuilder<R> zip4<R, A, B, C, D>(
  EventSubscriptionBuilder<A> eventA,
  EventSubscriptionBuilder<B> eventB,
  EventSubscriptionBuilder<C> eventC,
  EventSubscriptionBuilder<D> eventD,
  R Function(A a, B b, C c, D d) zipper,
) {
  return zip(
    [eventA, eventB, eventC, eventD],
    (values) {
      final a = values[0] as A;
      final b = values[1] as B;
      final c = values[2] as C;
      final d = values[3] as D;

      return zipper(a, b, c, d);
    },
  );
}

EventSubscriptionBuilder<R> zip5<R, A, B, C, D, E>(
  EventSubscriptionBuilder<A> eventA,
  EventSubscriptionBuilder<B> eventB,
  EventSubscriptionBuilder<C> eventC,
  EventSubscriptionBuilder<D> eventD,
  EventSubscriptionBuilder<E> eventE,
  R Function(A a, B b, C c, D d, E e) zipper,
) {
  return zip(
    [eventA, eventB, eventC, eventD, eventE],
    (values) {
      final a = values[0] as A;
      final b = values[1] as B;
      final c = values[2] as C;
      final d = values[3] as D;
      final e = values[4] as E;

      return zipper(a, b, c, d, e);
    },
  );
}

EventSubscriptionBuilder<R> zip6<R, A, B, C, D, E, F>(
  EventSubscriptionBuilder<A> eventA,
  EventSubscriptionBuilder<B> eventB,
  EventSubscriptionBuilder<C> eventC,
  EventSubscriptionBuilder<D> eventD,
  EventSubscriptionBuilder<E> eventE,
  EventSubscriptionBuilder<F> eventF,
  R Function(A a, B b, C c, D d, E e, F f) zipper,
) {
  return zip(
    [eventA, eventB, eventC, eventD, eventE, eventF],
    (values) {
      final a = values[0] as A;
      final b = values[1] as B;
      final c = values[2] as C;
      final d = values[3] as D;
      final e = values[4] as E;
      final f = values[5] as F;

      return zipper(a, b, c, d, e, f);
    },
  );
}

EventSubscriptionBuilder<R> zip7<R, A, B, C, D, E, F, G>(
  EventSubscriptionBuilder<A> eventA,
  EventSubscriptionBuilder<B> eventB,
  EventSubscriptionBuilder<C> eventC,
  EventSubscriptionBuilder<D> eventD,
  EventSubscriptionBuilder<E> eventE,
  EventSubscriptionBuilder<F> eventF,
  EventSubscriptionBuilder<G> eventG,
  R Function(A a, B b, C c, D d, E e, F f, G g) zipper,
) {
  return zip(
    [eventA, eventB, eventC, eventD, eventE, eventF, eventG],
    (values) {
      final a = values[0] as A;
      final b = values[1] as B;
      final c = values[2] as C;
      final d = values[3] as D;
      final e = values[4] as E;
      final f = values[5] as F;
      final g = values[6] as G;

      return zipper(a, b, c, d, e, f, g);
    },
  );
}

EventSubscriptionBuilder<R> zip8<R, A, B, C, D, E, F, G, H>(
  EventSubscriptionBuilder<A> eventA,
  EventSubscriptionBuilder<B> eventB,
  EventSubscriptionBuilder<C> eventC,
  EventSubscriptionBuilder<D> eventD,
  EventSubscriptionBuilder<E> eventE,
  EventSubscriptionBuilder<F> eventF,
  EventSubscriptionBuilder<G> eventG,
  EventSubscriptionBuilder<H> eventH,
  R Function(A a, B b, C c, D d, E e, F f, G g, H h) zipper,
) {
  return zip(
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

      return zipper(a, b, c, d, e, f, g, h);
    },
  );
}

EventSubscriptionBuilder<R> zip9<R, A, B, C, D, E, F, G, H, I>(
  EventSubscriptionBuilder<A> eventA,
  EventSubscriptionBuilder<B> eventB,
  EventSubscriptionBuilder<C> eventC,
  EventSubscriptionBuilder<D> eventD,
  EventSubscriptionBuilder<E> eventE,
  EventSubscriptionBuilder<F> eventF,
  EventSubscriptionBuilder<G> eventG,
  EventSubscriptionBuilder<H> eventH,
  EventSubscriptionBuilder<I> eventI,
  R Function(A a, B b, C c, D d, E e, F f, G g, H h, I i) zipper,
) {
  return zip(
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

      return zipper(a, b, c, d, e, f, g, h, i);
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

      final internalSubscription = eventBuilder
          .cast<dynamic>()
          .subscribeFunction((e) => handleEvent(e, index));

      return internalSubscription;
    }).toList(growable: false);

    return subscriptions;
  }
}
