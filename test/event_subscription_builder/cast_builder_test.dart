import 'package:dart_event_manager/event_manager.dart';
import 'package:dart_event_manager/src/event_subscription_builder.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../mocks.dart';

void main() {
  group('EventSubscriptionBuilder', () {
    late MockEventHandlerStore mockEventHandlerStore;

    setUpAll(() {
      registerFallbackValue(MockEventHandler<Object>());
      registerFallbackValue(MockEventHandler<int>());
    });

    setUp(() {
      mockEventHandlerStore = MockEventHandlerStore();
    });

    group('cast', () {
      test('it creates a mapped instance', () {
        final builder =
            EventSubscriptionBuilder.create(mockEventHandlerStore).cast<int>();

        expect(builder, isNotNull);
      });

      test('it returns the casted value', () {
        Object input = 1234;
        late final int output;

        EventSubscriptionBuilder<Object>.create(mockEventHandlerStore)
            .cast<int>()
            .subscribeFunction((event) => output = event);

        final captureResult = verify(
          () => mockEventHandlerStore.register<Object>(captureAny()),
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
