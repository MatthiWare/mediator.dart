import 'package:dart_mediator/event_manager.dart';
import 'package:dart_mediator/src/event/event_manager.dart';
import 'package:dart_mediator/src/event/interfaces/event_manager_provider.dart';
import 'package:dart_mediator/src/utils/sentinel.dart';

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

EventSubscriptionBuilder<R> combineLatest2<R, A, B>(
  EventSubscriptionBuilder<A> eventA,
  EventSubscriptionBuilder<B> eventB,
  R Function(A a, B b) combinator,
) {
  final eventManager = EventManager.create();

  Object? a = sentinel;
  Object? b = sentinel;

  final builder = eventManager.on<_WrappedR<R>>();

  Future<void> emit() async {
    if (identical(a, sentinel) || identical(b, sentinel)) {
      return;
    }

    final result = _WrappedR<R>(combinator(a as A, b as B));

    eventManager.dispatch(result);
  }

  final subA = eventA.subscribeFunction((event) async {
    a = event;

    await emit();
  });

  final subB = eventB.subscribeFunction((event) async {
    b = event;

    await emit();
  });

  return builder.map((wrapped) => wrapped.r);
}

class _WrappedR<R> implements DomainEvent {
  final R r;

  _WrappedR(this.r);
}
