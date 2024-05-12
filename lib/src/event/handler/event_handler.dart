import 'dart:async';

import 'package:meta/meta.dart';

/// Factory to create a [EventHandler].
typedef EventHandlerFactory<TEvent> = EventHandler<TEvent> Function();

/// Handler for [TEvent].
abstract interface class EventHandler<TEvent> {
  /// Function based [EventHandler].
  ///
  /// Each event the underlying [handler] will be executed.
  const factory EventHandler.function(
    FutureOr<void> Function(TEvent event) handler,
  ) = _FunctionEventHandler;

  /// Factory based [EventHandler]
  ///
  /// Each event the underlying [factory] will be instantiated and used
  /// to handle the [TEvent].
  const factory EventHandler.factory(
    EventHandlerFactory<TEvent> factory,
  ) = _FactoryEventHandler;

  /// Handles the given [event].
  FutureOr<void> handle(TEvent event);
}

@immutable
class _FunctionEventHandler<T> implements EventHandler<T> {
  final FutureOr<void> Function(T event) handler;

  const _FunctionEventHandler(this.handler);

  @override
  FutureOr<void> handle(T event) => handler(event);

  @override
  int get hashCode => Object.hash(runtimeType, handler);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _FunctionEventHandler<T> &&
            other.handler == handler);
  }
}

@immutable
class _FactoryEventHandler<T> implements EventHandler<T> {
  final EventHandlerFactory<T> factory;

  const _FactoryEventHandler(this.factory);

  @override
  FutureOr<void> handle(T event) {
    final handler = factory();
    return handler.handle(event);
  }

  @override
  int get hashCode => Object.hash(runtimeType, factory);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _FactoryEventHandler<T> &&
            other.factory == factory);
  }
}
