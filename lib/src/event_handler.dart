import 'dart:async';

/// Handler for [TEvent].
abstract class EventHandler<TEvent> {
  /// Handles the given [event].
  FutureOr<void> handle(TEvent event);
}
