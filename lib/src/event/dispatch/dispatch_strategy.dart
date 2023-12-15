import 'package:dart_mediator/src/event/event.dart';
import 'package:dart_mediator/src/event/handler/event_handler.dart';
import 'package:dart_mediator/src/event/dispatch/concurrent_strategy.dart';
import 'package:dart_mediator/src/event/dispatch/sequential_strategy.dart';
import 'package:dart_mediator/src/event/observer/event_observer.dart';

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
  Future<void> execute<TEvent extends DomainEvent>(
    Set<EventHandler<TEvent>> handlers,
    TEvent event,
    List<EventObserver> observers,
  );
}
