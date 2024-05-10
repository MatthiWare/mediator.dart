import 'package:dart_mediator/src/event/handler/event_handler_store.dart';
import 'package:test/test.dart';

import '../../../mocks.dart';

void main() {
  group('EventHandlerStore', () {
    late EventHandlerStore eventHandlerStore;

    setUp(() {
      eventHandlerStore = EventHandlerStore();
    });

    group('register', () {
      test('it registers an event handler', () {
        expect(
          () => eventHandlerStore.register(MockEventHandler<int>()),
          returnsNormally,
        );
      });

      test('it throws when registering the same handler multiple times', () {
        final handler = MockEventHandler<int>();

        eventHandlerStore.register(handler);
        expect(
          () => eventHandlerStore.register(handler),
          throwsAssertionError,
        );
      });
    });

    group('unregister', () {
      test('it unregisters the event handler', () {
        final handler = MockEventHandler<int>();

        eventHandlerStore.register(handler);

        expect(
          () => eventHandlerStore.unregister(handler),
          returnsNormally,
        );
      });

      test('it throws when unregistering the same handler multiple times', () {
        final handler = MockEventHandler<int>();

        eventHandlerStore.register(handler);
        eventHandlerStore.unregister(handler);

        expect(
          () => eventHandlerStore.unregister(handler),
          throwsAssertionError,
        );
      });
    });

    group('getHandlersFor{TEvent}', () {
      test('it returns the registered handlers', () {
        final handler = MockEventHandler<int>();

        eventHandlerStore.register(handler);

        expect(
          eventHandlerStore.getHandlersFor<int>(),
          {handler},
        );
      });
    });
  });
}
