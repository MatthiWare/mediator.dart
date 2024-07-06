import 'package:dart_mediator/src/event/event_manager.dart';
import 'package:dart_mediator/src/event/subscription_builder/event_subscription_builder.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../../mocks.dart';
import '../../test_data.dart';

void main() {
  group('EventManager', () {
    late EventManager eventManager;
    late MockEventHandlerStore mockEventHandlerStore;
    late MockDispatchStrategy mockDispatchStrategy;
    late MockEventObserver mockEventObserver;

    setUp(() {
      mockEventHandlerStore = MockEventHandlerStore();
      mockDispatchStrategy = MockDispatchStrategy();
      mockEventObserver = MockEventObserver();

      eventManager = EventManager(
        eventHandlerStore: mockEventHandlerStore,
        observers: [mockEventObserver],
        defaultDispatchStrategy: mockDispatchStrategy,
      );
    });

    setUpAll(() {
      registerFallbackValue(const DomainIntEvent(123));
    });

    group('on{T}', () {
      test('it returns a new builder instance', () {
        expect(
          eventManager.on<DomainIntEvent>(),
          const TypeMatcher<EventSubscriptionBuilder<DomainIntEvent>>(),
        );
      });
    });

    group('dispatch', () {
      const event = DomainIntEvent(123);

      test('it executes the dispatch strategy', () async {
        final handlers = {MockEventHandler<DomainIntEvent>()};

        when(() => mockEventHandlerStore.getHandlersFor<DomainIntEvent>())
            .thenReturn(handlers);

        when(() => mockDispatchStrategy.execute<DomainIntEvent>(
            any(), any(), any())).thenAnswer((_) => Future.value());

        await eventManager.dispatch(event);

        verify(() =>
            mockDispatchStrategy.execute(handlers, event, [mockEventObserver]));
      });

      test('it calls onDispatch', () async {
        final handlers = {MockEventHandler<DomainIntEvent>()};

        when(() => mockEventHandlerStore.getHandlersFor<DomainIntEvent>())
            .thenReturn(handlers);

        when(() => mockDispatchStrategy.execute<DomainIntEvent>(
            any(), any(), any())).thenAnswer((_) => Future.value());

        await eventManager.dispatch(event);

        verify(() => mockEventObserver.onDispatch(event, handlers));
      });
    });
  });
}
