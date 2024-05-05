import 'package:dart_mediator/src/request/handler/request_handler.dart';
import 'package:test/test.dart';

import '../../../mocks.dart';

void main() {
  group('RequestHandler', () {
    setUp(() {});

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
  });
}
