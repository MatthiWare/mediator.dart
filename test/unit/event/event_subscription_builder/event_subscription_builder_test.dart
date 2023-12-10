import 'package:dart_mediator/event_manager.dart';
import 'package:dart_mediator/src/event/subscription_builder/event_subscription_builder.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../../../mocks.dart';

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

    group('create', () {
      test('it creates an instance', () {
        final builder = EventSubscriptionBuilder.create(mockEventHandlerStore);

        expect(builder, isNotNull);
      });
    });

    group('subscribe', () {
      test('it return a subscription', () {
        final subscription =
            EventSubscriptionBuilder<int>.create(mockEventHandlerStore)
                .subscribe(EventHandler.function((event) {}));

        expect(
          subscription,
          isA<EventSubscription>(),
          reason: 'it should return a subscription',
        );
      });

      test('it can cancel the subscription', () {
        final mockHandler = MockEventHandler<int>();

        final subscription =
            EventSubscriptionBuilder<int>.create(mockEventHandlerStore)
                .subscribe(mockHandler);

        subscription.cancel();

        verify(() => mockEventHandlerStore.unregister(mockHandler));
      });
    });

    group('subscribeFunction', () {
      test('it return a subscription', () {
        final subscription =
            EventSubscriptionBuilder<int>.create(mockEventHandlerStore)
                .subscribeFunction((event) {});

        expect(
          subscription,
          isA<EventSubscription>(),
          reason: 'it should return a subscription',
        );
      });
    });
  });
}
