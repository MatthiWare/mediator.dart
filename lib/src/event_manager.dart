import 'package:dart_event_manager/src/event_handler.dart';

class EventManager {
  final _handlers = <Type, List<EventHandler>>{};

  EventManager();

  /// Subscribes to a given [TEvent] using the [handler].
  void subscribe<TEvent>(EventHandler<TEvent> handler) {
    final handlers = _getHandlersFor<TEvent>();

    assert(
      !handlers.contains(handler),
      'subscribe<$TEvent> was called with an already registered handler',
    );

    handlers.add(handler);
  }

  /// Dispatches the given [event] to the registered [EventHandler]'s.
  Future<void> dispatch<TEvent>(TEvent event) async {
    final handlers = _getHandlersFor<TEvent>();

    assert(
      handlers.isNotEmpty,
      'dispatch<$TEvent> was invoked but no handlers are registered to handle this',
    );

    for (final handler in handlers) {
      await handler.handle(event);
    }
  }

  List<EventHandler<TEvent>> _getHandlersFor<TEvent>() {
    final handlers = _handlers.putIfAbsent(
      TEvent,
      () => <EventHandler<TEvent>>[],
    ) as List<EventHandler<TEvent>>;

    return handlers;
  }
}
