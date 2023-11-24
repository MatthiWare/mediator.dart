import 'dart:async';

import 'package:dart_event_manager/event_manager.dart';

part 'event_subscription_builder/skip_builder.dart';
part 'event_subscription_builder/map_builder.dart';

/// Builder that is able to subscribe to the [EventManager].
///
/// This is a builder pattern that allows you to manipulate the [T] event
/// before it reaches the handler defined in either [subscribe] or [subscribeFunction].
///
/// To transform the events [map] can be used.
///
/// To filter the events [where] can be used.
abstract class EventSubscriptionBuilder<T> {
  EventSubscriptionBuilder();

  /// Creates a new [EventSubscriptionBuilder] this can be used to mutate
  /// the events before they reach the [EventHandler] using the builder pattern.
  factory EventSubscriptionBuilder.create(EventManager eventManager) =
      _EventSubscriptionBuilder;

  /// Transforms each event.
  ///
  /// It extends the current builder by converting the
  /// input [T] using the provided [mapper] function into
  /// output [S]. Only events of type [S] will reach the
  /// [EventHandler].
  EventSubscriptionBuilder<S> map<S>(S Function(T event) mapper) {
    return _MapEventSubscriptionBuilder(parent: this, mapper: mapper);
  }

  /// Filters the events
  ///
  /// It extends the current builder so that only inputs
  /// that pass the [where] clause will be kept for the [EventHandler].
  EventSubscriptionBuilder<T> where(bool Function(T event) where) {
    return _WhereEventSubscriptionBuilder(this, where);
  }

  /// Filters the events
  ///
  /// It extends the current builder so that only inputs
  /// that pass the [where] clause will be kept for the [EventHandler].
  EventSubscriptionBuilder<T> skip(int count) {
    return _SkipEventSubscriptionBuilder(parent: this, skips: count);
  }

  /// Subscribes to the given [handler].
  ///
  /// This finalizes the builder and applies all the steps
  /// before subscribing.
  EventSubscription subscribe(EventHandler<T> handler);
}

extension EventSubscriptionBuilderFunctionExtension<T>
    on EventSubscriptionBuilder<T> {
  /// Subscribes to the given [handler].
  ///
  /// This finalizes the builder and applies all the steps
  /// before subscribing.
  EventSubscription subscribeFunction(
    FutureOr<void> Function(T event) handler,
  ) {
    return subscribe(EventHandler.function(handler));
  }
}

class _EventSubscriptionBuilder<T> extends EventSubscriptionBuilder<T> {
  final EventManager _eventManager;

  _EventSubscriptionBuilder(this._eventManager);

  @override
  EventSubscription subscribe(EventHandler<T> handler) =>
      _eventManager.subscribe(handler);
}

class _WhereEventSubscriptionBuilder<T> extends EventSubscriptionBuilder<T> {
  final EventSubscriptionBuilder<T> _parent;
  final bool Function(T event) _where;

  _WhereEventSubscriptionBuilder(
    this._parent,
    this._where,
  );

  @override
  EventSubscription subscribe(EventHandler<T> handler) {
    return _parent.subscribe(
      EventHandler.function(
        (event) => _handleWhere(event, handler.handle),
      ),
    );
  }

  FutureOr<void> _handleWhere(
    T event,
    FutureOr<void> Function(T event) handler,
  ) {
    if (_where(event)) {
      return handler(event);
    }
  }
}
