import 'package:dart_mediator/src/request/handler/request_handler_store.dart';
import 'package:test/test.dart';

import '../../../mocks.dart';

void main() {
  group('RequestHandlerStore', () {
    late RequestHandlerStore requestHandlerStore;

    setUp(() {
      requestHandlerStore = RequestHandlerStore();
    });

    group('register', () {
      final mockRequestHandler = MockRequestHandler<int, MockRequest<int>>();

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

    group('registerFactory', () {
      test('it registers the handler', () {
        expect(
          () => requestHandlerStore.registerFactory<int, MockRequest<int>>(
            () => MockRequestHandler<int, MockRequest<int>>(),
          ),
          returnsNormally,
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
        correctHandlerFactory() => mockHandler;

        requestHandlerStore.registerFactory(correctHandlerFactory);

        expect(
          requestHandlerStore.getHandlerFor(MockRequest<int>()),
          mockHandler,
        );
      });
    });
  });
}
