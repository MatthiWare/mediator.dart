part of 'event_subscription_builder.dart';

class _DistinctEventSubscriptionBuilder<T>
    extends BaseEventSubscriptionBuilder<T, T> {
  final bool Function(T previous, T next) equals;

  _DistinctEventSubscriptionBuilder({
    required super.parent,
    required this.equals,
  });

  @override
  EventHandler<T> createHandler(EventHandler<T> handler) {
    return _DistinctEventHandler(parent: handler, equals: equals);
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
