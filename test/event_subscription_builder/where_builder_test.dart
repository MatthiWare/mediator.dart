import 'package:dart_event_manager/event_manager.dart';
import 'package:dart_event_manager/src/event_subscription_builder.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../mocks.dart';

void main() {
  group('EventSubscriptionBuilder', () {
    late MockEventHandlerStore mockEventHandlerStore;

    setUpAll(() {
      registerFallbackValue(MockEventHandler<String>());
      registerFallbackValue(MockEventHandler<int>());
    });

    setUp(() {
      mockEventHandlerStore = MockEventHandlerStore();
    });

    group('where', () {
      test('it creates a where instance', () {
        final builder =
            EventSubscriptionBuilder<int>.create(mockEventHandlerStore).where(
          (event) => event > 0,
        );

        expect(builder, isNotNull);
      });

      test('it only executes when the where condition is true', () {
        const expected = [0, 55, 99];
        final outputs = <int>[];

        EventSubscriptionBuilder<int>.create(mockEventHandlerStore)
            .where((event) => event < 100)
            .subscribeFunction((event) => outputs.add(event));

        final captureResult = verify(
          () => mockEventHandlerStore.register<int>(captureAny()),
        );
        final handler = captureResult.captured.first as EventHandler<int>;

        handler.handle(1000);
        handler.handle(0);
        handler.handle(100);
        handler.handle(55);
        handler.handle(99);
        handler.handle(333);

        expect(
          outputs,
          expected,
          reason: 'Output should have only values <100',
        );
      });
    });
  });
}
