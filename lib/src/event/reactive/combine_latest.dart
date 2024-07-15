import 'dart:async';

import 'package:dart_mediator/event_manager.dart';
import 'package:dart_mediator/src/event/event_manager.dart';
import 'package:dart_mediator/src/event/interfaces/event_manager_provider.dart';
import 'package:dart_mediator/src/utils/sentinel.dart';
import 'package:meta/meta.dart';

void _assertEventManagersTheSame(List<EventSubscriptionBuilder> builders) {
  final eventManagers =
      builders.map((e) => (e as EventManagerProvider).eventManager).map((e) {
    if (e is EventManagerForked) {
      return e.parent;
    }

    return e;
  }).toList();

  if (eventManagers.isEmpty || eventManagers.length == 1) {
    return;
  }

  final first = eventManagers.first;

  for (final instance in eventManagers) {
    if (first != instance) {
      throw StateError(
        'The provided event subscriptions are not created from the '
        'same `EventManager` instance. \n\n'
        '$instance differs from $first.',
      );
    }
  }
}

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
    _assertEventManagersTheSame(events);
    return true;
  }());

  final forkedEventManager =
      (events.first as EventManagerProvider).eventManager.fork();

  final builder = _CombineLatestEventSubscriptionBuilder<_WrappedR<R>, R>(
    parent: forkedEventManager
        .on<_WrappedR<R>>()
        .map((wrapped) => wrapped.unwrapped),
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

@immutable
class _WrappedR<R> implements DomainEvent {
  final R unwrapped;

  const _WrappedR(this.unwrapped);

  @override
  int get hashCode => Object.hash(runtimeType, unwrapped);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _WrappedR<R> &&
            other.unwrapped == unwrapped);
  }
}

class _CombineLatestEventSubscriptionBuilder<TWrapped, T>
    extends BaseEventSubscriptionBuilder<T, T> {
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
  EventHandler<T> createHandler(EventHandler<T> handler) {
    final lastValues = List<Object?>.filled(events.length, sentinel);
    final emittedHandlersList = List<bool>.filled(events.length, false);

    bool allHandlersEmitted = false;

    final returnedHandler = _CombineLatestEventHandler(parent: handler);

    Future<void> emit() async {
      if (!allHandlersEmitted) {
        allHandlersEmitted = !emittedHandlersList.any((x) => x == false);

        if (!allHandlersEmitted) {
          return;
        }
      }

      final result = combinator(lastValues);

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

class _CombineLatestEventHandler<T> implements EventHandler<T> {
  final EventHandler<T> parent;

  _CombineLatestEventHandler({
    required this.parent,
  });

  @override
  FutureOr<void> handle(T event) {
    return parent.handle(event);
  }
}
