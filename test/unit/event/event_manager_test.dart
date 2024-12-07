import 'package:dart_mediator/src/event/event_manager.dart';
import 'package:dart_mediator/src/event/handler/event_handler.dart';
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
        final Set<EventHandler> handlers = {MockEventHandler<DomainIntEvent>()};

        when(() => mockEventHandlerStore.getHandlersFor(DomainIntEvent))
            .thenReturn(handlers);

        when(() => mockDispatchStrategy.execute(any(), any(), any()))
            .thenAnswer((_) => Future.value());

        await eventManager.dispatch(event);

        verify(() =>
            mockDispatchStrategy.execute(handlers, event, [mockEventObserver]));
      });

      test('it calls onDispatch', () async {
        final Set<EventHandler> handlers = {MockEventHandler<DomainIntEvent>()};

        when(() => mockEventHandlerStore.getHandlersFor(DomainIntEvent))
            .thenReturn(handlers);

        when(() => mockDispatchStrategy.execute(any(), any(), any()))
            .thenAnswer((_) => Future.value());

        await eventManager.dispatch(event);

        verify(() => mockEventObserver.onDispatch(event, handlers));
      });

      test('it gets both runtime and compile time handlers', () async {
        final Set<MockEventHandler> baseHandlers = {
          MockEventHandler<BaseEvent>()
        };

        final Set<MockEventHandler> concreteHandlers = {
          MockEventHandler<ConcreteEvent>()
        };

        final combined = {...baseHandlers, ...concreteHandlers};

        when(() => mockEventHandlerStore.getHandlersFor(BaseEvent))
            .thenReturn(baseHandlers);

        when(() => mockEventHandlerStore.getHandlersFor(ConcreteEvent))
            .thenReturn(concreteHandlers);

        when(() => mockDispatchStrategy.execute(any(), any(), any()))
            .thenAnswer((_) => Future.value());

        const event = BaseEvent.concrete();

        await eventManager.dispatch(event);

        verify(() => mockEventObserver.onDispatch(event, combined));
        verify(() =>
            mockDispatchStrategy.execute(combined, event, [mockEventObserver]));
      });
    });
  });
}
