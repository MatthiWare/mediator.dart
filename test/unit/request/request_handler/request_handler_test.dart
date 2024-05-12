import 'package:dart_mediator/src/request/handler/request_handler.dart';
import 'package:dart_mediator/src/request/request.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../../../mocks.dart';

void main() {
  group('RequestHandler', () {
    group('function', () {
      group('handle', () {
        test('it handles the request', () {
          var handled = false;
          final mockRequest = MockRequest<int>();
          final handler = RequestHandler<int, MockRequest<int>>.function((req) {
            handled = true;
            return 123;
          });

          expect(handler.handle(mockRequest), 123);
          expect(handled, isTrue);
        });
      });

      test('is immutable', () {
        int handle(MockRequest<int> req) => 123;

        final a = RequestHandler.function(handle);
        final b = RequestHandler.function(handle);

        expect(a, b);
        expect(a == b, isTrue);
        expect(a.hashCode == b.hashCode, isTrue);
      });
    });

    group('factory', () {
      group('handle', () {
        test('it handles the request', () {
          final mockRequest = MockRequest<int>();
          final mockHandler = MockRequestHandler<int, MockRequest<int>>();

          when(() => mockHandler.handle(mockRequest)).thenReturn(123);

          MockRequestHandler<int, MockRequest<int>> factory() => mockHandler;

          final handler = RequestHandler.factory(factory);

          expect(handler.handle(mockRequest), 123);

          verify(() => mockHandler.handle(mockRequest));
        });
      });

      test('is immutable', () {
        RequestHandler<int, Request<int>> factory() => MockRequestHandler();

        final a = RequestHandler.factory(factory);
        final b = RequestHandler.factory(factory);

        expect(a, b);
        expect(a == b, isTrue);
        expect(a.hashCode == b.hashCode, isTrue);
      });
    });
  });
}
