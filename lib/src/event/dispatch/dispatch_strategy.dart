import 'package:dart_event_manager/src/event/handler/event_handler.dart';
import 'package:dart_event_manager/src/event/dispatch/concurrent_strategy.dart';
import 'package:dart_event_manager/src/event/dispatch/sequential_strategy.dart';

/// Strategy to use for dispatching events to the handlers
abstract interface class DispatchStrategy {
  /// Dispatches events one by one to the [EventHandler]'s.
  ///
  /// See [SequentialDispatchStrategy].
  const factory DispatchStrategy.sequential() = SequentialDispatchStrategy;

  /// Dispatches events concurrently to all [EventHandler]'s.
  ///
  /// See [ConcurrentDispatchStrategy].
  const factory DispatchStrategy.concurrent() = ConcurrentDispatchStrategy;

  /// Executes the given strategy by applying the [event] to the given
  /// [handlers].
  Future<void> execute<TEvent>(
    Set<EventHandler<TEvent>> handlers,
    TEvent event,
  );
}
