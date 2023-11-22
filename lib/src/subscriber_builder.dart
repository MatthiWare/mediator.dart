import 'dart:async';

import 'package:dart_event_manager/event_manager.dart';

/// Builder that is able to subscribe to the [EventManager].
///
/// This is a builder pattern that allows you to manipulate the [T] event
/// before it reaches the handler defined in either [subscribe] or [subscribeFunction].
///
/// To transform the events [map] can be used.
///
/// To filter the events [where] can be used.
abstract class SubscriberBuilder<T> {
  SubscriberBuilder();

  /// Creates a new [SubscriberBuilder] this can be used to mutate
  /// the events before they reach the [EventHandler] using the builder pattern.
  factory SubscriberBuilder.create(EventManager eventManager) =
      _SubscriberBuilder;

  /// Transforms each event.
  ///
  /// It extends the current builder by converting the
  /// input [T] using the provided [mapper] function into
  /// output [S]. Only events of type [S] will reach the
  /// [EventHandler].
  SubscriberBuilder<S> map<S>(S Function(T event) mapper) {
    return _MapSubscriberBuilder(this, mapper);
  }

  /// Filters the events
  ///
  /// It extends the current builder so that only inputs
  /// that pass the [where] clause will be kept for the [EventHandler].
  SubscriberBuilder<T> where(bool Function(T event) where) {
    return _WhereSubscriberBuilder(this, where);
  }

  /// Subscribes to the given [handler].
  ///
  /// This finalizes the builder and applies all the steps
  /// before subscribing.
  EventSubscription subscribe(EventHandler<T> handler);

  /// Subscribes to the given [handler].
  ///
  /// This finalizes the builder and applies all the steps
  /// before subscribing.
  EventSubscription subscribeFunction(
    FutureOr<void> Function(T event) handler,
  );
}

class _SubscriberBuilder<T> extends SubscriberBuilder<T> {
  final EventManager _eventManager;

  _SubscriberBuilder(this._eventManager);

  @override
  EventSubscription subscribe(EventHandler<T> handler) =>
      _eventManager.subscribe(handler);

  @override
  EventSubscription subscribeFunction(
    FutureOr<void> Function(T event) handler,
  ) =>
      _eventManager.subscribe(EventHandler.function(handler));
}

class _WhereSubscriberBuilder<T> extends SubscriberBuilder<T> {
  final SubscriberBuilder<T> _parent;
  final bool Function(T event) _where;

  _WhereSubscriberBuilder(
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

  @override
  EventSubscription subscribeFunction(
    FutureOr<void> Function(T event) handler,
  ) {
    return _parent.subscribeFunction(
      (event) => _handleWhere(event, handler),
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

class _MapSubscriberBuilder<T, S> extends SubscriberBuilder<S> {
  final SubscriberBuilder<T> _parent;
  final S Function(T event) _mapper;

  _MapSubscriberBuilder(
    this._parent,
    this._mapper,
  );

  @override
  EventSubscription subscribe(EventHandler<S> handler) {
    return _parent.subscribe(
      EventHandler.function(
        (event) => handler.handle(_mapper(event)),
      ),
    );
  }

  @override
  EventSubscription subscribeFunction(
    FutureOr<void> Function(S event) handler,
  ) {
    return _parent.subscribeFunction(
      (event) => handler(_mapper(event)),
    );
  }
}
