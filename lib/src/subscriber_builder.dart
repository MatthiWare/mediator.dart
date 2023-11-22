import 'dart:async';

import 'package:dart_event_manager/event_manager.dart';

final x = Stream.empty();

abstract class SubscriberBuilder<T> {
  SubscriberBuilder();

  factory SubscriberBuilder.create(EventManager eventManager) =
      _SubscriberBuilder;

  SubscriberBuilder<S> map<S>(S Function(T event) mapper) {
    return _MapSubscriberBuilder(this, mapper);
  }

  SubscriberBuilder<T> where(bool Function(T event) where) {
    return _WhereSubscriberBuilder(this, where);
  }

  void subscribe(EventHandler<T> handler);

  void subscribeFunction(FutureOr<void> Function(T event) handler);
}

class _SubscriberBuilder<T> extends SubscriberBuilder<T> {
  final EventManager _eventManager;

  _SubscriberBuilder(this._eventManager);

  @override
  void subscribe(EventHandler<T> handler) {
    _eventManager.subscribe(handler);
  }

  @override
  void subscribeFunction(FutureOr<void> Function(T event) handler) {
    _eventManager.subscribe(EventHandler.function(handler));
  }
}

class _WhereSubscriberBuilder<T> extends SubscriberBuilder<T> {
  final SubscriberBuilder<T> _parent;
  final bool Function(T event) _where;

  _WhereSubscriberBuilder(
    this._parent,
    this._where,
  );

  @override
  void subscribe(EventHandler<T> handler) {
    _parent.subscribe(
      EventHandler.function(
        (event) => _handleWhere(event, handler.handle),
      ),
    );
  }

  @override
  void subscribeFunction(FutureOr<void> Function(T event) handler) {
    _parent.subscribeFunction(
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
  void subscribe(EventHandler<S> handler) {
    _parent.subscribe(
      EventHandler.function(
        (event) => handler.handle(_mapper(event)),
      ),
    );
  }

  @override
  void subscribeFunction(FutureOr<void> Function(S event) handler) {
    _parent.subscribeFunction(
      (event) => handler(_mapper(event)),
    );
  }
}
