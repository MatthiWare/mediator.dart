import 'package:dart_event_manager/src/event/dispatch/dispatch_strategy.dart';
import 'package:dart_event_manager/src/event/event_manager.dart';
import 'package:dart_event_manager/src/event/observer/event_observer.dart';
import 'package:dart_event_manager/src/request/request_manager.dart';

class Mediator {
  final RequestManager _requestsManager;
  final EventManager _eventManager;

  Mediator._(
    this._eventManager,
    this._requestsManager,
  );

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

  RequestManager get requests => _requestsManager;

  EventManager get events => _eventManager;
}
