import 'package:dart_mediator/src/event/dispatch/dispatch_strategy.dart';
import 'package:dart_mediator/src/event/handler/event_handler.dart';
import 'package:dart_mediator/src/event/observer/event_observer.dart';

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
    List<EventObserver> observers,
  ) async {
    for (final handler in handlers) {
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
  }
}
