import 'package:dart_event_manager/src/event_handler/event_handler.dart';
import 'package:dart_event_manager/src/event_handler/event_handler_store.dart';
import 'package:test/test.dart';

import '../../mocks.dart';

void main() {
  group('EventHandlerStore', () {
    late EventHandlerStore eventHandlerStore;

    setUp(() {
      eventHandlerStore = EventHandlerStore();
    });

    group('subscribe', () {
      test('it subscribes to the event', () {
        expect(
          () => eventHandlerStore
              .register(EventHandler<int>.function((event) {})),
          returnsNormally,
        );
      });

      test('it throws when registering the same handler multiple times', () {
        final handler = EventHandler<int>.function((event) {});

        eventHandlerStore.register(handler);
        expect(
          () => eventHandlerStore.register(handler),
          throwsAssertionError,
        );
      });
    });

    group('unsubscribe', () {
      test('it unsubscribes to the event', () {
        final handler = EventHandler<int>.function((event) {});

        eventHandlerStore.register(handler);

        expect(
          () => eventHandlerStore.unregister(handler),
          returnsNormally,
        );
      });

      test('it throws when unsubscribing the same handler multiple times', () {
        final handler = EventHandler<int>.function((event) {});

        eventHandlerStore.register(handler);
        eventHandlerStore.unregister(handler);

        expect(
          () => eventHandlerStore.unregister(handler),
          throwsAssertionError,
        );
      });
    });
  });
}
