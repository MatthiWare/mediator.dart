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

  List<EventHandler<TEvent>> _getHandlersFor<TEvent>() {
    final handlers = _handlers.putIfAbsent(
      TEvent,
      () => <EventHandler<TEvent>>[],
    ) as List<EventHandler<TEvent>>;

    return handlers;
  }
}
