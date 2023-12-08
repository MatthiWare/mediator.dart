part of 'event_subscription_builder.dart';

class _DistinctEventSubscriptionBuilder<T> extends EventSubscriptionBuilder<T> {
  final EventSubscriptionBuilder<T> parent;
  final bool Function(T previous, T next) equals;

  _DistinctEventSubscriptionBuilder({
    required this.parent,
    required this.equals,
  });

  @override
  EventSubscription subscribe(EventHandler<T> handler) {
    return parent
        .subscribe(_DistinctEventHandler(parent: handler, equals: equals));
  }

  @override
  EventSubscription subscribeFactory(EventHandlerFactory<T> factory) {
    return parent.subscribeFactory(() {
      final handler = factory();
      return _DistinctEventHandler(parent: handler, equals: equals);
    });
  }
}

class _DistinctEventHandler<T> implements EventHandler<T> {
  static final _sentinel = Object();

  final EventHandler<T> parent;
  final bool Function(T previous, T next) equals;

  Object? _previous = _sentinel;

  _DistinctEventHandler({
    required this.parent,
    required this.equals,
  });

  @override
  FutureOr<void> handle(T event) {
    if (identical(_previous, _sentinel)) {
      _previous = event;
      // Skip first event.
      return parent.handle(event);
    }

    if (!equals(_previous as T, event)) {
      _previous = event;
      return parent.handle(event);
    }
  }
}
