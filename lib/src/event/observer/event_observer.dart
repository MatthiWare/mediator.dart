import 'package:dart_event_manager/src/event/event.dart';
import 'package:dart_event_manager/src/event/handler/event_handler.dart';
import 'package:dart_event_manager/src/event/dispatch/dispatch_strategy.dart';

/// Observer for [DomainEvent]'s.
abstract interface class EventObserver {
  /// When the [event] is dispatched.
  ///
  /// [handlers] will be executed based on the [DispatchStrategy].
  void onDispatch<TEvent extends DomainEvent>(
    TEvent event,
    Set<EventHandler<TEvent>> handlers,
  );

  /// When the [event] is handled by the [handler].
  void onHandled<TEvent extends DomainEvent>(
    TEvent event,
    EventHandler<TEvent> handler,
  );

  /// When the [event] is failed by the [handler] the [error] contains the
  /// exception object.
  void onError<TEvent extends DomainEvent>(
    TEvent event,
    EventHandler<TEvent> handler,
    Object error,
    StackTrace stackTrace,
  );
}
