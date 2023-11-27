import 'package:dart_event_manager/event_manager.dart';
import 'package:dart_event_manager/src/event_subscription_builder.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../mocks.dart';

void main() {
  group('EventSubscriptionBuilder', () {
    late MockEventManager mockEventManager;

    setUpAll(() {
      registerFallbackValue(MockEventHandler<int>());
    });

    setUp(() {
      mockEventManager = MockEventManager();

      when(() => mockEventManager.subscribe<int>(any()))
          .thenReturn(MockEventSubscription());
    });

    group('expand', () {
      test('it creates a expand instance', () {
        final builder = EventSubscriptionBuilder<int>.create(mockEventManager)
            .expand((i) => [i, i]);

        expect(builder, isNotNull);
      });

      test('it expands the inputs', () async {
        const inputs = [1, 2];
        const expected = [1, 1, 2, 2];
        final outputs = <int>[];

        EventSubscriptionBuilder<int>.create(mockEventManager)
            .expand((input) => [input, input])
            .subscribeFunction((event) => outputs.add(event));

        final captureResult = verify(
          () => mockEventManager.subscribe<int>(captureAny()),
        );
        final handler = captureResult.captured.first as EventHandler<int>;

        for (final input in inputs) {
          await handler.handle(input);
        }

        expect(
          outputs,
          expected,
          reason: 'Output should have expanded the original inputs',
        );
      });
    });
  });
}
