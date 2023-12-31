import 'dart:async';

/// Factory to create a [EventHandler].
typedef EventHandlerFactory<TEvent> = EventHandler<TEvent> Function();

/// Handler for [TEvent].
abstract interface class EventHandler<TEvent> {
  /// Function based event handler
  const factory EventHandler.function(
    FutureOr<void> Function(TEvent event) handler,
  ) = _FunctionEventHandler;

  /// Handles the given [event].
  FutureOr<void> handle(TEvent event);
}

class _FunctionEventHandler<T> implements EventHandler<T> {
  final FutureOr<void> Function(T event) handler;

  const _FunctionEventHandler(this.handler);

  @override
  FutureOr<void> handle(T event) => handler(event);
}
