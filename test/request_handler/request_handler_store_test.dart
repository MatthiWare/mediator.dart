import 'package:dart_event_manager/src/request_handler/request_handler_store.dart';
import 'package:test/test.dart';

import '../mocks.dart';

void main() {
  group('RequestHandlerStore', () {
    late RequestHandlerStore requestHandlerStore;

    setUp(() {
      requestHandlerStore = RequestHandlerStore();
    });

    group('register', () {
      final mockRequestHandler = MockRequestHandler<int, String>();

      test('it registers the handler', () {
        expect(
          () => requestHandlerStore.register(mockRequestHandler),
          returnsNormally,
        );
      });

      test('it throws when registering the same handler multiple times', () {
        requestHandlerStore.register(mockRequestHandler);
        expect(
          () => requestHandlerStore.register(mockRequestHandler),
          throwsAssertionError,
        );
      });
    });

    group('unregister', () {
      final mockRequestHandler = MockRequestHandler<int, String>();

      test('it unsubscribes to the event', () {
        requestHandlerStore.register(mockRequestHandler);

        expect(
          () => requestHandlerStore.unregister(mockRequestHandler),
          returnsNormally,
        );
      });

      test('it throws when unsubscribing the same handler multiple times', () {
        requestHandlerStore.register(mockRequestHandler);
        requestHandlerStore.unregister(mockRequestHandler);

        expect(
          () => requestHandlerStore.unregister(mockRequestHandler),
          throwsAssertionError,
        );
      });
    });

    group('getHandlerFor{TResponse, TRequest}', () {
      test('it throws when the handler does not exist', () {
        expect(
          () => requestHandlerStore.getHandlerFor<int, String>(),
          throwsAssertionError,
        );
      });

      test('it throws when the handler does not match the types', () {
        final handlerWithWrongTypes = MockRequestHandler<String, String>();

        requestHandlerStore.register(handlerWithWrongTypes);

        expect(
          () => requestHandlerStore.getHandlerFor<int, String>(),
          throwsAssertionError,
        );
      });

      test('it returns the request handler', () {
        final correctHandler = MockRequestHandler<int, String>();

        requestHandlerStore.register(correctHandler);

        expect(
          requestHandlerStore.getHandlerFor<int, String>(),
          correctHandler,
        );
      });
    });
  });
}
