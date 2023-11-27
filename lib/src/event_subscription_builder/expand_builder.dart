part of '../event_subscription_builder.dart';

class _ExpandEventSubscriptionBuilder<T> extends EventSubscriptionBuilder<T> {
  final EventSubscriptionBuilder<T> parent;
  final Iterable<T> Function(T element) convert;

  _ExpandEventSubscriptionBuilder({
    required this.parent,
    required this.convert,
  });

  @override
  EventSubscription subscribe(EventHandler<T> handler) {
    return parent.subscribe(
      _ExpandEventHandler(parent: handler, expand: convert),
    );
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
  FutureOr<void> handle(T event) async {
    for (final element in expand(event)) {
      await parent.handle(element);
    }
  }
}
