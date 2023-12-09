part of 'event_subscription_builder.dart';

class _WhereEventSubscriptionBuilder<T>
    extends BaseEventSubscriptionBuilder<T, T> {
  final bool Function(T event) test;

  _WhereEventSubscriptionBuilder({
    required super.parent,
    required this.test,
  });

  @override
  EventHandler<T> createHandler(EventHandler<T> handler) {
    return _WhereEventHandler(parent: handler, where: test);
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
