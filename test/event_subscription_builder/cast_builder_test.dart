import 'package:dart_event_manager/event_manager.dart';
import 'package:dart_event_manager/src/event_subscription_builder.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../mocks.dart';

void main() {
  group('EventSubscriptionBuilder', () {
    late MockEventManager mockEventManager;

    setUpAll(() {
      registerFallbackValue(MockEventHandler<Object>());
      registerFallbackValue(MockEventHandler<int>());
    });

    setUp(() {
      mockEventManager = MockEventManager();

      when(() => mockEventManager.subscribe<int>(any()))
          .thenReturn(MockEventSubscription());

      when(() => mockEventManager.subscribe<Object>(any()))
          .thenReturn(MockEventSubscription());
    });

    group('cast', () {
      test('it creates a mapped instance', () {
        final builder =
            EventSubscriptionBuilder.create(mockEventManager).cast<int>();

        expect(builder, isNotNull);
      });

      test('it returns the casted value', () {
        Object input = 1234;
        late final int output;

        EventSubscriptionBuilder<Object>.create(mockEventManager)
            .cast<int>()
            .subscribeFunction((event) => output = event);

        final captureResult = verify(
          () => mockEventManager.subscribe<Object>(captureAny()),
        );
        final handler = captureResult.captured.first as EventHandler<Object>;

        handler.handle(input);

        expect(
          output,
          1234,
          reason: 'Output should have been mapped',
        );
      });
    });
  });
}
