part of '../event_subscription_builder.dart';

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
}

class _MapEventHandler<T, S> implements EventHandler<T> {
  final EventHandler<S> parent;
  final S Function(T event) mapper;

  _MapEventHandler({
    required this.parent,
    required this.mapper,
  });

  @override
  void handle(T event) {
    parent.handle(mapper(event));
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
    return parent.handle(await mapper(event));
  }
}
