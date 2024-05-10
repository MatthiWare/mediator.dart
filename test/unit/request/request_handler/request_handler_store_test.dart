import 'package:dart_mediator/src/request/handler/request_handler_store.dart';
import 'package:test/test.dart';

import '../../../mocks.dart';

void main() {
  group('RequestHandlerStore', () {
    late RequestHandlerStore requestHandlerStore;

    final mockRequestHandler = MockRequestHandler<int, MockRequest<int>>();

    setUp(() {
      requestHandlerStore = RequestHandlerStore();
    });

    group('register', () {
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
      final mockRequestHandler = MockRequestHandler<int, MockRequest<int>>();

      test('it unregisters the handler', () {
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
          () => requestHandlerStore.getHandlerFor(MockRequest()),
          throwsAssertionError,
        );
      });

      test('it throws when the handler does not match the types', () {
        final handlerWithWrongTypes =
            MockRequestHandler<String, MockRequest<String>>();

        requestHandlerStore.register(handlerWithWrongTypes);

        expect(
          () => requestHandlerStore.getHandlerFor(MockRequest<int>()),
          throwsAssertionError,
        );
      });

      test('it returns the request handler', () {
        final correctHandler = MockRequestHandler<int, MockRequest<int>>();

        requestHandlerStore.register(correctHandler);

        final result = requestHandlerStore.getHandlerFor(MockRequest<int>());

        expect(
          result,
          correctHandler,
        );
      });
    });
  });
}
