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

  final forkedEventManager =
      (events.first as EventManagerProvider).eventManager.fork();

  final builder = _MergeEventSubscriptionBuilder<WrappedEvent<R>, R>(
    parent: forkedEventManager.on<WrappedEvent<R>>(),
    fork: forkedEventManager,
    events: events,
  );

  return builder;
}

class _MergeEventSubscriptionBuilder<TWrapped extends WrappedEvent<T>, T>
    extends BaseEventSubscriptionBuilder<TWrapped, T> {
  final EventManager fork;
  final List<EventSubscriptionBuilder<T>> events;

  _MergeEventSubscriptionBuilder({
    required super.parent,
    required this.fork,
    required this.events,
  });

  @override
  EventHandler<TWrapped> createHandler(EventHandler<T> handler) {
    final returnedHandler = _MergeEventHandler<T, TWrapped>(parent: handler);

    Future<void> emit(T event) async {
      final result = WrappedEvent(event) as TWrapped;

      await returnedHandler.handle(result);
    }

    final subscriptions = events.map((eventBuilder) {
      return eventBuilder.subscribeFunction(emit);
    }).toList(growable: false);

    return returnedHandler;
  }
}

class _MergeEventHandler<T, R extends WrappedEvent<T>>
    implements EventHandler<R> {
  final EventHandler<T> parent;

  _MergeEventHandler({
    required this.parent,
  });

  @override
  FutureOr<void> handle(R event) {
    return parent.handle(event.unwrapped);
  }
}
