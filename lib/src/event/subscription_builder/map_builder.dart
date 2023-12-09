part of 'event_subscription_builder.dart';

class _MapEventSubscriptionBuilder<T, S>
    extends BaseEventSubscriptionBuilder<T, S> {
  final S Function(T event) mapper;

  _MapEventSubscriptionBuilder({
    required super.parent,
    required this.mapper,
  });

  @override
  EventHandler<T> createHandler(EventHandler<S> handler) {
    return _MapEventHandler(parent: handler, mapper: mapper);
  }
}

class _MapEventHandler<T, S> implements EventHandler<T> {
  final EventHandler<S> parent;
  final S Function(T event) mapper;

  _MapEventHandler({
    required this.parent,
    required this.mapper,
  });

  @override
  FutureOr<void> handle(T event) {
    return parent.handle(mapper(event));
  }
}

class _AsyncMapEventSubscriptionBuilder<T, S>
    extends BaseEventSubscriptionBuilder<T, S> {
  final Future<S> Function(T event) mapper;

  _AsyncMapEventSubscriptionBuilder({
    required super.parent,
    required this.mapper,
  });

  @override
  EventHandler<T> createHandler(EventHandler<S> handler) {
    return _AsyncMapEventHandler(parent: handler, mapper: mapper);
  }
}

class _AsyncMapEventHandler<T, S> implements EventHandler<T> {
  final EventHandler<S> parent;
  final Future<S> Function(T event) mapper;

  _AsyncMapEventHandler({
    required this.parent,
    required this.mapper,
  });

  @override
  Future<void> handle(T event) async {
    await parent.handle(await mapper(event));
  }
}
