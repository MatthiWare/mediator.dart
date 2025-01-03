import 'package:dart_mediator/src/event/event.dart';
import 'package:dart_mediator/src/event/handler/event_handler.dart';
import 'package:dart_mediator/src/event/dispatch/dispatch_strategy.dart';

/// Observer for [DomainEvent]'s.
abstract interface class EventObserver {
  /// When the [event] is dispatched.
  ///
  /// [handlers] will be executed based on the [DispatchStrategy].
  void onDispatch<TEvent>(
    TEvent event,
    Set<EventHandler> handlers,
  );

  /// When the [event] is handled by the [handler].
  void onHandled<TEvent>(
    TEvent event,
    EventHandler handler,
  );

  /// When the [event] is failed by the [handler] the [error] contains the
  /// exception object.
  void onError<TEvent>(
    TEvent event,
    EventHandler handler,
    Object error,
    StackTrace stackTrace,
  );
}
