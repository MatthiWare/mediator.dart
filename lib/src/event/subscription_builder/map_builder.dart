part of 'event_subscription_builder.dart';

class _MapEventSubscriptionBuilder<T, S> extends EventSubscriptionBuilder<S> {
  final EventSubscriptionBuilder<T> parent;
  final S Function(T event) mapper;

  _MapEventSubscriptionBuilder({
    required this.parent,
    required this.mapper,
  });

  @override
  EventSubscription subscribe(EventHandler<S> handler) {
    return parent.subscribe(_MapEventHandler(parent: handler, mapper: mapper));
  }

  @override
  EventSubscription subscribeFactory(EventHandlerFactory<S> factory) {
    return parent.subscribeFactory(() {
      final handler = factory();
      return _MapEventHandler(parent: handler, mapper: mapper);
    });
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
    extends EventSubscriptionBuilder<S> {
  final EventSubscriptionBuilder<T> parent;
  final Future<S> Function(T event) mapper;

  _AsyncMapEventSubscriptionBuilder({
    required this.parent,
    required this.mapper,
  });

  @override
  EventSubscription subscribe(EventHandler<S> handler) {
    return parent.subscribe(
      _AsyncMapEventHandler(parent: handler, mapper: mapper),
    );
  }

  @override
  EventSubscription subscribeFactory(EventHandlerFactory<S> factory) {
    return parent.subscribeFactory(() {
      final handler = factory();
      return _AsyncMapEventHandler(parent: handler, mapper: mapper);
    });
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
    return await parent.handle(await mapper(event));
  }
}
