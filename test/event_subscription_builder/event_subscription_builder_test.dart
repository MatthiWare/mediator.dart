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
