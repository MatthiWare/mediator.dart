import 'package:dart_mediator/src/event/dispatch/dispatch_strategy.dart';
import 'package:dart_mediator/src/event/event.dart';
import 'package:dart_mediator/src/event/handler/event_handler_store.dart';
import 'package:dart_mediator/src/event/observer/event_observer.dart';
import 'package:dart_mediator/src/event/subscription_builder/event_subscription_builder.dart';

class EventManager {
  final EventHandlerStore _eventHandlerStore;
  final List<EventObserver> _observers;
  final DispatchStrategy _defaultDispatchStrategy;

  EventManager._(
    this._eventHandlerStore,
    this._observers,
    this._defaultDispatchStrategy,
  );

  factory EventManager({
    EventHandlerStore? eventHandlerStore,
    List<EventObserver>? observers,
    DispatchStrategy defaultDispatchStrategy =
        const DispatchStrategy.concurrent(),
  }) {
    return EventManager._(
      eventHandlerStore ?? EventHandlerStore(),
      observers ?? [],
      defaultDispatchStrategy,
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
