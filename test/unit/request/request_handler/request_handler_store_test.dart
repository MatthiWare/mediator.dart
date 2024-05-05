import 'package:dart_mediator/src/request/handler/request_handler.dart';
import 'package:dart_mediator/src/request/handler/request_handler_store.dart';
import 'package:test/test.dart';

import '../../../mocks.dart';

void main() {
  group('RequestHandlerStore', () {
    late RequestHandlerStore requestHandlerStore;

    RequestHandler<int, MockRequest<int>> handlerFactory() =>
        MockRequestHandler<int, MockRequest<int>>();

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

      test('it throws when a factory for this type was already registered', () {
        requestHandlerStore.registerFactory(handlerFactory);

        expect(
          () => requestHandlerStore.register(mockRequestHandler),
          throwsAssertionError,
        );
      });
    });

    group('registerFactory', () {
      test('it registers the handler', () {
        expect(
          () => requestHandlerStore.registerFactory(handlerFactory),
          returnsNormally,
        );
      });

      test('it throws when registering the same factory multiple times', () {
        requestHandlerStore.registerFactory(handlerFactory);

        expect(
          () => requestHandlerStore.registerFactory(handlerFactory),
          throwsAssertionError,
        );
      });

      test('it throws when a handler for this type was already registered', () {
        requestHandlerStore.register(mockRequestHandler);

        expect(
          () => requestHandlerStore.registerFactory(handlerFactory),
          throwsAssertionError,
        );
      });
    });

    group('unregister', () {
      final mockRequestHandler = MockRequestHandler<int, MockRequest<int>>();

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

      test('it returns the request handler factory', () {
        final mockHandler = MockRequestHandler<int, MockRequest<int>>();
        MockRequestHandler<int, MockRequest<int>> correctHandlerFactory() =>
            mockHandler;

        requestHandlerStore.registerFactory(correctHandlerFactory);

        expect(
          requestHandlerStore.getHandlerFor(MockRequest<int>()),
          mockHandler,
        );
      });
    });
  });
}
