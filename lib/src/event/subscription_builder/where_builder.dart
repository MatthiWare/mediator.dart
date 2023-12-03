part of 'event_subscription_builder.dart';

class _WhereEventSubscriptionBuilder<T> extends EventSubscriptionBuilder<T> {
  final EventSubscriptionBuilder<T> parent;
  final bool Function(T event) test;

  _WhereEventSubscriptionBuilder({
    required this.parent,
    required this.test,
  });

  @override
  EventSubscription subscribe(EventHandler<T> handler) {
    return parent.subscribe(
      _WhereEventHandler(parent: handler, where: test),
    );
  }
}

class _WhereEventHandler<T> implements EventHandler<T> {
  final EventHandler<T> parent;
  final bool Function(T event) where;

  _WhereEventHandler({
    required this.parent,
    required this.where,
  });

  @override
  FutureOr<void> handle(T event) {
    if (where(event)) {
      return parent.handle(event);
    }
  }
}
