import 'package:dart_event_manager/src/event/handler/event_handler.dart';

class EventHandlerStore {
  final _handlers = <Type, Set<EventHandler>>{};
  final _handlerFactories = <Type, Set<EventHandlerFactory>>{};

  /// Registers the [handler] to a given [TEvent].
  void register<TEvent>(EventHandler<TEvent> handler) {
    final handlers = _getHandlersFor<TEvent>();

    assert(
      !handlers.contains(handler),
      'register<$TEvent> was called with an already registered handler',
    );

    handlers.add(handler);
  }

  /// Registers the [factory] to a given [TEvent].
  void registerFactory<TEvent>(EventHandlerFactory<TEvent> factory) {
    final factories = _getHandlerFactoriesFor<TEvent>();

    assert(
      !factories.contains(factory),
      'registerFactory<$TEvent> was called with an already registered factory',
    );

    factories.add(factory);
  }

  /// Unregisters the given [handler].
  void unregister<TEvent>(EventHandler<TEvent> handler) {
    final handlers = _getHandlersFor<TEvent>();

    assert(
      handlers.contains(handler),
      'unregister<$TEvent> was called for a handler that was never registered',
    );

    handlers.remove(handler);
  }

  /// Unregisters the given [factory].
  void unregisterFactory<TEvent>(EventHandlerFactory<TEvent> factory) {
    final factories = _getHandlerFactoriesFor<TEvent>();

    assert(
      factories.contains(factory),
      'unregisterFactory<$TEvent> was called for a factory that was never registered',
    );

    factories.remove(factory);
  }

  /// Returns all registered [EventHandler]'s for [TEvent].
  Set<EventHandler<TEvent>> getHandlersFor<TEvent>() {
    final handlers = _getHandlersFor<TEvent>();
    final factories =
        _getHandlerFactoriesFor<TEvent>().map((factory) => factory());

    return {
      ...handlers,
      ...factories,
    };
  }

  Set<EventHandler<TEvent>> _getHandlersFor<TEvent>() {
    final handlers = _handlers.putIfAbsent(
      TEvent,
      () => <EventHandler<TEvent>>{},
    ) as Set<EventHandler<TEvent>>;

    return handlers;
  }

  Set<EventHandlerFactory<TEvent>> _getHandlerFactoriesFor<TEvent>() {
    final factories = _handlerFactories.putIfAbsent(
      TEvent,
      () => <EventHandlerFactory<TEvent>>{},
    ) as Set<EventHandlerFactory<TEvent>>;

    return factories;
  }
}
