import 'dart:async';

import 'package:dart_mediator/request_manager.dart';
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
          final handler =
              PipelineBehavior<int, MockRequest<int>>.function((req, next) {
            handled = true;
            return next();
          });

          expect(handler.handle(mockRequest, () => 123), 123);
          expect(handled, isTrue);
        });
      });

      test('is immutable', () {
        FutureOr<int> handler(
          Request<String> req,
          RequestHandlerDelegate<int> next,
        ) {
          return next();
        }

        final a = PipelineBehavior.function(handler);
        final b = PipelineBehavior.function(handler);

        expect(a, b);
        expect(a == b, isTrue);
        expect(a.hashCode == b.hashCode, isTrue);
      });
    });

    group('factory', () {
      group('handle', () {
        test('it handles the request', () {
          final mockPipeline = MockPipelineBehavior<int, MockRequest<int>>();
          PipelineBehavior<int, MockRequest<int>> factory() => mockPipeline;

          final handler =
              PipelineBehavior<int, MockRequest<int>>.factory(factory);

          int next() => 123;
          final request = MockRequest<int>();

          when(() => mockPipeline.handle(request, next)).thenReturn(123);

          handler.handle(request, next);

          verify(() => mockPipeline.handle(request, next));
        });
      });

      test('is immutable', () {
        PipelineBehavior<int, MockRequest<int>> factory() =>
            MockPipelineBehavior();

        final a = PipelineBehavior.factory(factory);
        final b = PipelineBehavior.factory(factory);

        expect(a, b);
        expect(a == b, isTrue);
        expect(a.hashCode == b.hashCode, isTrue);
      });
    });
  });
}
