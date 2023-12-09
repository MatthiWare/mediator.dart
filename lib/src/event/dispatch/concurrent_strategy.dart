import 'package:dart_event_manager/src/event/dispatch/dispatch_strategy.dart';
import 'package:dart_event_manager/src/event/event.dart';
import 'package:dart_event_manager/src/event/handler/event_handler.dart';
import 'package:dart_event_manager/src/event/observer/event_observer.dart';

/// [DispatchStrategy] that handles events concurrently
///
/// Each handler can start processing the event at the same time.
/// When [execute] completes you are guaranteed that all [EventHandler]'s have
/// completed. But the order they completed in is unknown.
class ConcurrentDispatchStrategy implements DispatchStrategy {
  const ConcurrentDispatchStrategy();

  @override
  Future<void> execute<TEvent extends DomainEvent>(
    Set<EventHandler<TEvent>> handlers,
    TEvent event,
    List<EventObserver> observers,
  ) async {
    Future<void> handleEvent(EventHandler<TEvent> handler) async {
      try {
        await handler.handle(event);
        for (final observer in observers) {
          observer.onHandled<TEvent>(event, handler);
        }
      } catch (e, stackTrace) {
        for (final observer in observers) {
          observer.onError(event, handler, e, stackTrace);
        }
        rethrow;
      }
    }

    final tasks = <Future>[];

    for (final handler in handlers) {
      tasks.add(handleEvent(handler));
    }

    await Future.wait(tasks);
  }
}
