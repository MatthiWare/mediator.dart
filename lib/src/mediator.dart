import 'package:dart_mediator/src/event/dispatch/dispatch_strategy.dart';
import 'package:dart_mediator/src/event/event_manager.dart';
import 'package:dart_mediator/src/event/observer/event_observer.dart';
import 'package:dart_mediator/src/request/request_manager.dart';

/// Mediator that encapsulates both request/response and publishing events
///
/// See [requests] for request response.
///
/// See [events] for publishing events.
class Mediator {
  final RequestManager _requestsManager;
  final EventManager _eventManager;

  Mediator._(
    this._eventManager,
    this._requestsManager,
  );

  /// Creates a new [Mediator]
  ///
  /// [eventObservers] can be provided to observe events dispatched
  /// in [EventManager].
  ///
  /// [defaultEventDispatchStrategy] defines the strategy used when dispatching
  /// events. By default [DispatchStrategy.concurrent] is used.
  factory Mediator({
    RequestManager? requestManager,
    EventManager? eventManager,
    List<EventObserver> eventObservers = const [],
    DispatchStrategy defaultEventDispatchStrategy =
        const DispatchStrategy.concurrent(),
  }) {
    return Mediator._(
      eventManager ??
          EventManager(
            observers: eventObservers,
            defaultDispatchStrategy: defaultEventDispatchStrategy,
          ),
      requestManager ?? RequestManager(),
    );
  }

  /// Request/response communication.
  ///
  /// See [RequestManager]
  RequestManager get requests => _requestsManager;

  /// Publishing events.
  ///
  /// See [EventManager].
  EventManager get events => _eventManager;
}
