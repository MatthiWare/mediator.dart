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

  final forkedEventManager =
      (events.first as EventManagerProvider).eventManager.fork();

  final builder = _CombineLatestEventSubscriptionBuilder<WrappedEvent<R>, R>(
    parent: forkedEventManager.on<WrappedEvent<R>>(),
    fork: forkedEventManager,
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

class _CombineLatestEventSubscriptionBuilder<TWrapped extends WrappedEvent<T>,
    T> extends BaseEventSubscriptionBuilder<TWrapped, T> {
  final EventManager fork;
  final List<EventSubscriptionBuilder<dynamic>> events;
  final T Function(List<dynamic> events) combinator;

  _CombineLatestEventSubscriptionBuilder({
    required super.parent,
    required this.fork,
    required this.events,
    required this.combinator,
  });

  @override
  EventHandler<TWrapped> createHandler(EventHandler<T> handler) {
    final lastValues = List<Object?>.filled(events.length, sentinel);
    final emittedHandlersList = List<bool>.filled(events.length, false);

    bool allHandlersEmitted = false;

    final returnedHandler =
        _CombineLatestEventHandler<T, TWrapped>(parent: handler);

    Future<void> emit() async {
      if (!allHandlersEmitted) {
        allHandlersEmitted = !emittedHandlersList.any((x) => x == false);

        if (!allHandlersEmitted) {
          return;
        }
      }

      final result = WrappedEvent(combinator(lastValues)) as TWrapped;

      await returnedHandler.handle(result);
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

    return returnedHandler;
  }
}

class _CombineLatestEventHandler<T, R extends WrappedEvent<T>>
    implements EventHandler<R> {
  final EventHandler<T> parent;

  _CombineLatestEventHandler({
    required this.parent,
  });

  @override
  FutureOr<void> handle(R event) {
    return parent.handle(event.unwrapped);
  }
}
