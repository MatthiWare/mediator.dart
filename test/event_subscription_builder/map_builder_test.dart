import 'package:dart_event_manager/event_manager.dart';
import 'package:dart_event_manager/src/event_subscription_builder.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../mocks.dart';

void main() {
  group('EventSubscriptionBuilder', () {
    late MockEventManager mockEventManager;

    setUpAll(() {
      registerFallbackValue(MockEventHandler<String>());
      registerFallbackValue(MockEventHandler<int>());
    });

    setUp(() {
      mockEventManager = MockEventManager();

      when(() => mockEventManager.subscribe<int>(any()))
          .thenReturn(MockEventSubscription());
      when(() => mockEventManager.subscribe<String>(any()))
          .thenReturn(MockEventSubscription());
    });

    group('map', () {
      test('it creates a mapped instance', () {
        final builder = EventSubscriptionBuilder.create(mockEventManager).map(
          (event) => 123,
        );

        expect(builder, isNotNull);
      });

      test('it executes the mapped value', () {
        const expected = 1234;
        late final int output;

        EventSubscriptionBuilder<String>.create(mockEventManager)
            .map((event) => expected)
            .subscribeFunction((event) => output = event);

        final captureResult = verify(
          () => mockEventManager.subscribe<String>(captureAny()),
        );
        final handler = captureResult.captured.first as EventHandler<String>;

        handler.handle('not 1234');

        expect(
          output,
          expected,
          reason: 'Output should have been mapped',
        );
      });
    });

    group('asyncMap', () {
      test('it creates a mapped instance', () {
        final builder =
            EventSubscriptionBuilder.create(mockEventManager).asyncMap(
          (event) async => 123,
        );

        expect(builder, isNotNull);
      });

      test('it executes the mapped value', () async {
        const expected = 1234;
        late final int output;

        EventSubscriptionBuilder<String>.create(mockEventManager)
            .asyncMap((event) async => expected)
            .subscribeFunction((event) => output = event);

        final captureResult = verify(
          () => mockEventManager.subscribe<String>(captureAny()),
        );
        final handler = captureResult.captured.first as EventHandler<String>;

        await handler.handle('not 1234');

        expect(
          output,
          expected,
          reason: 'Output should have been mapped',
        );
      });
    });
  });
}
