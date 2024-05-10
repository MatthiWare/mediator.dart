import 'package:dart_mediator/event_manager.dart';
import 'package:dart_mediator/src/event/handler/event_handler.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../../../mocks.dart';

void main() {
  group('EventHandler', () {
    group('function', () {
      group('handle', () {
        test('it handles the event', () {
          var handled = false;
          final handler = EventHandler<int>.function((event) {
            handled = true;
          });

          handler.handle(123);

          expect(handled, isTrue);
        });
      });

      test('is immutable', () {
        void handler(int a) {}

        final a = EventHandler.function(handler);
        final b = EventHandler.function(handler);

        expect(a, b);
        expect(a == b, isTrue);
        expect(a.hashCode == b.hashCode, isTrue);
      });
    });

    group('factory', () {
      group('handle', () {
        test('it handles the event', () {
          final mockEventHandler = MockEventHandler<int>();
          final handler = EventHandler<int>.factory(() => mockEventHandler);

          handler.handle(123);

          verify(() => mockEventHandler.handle(123));
        });
      });

      test('is immutable', () {
        EventHandler<int> factory() => MockEventHandler();

        final a = EventHandler.factory(factory);
        final b = EventHandler.factory(factory);

        expect(a, b);
        expect(a == b, isTrue);
        expect(a.hashCode == b.hashCode, isTrue);
      });
    });
  });
}
