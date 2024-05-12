import 'package:dart_mediator/event_manager.dart';
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
      test('it subscribes the handler', () {
        final handler = EventHandler<int>.function((event) {});

        EventSubscriptionBuilder<int>.create(mockEventHandlerStore)
            .subscribe(handler);

        verify(() => mockEventHandlerStore.register(handler));
      });

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
      test('it subscribes the handler', () {
        EventSubscriptionBuilder<int>.create(mockEventHandlerStore)
            .subscribeFunction((event) {});

        verify(() => mockEventHandlerStore.register(any<EventHandler<int>>()));
      });

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

      test('it can cancel the subscription', () {
        final subscription =
            EventSubscriptionBuilder<int>.create(mockEventHandlerStore)
                .subscribeFunction((event) {});

        subscription.cancel();

        verify(
          () => mockEventHandlerStore.unregister(any<EventHandler<int>>()),
        );
      });
    });

    group('subscribeFactory', () {
      EventHandler<int> handlerFactory() => MockEventHandler();

      final factoryHandler = EventHandler.factory(handlerFactory);

      test('it subscribes the handler', () {
        EventSubscriptionBuilder<int>.create(mockEventHandlerStore)
            .subscribeFactory(handlerFactory);

        verify(() => mockEventHandlerStore.register(factoryHandler));
      });

      test('it return a subscription', () {
        final subscription =
            EventSubscriptionBuilder<int>.create(mockEventHandlerStore)
                .subscribeFactory(handlerFactory);

        expect(
          subscription,
          isA<EventSubscription>(),
          reason: 'it should return a subscription',
        );
      });

      test('it can cancel the subscription', () {
        final subscription =
            EventSubscriptionBuilder<int>.create(mockEventHandlerStore)
                .subscribeFactory(handlerFactory);

        subscription.cancel();

        verify(() => mockEventHandlerStore.unregister(factoryHandler));
      });
    });
  });
}
