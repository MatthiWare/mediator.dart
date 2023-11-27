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

    group('map', () {
      test('it creates a mapped instance', () {
        final builder =
            EventSubscriptionBuilder.create(mockEventHandlerStore).map(
          (event) => 123,
        );

        expect(builder, isNotNull);
      });

      test('it executes the mapped value', () {
        const expected = 1234;
        late final int output;

        EventSubscriptionBuilder<String>.create(mockEventHandlerStore)
            .map((event) => expected)
            .subscribeFunction((event) => output = event);

        final captureResult = verify(
          () => mockEventHandlerStore.register<String>(captureAny()),
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
            EventSubscriptionBuilder.create(mockEventHandlerStore).asyncMap(
          (event) async => 123,
        );

        expect(builder, isNotNull);
      });

      test('it executes the mapped value', () async {
        const expected = 1234;
        late final int output;

        EventSubscriptionBuilder<String>.create(mockEventHandlerStore)
            .asyncMap((event) async => expected)
            .subscribeFunction((event) => output = event);

        final captureResult = verify(
          () => mockEventHandlerStore.register<String>(captureAny()),
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
