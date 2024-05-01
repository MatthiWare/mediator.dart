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

    group('registerFactory', () {
      test('it registers the factory', () {
        expect(
          () =>
              eventHandlerStore.registerFactory(() => MockEventHandler<int>()),
          returnsNormally,
        );
      });

      test('it throws when registering the same handler multiple times', () {
        MockEventHandler<int> factory() => MockEventHandler<int>();

        eventHandlerStore.registerFactory(factory);
        expect(
          () => eventHandlerStore.registerFactory(factory),
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

    group('unregisterFactory', () {
      test('it unregisters the factory', () {
        MockEventHandler<int> factory() => MockEventHandler<int>();

        eventHandlerStore.registerFactory(factory);

        expect(
          () => eventHandlerStore.unregisterFactory(factory),
          returnsNormally,
        );
      });

      test('it throws when unregistering the same factory multiple times', () {
        MockEventHandler<int> factory() => MockEventHandler<int>();

        eventHandlerStore.registerFactory(factory);
        eventHandlerStore.unregisterFactory(factory);

        expect(
          () => eventHandlerStore.unregisterFactory(factory),
          throwsAssertionError,
        );
      });
    });

    group('getHandlersFor{TEvent}', () {
      test('it returns the registered handlers', () {
        final handler = MockEventHandler<int>();
        final factoryHandler = MockEventHandler<int>();
        MockEventHandler<int> factory() => factoryHandler;

        eventHandlerStore.register(handler);
        eventHandlerStore.registerFactory(factory);

        expect(
          eventHandlerStore.getHandlersFor<int>(),
          {handler, factoryHandler},
        );
      });
    });
  });
}
