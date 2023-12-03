import 'package:dart_event_manager/src/event/dispatch/dispatch_strategy.dart';
import 'package:dart_event_manager/src/event/handler/event_handler.dart';

/// [DispatchStrategy] that handles events one by one.
///
/// Each handler needs to complete before the next handler can process the
/// event.
///
/// The order of the handlers is guaranteed to be the same order
/// as they were originally registered in.
class SequentialDispatchStrategy implements DispatchStrategy {
  const SequentialDispatchStrategy();

  @override
  Future<void> execute<TEvent>(
    Set<EventHandler<TEvent>> handlers,
    TEvent event,
  ) async {
    for (final handler in handlers) {
      await handler.handle(event);
    }
  }
}
