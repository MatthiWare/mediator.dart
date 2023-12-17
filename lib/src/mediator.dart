import 'package:dart_mediator/src/event/dispatch/dispatch_strategy.dart';
import 'package:dart_mediator/src/event/event_manager.dart';
import 'package:dart_mediator/src/event/observer/event_observer.dart';
import 'package:dart_mediator/src/request/request_manager.dart';

/// The [Mediator] is the central point of communication.
///
/// It is a wrapper around [EventManager] and [RequestManager].
class Mediator {
  final RequestManager _requestsManager;
  final EventManager _eventManager;

  /// Creates a new [Mediator]
  ///
  /// [eventManager] can be provided to manage event publishing.
  ///
  /// [requestManager] can be provided to manage request/response communication.
  Mediator({
    required EventManager eventManager,
    required RequestManager requestManager,
  })  : _eventManager = eventManager,
        _requestsManager = requestManager;

  /// Creates a default [Mediator].
  ///
  /// [observers] can be provided to observe events dispatched.
  ///
  /// [defaultDispatchStrategy] defines the strategy used when dispatching events.
  factory Mediator.create({
    List<EventObserver> observers = const [],
    DispatchStrategy defaultDispatchStrategy =
        const DispatchStrategy.concurrent(),
  }) {
    return Mediator(
      eventManager: EventManager.create(
        defaultDispatchStrategy: defaultDispatchStrategy,
        observers: observers,
      ),
      requestManager: RequestManager.create(),
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
