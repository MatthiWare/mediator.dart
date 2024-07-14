import 'package:dart_mediator/event_manager.dart';

EventSubscriptionBuilder<R> combineLatest2<R, A, B>(
  EventSubscriptionBuilder<A> eventA,
  EventSubscriptionBuilder<B> eventB,
  R Function(A a, B b) combinator,
) {
  final eventManager = EventManager.create();

  final sentinel = Object();

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
