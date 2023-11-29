import 'package:dart_event_manager/src/dispatch_strategy.dart';
import 'package:dart_event_manager/src/event_handler/event_handler.dart';

/// [DispatchStrategy] that handles events concurrently
///
/// Each handler can start processing the event at the same time.
/// When [execute] completes you are guaranteed that all [EventHandler]'s have
/// completed. But the order they completed in is unknown.
class ConcurrentDispatchStrategy implements DispatchStrategy {
  const ConcurrentDispatchStrategy();

  @override
  Future<void> execute<TEvent>(
    Set<EventHandler<TEvent>> handlers,
    TEvent event,
  ) async {
    Future<void> handleEvent(EventHandler<TEvent> handler) async {
      await handler.handle(event);
    }

    final tasks = <Future>[];

    for (final handler in handlers) {
      tasks.add(handleEvent(handler));
    }

    await Future.wait(tasks);
  }
}
