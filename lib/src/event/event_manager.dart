import 'package:dart_mediator/src/event/dispatch/dispatch_strategy.dart';
import 'package:dart_mediator/src/event/event.dart';
import 'package:dart_mediator/src/event/handler/event_handler.dart';
import 'package:dart_mediator/src/event/handler/event_handler_store.dart';
import 'package:dart_mediator/src/event/observer/event_observer.dart';
import 'package:dart_mediator/src/event/subscription_builder/event_subscription_builder.dart';

/// Publish events through the mediator to be handled by multiple handlers.
class EventManager {
  final EventHandlerStore _eventHandlerStore;
  final List<EventObserver> _observers;
  final DispatchStrategy _defaultDispatchStrategy;

  /// Creates a new [EventManager].
  ///
  /// [eventHandlerStore] is used to store the subscribed [EventHandler]'s.
  /// These handlers are created by the [on] method.
  ///
  /// [observers] can be provided to observe events dispatched.
  ///
  /// [defaultDispatchStrategy] defines the strategy used when dispatching
  /// events. By default [DispatchStrategy.concurrent] is used.
  EventManager({
    required EventHandlerStore eventHandlerStore,
    required List<EventObserver> observers,
    required DispatchStrategy defaultDispatchStrategy,
  })  : _eventHandlerStore = eventHandlerStore,
        _observers = observers,
        _defaultDispatchStrategy = defaultDispatchStrategy;

  /// Creates a default [EventManager].
  ///
  /// [observers] can be provided to observe events dispatched.
  ///
  /// [defaultDispatchStrategy] defines the strategy used when dispatching events.
  factory EventManager.create({
    List<EventObserver> observers = const [],
    DispatchStrategy defaultDispatchStrategy =
        const DispatchStrategy.concurrent(),
  }) {
    return EventManager(
      eventHandlerStore: EventHandlerStore(),
      observers: observers,
      defaultDispatchStrategy: defaultDispatchStrategy,
    );
  }

  /// Subscribe on the given [T] event.
  ///
  /// Returns a [EventSubscriptionBuilder] that allows to build a specific
  /// subscription.
  EventSubscriptionBuilder<T> on<T extends DomainEvent>() =>
      EventSubscriptionBuilder.create(_eventHandlerStore);

  /// Dispatches the given [event] to the registered [EventHandler]'s.
  Future<void> dispatch<TEvent extends DomainEvent>(
    TEvent event, [
    DispatchStrategy? dispatchStrategy,
  ]) async {
    final handlers = _eventHandlerStore.getHandlersFor<TEvent>();

    assert(
      handlers.isNotEmpty,
      'dispatch<$TEvent> was invoked but no handlers are registered to handle this',
    );

    for (final observer in _observers) {
      observer.onDispatch(event, handlers);
    }

    await (dispatchStrategy ?? _defaultDispatchStrategy)
        .execute(handlers, event, _observers);
  }
}
