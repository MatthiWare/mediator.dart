part of '../event_subscription_builder.dart';

class _SkipEventSubscriptionBuilder<T> extends EventSubscriptionBuilder<T> {
  final EventSubscriptionBuilder<T> parent;
  final int skips;

  _SkipEventSubscriptionBuilder({
    required this.parent,
    required this.skips,
  });

  @override
  EventSubscription subscribe(EventHandler<T> handler) {
    return parent.subscribe(_SkipEventHandler(parent: handler, skips: skips));
  }
}

class _SkipEventHandler<T> implements EventHandler<T> {
  int skipped = 0;

  final EventHandler<T> parent;
  final int skips;

  _SkipEventHandler({
    required this.parent,
    required this.skips,
  });

  @override
  FutureOr<void> handle(T event) {
    if (skipped >= skips) {
      return parent.handle(event);
    }

    skipped++;
  }
}
