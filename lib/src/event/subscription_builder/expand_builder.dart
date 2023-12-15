part of 'event_subscription_builder.dart';

class _ExpandEventSubscriptionBuilder<T>
    extends BaseEventSubscriptionBuilder<T, T> {
  final Iterable<T> Function(T element) convert;

  _ExpandEventSubscriptionBuilder({
    required super.parent,
    required this.convert,
  });

  @override
  EventHandler<T> createHandler(EventHandler<T> handler) {
    return _ExpandEventHandler(parent: handler, expand: convert);
  }
}

class _ExpandEventHandler<T> implements EventHandler<T> {
  final EventHandler<T> parent;
  final Iterable<T> Function(T element) expand;

  _ExpandEventHandler({
    required this.parent,
    required this.expand,
  });

  @override
  Future<void> handle(T event) async {
    for (final element in expand(event)) {
      await parent.handle(element);
    }
  }
}

class _AsyncExpandEventSubscriptionBuilder<T>
    extends BaseEventSubscriptionBuilder<T, T> {
  final Stream<T> Function(T element) convert;

  _AsyncExpandEventSubscriptionBuilder({
    required super.parent,
    required this.convert,
  });

  @override
  EventHandler<T> createHandler(EventHandler<T> handler) {
    return _AsyncExpandEventHandler(parent: handler, expand: convert);
  }
}

class _AsyncExpandEventHandler<T> implements EventHandler<T> {
  final EventHandler<T> parent;
  final Stream<T> Function(T element) expand;

  _AsyncExpandEventHandler({
    required this.parent,
    required this.expand,
  });

  @override
  FutureOr<void> handle(T event) async {
    await for (final element in expand(event)) {
      await parent.handle(element);
    }
  }
}
