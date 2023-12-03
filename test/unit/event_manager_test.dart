import 'package:dart_event_manager/src/mediator.dart';
import 'package:dart_event_manager/src/event_subscription_builder.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../mocks.dart';
import '../test_data.dart';

void main() {
  group('EventManager', () {
    late Mediator eventManager;
    late MockEventHandlerStore mockEventHandlerStore;
    late MockRequestManager mockRequestManager;
    late MockDispatchStrategy mockDispatchStrategy;

    setUp(() {
      mockEventHandlerStore = MockEventHandlerStore();
      mockRequestManager = MockRequestManager();
      mockDispatchStrategy = MockDispatchStrategy();

      eventManager = Mediator(
        eventHandlerStore: mockEventHandlerStore,
        requestManager: mockRequestManager,
        defaultEventDispatchStrategy: mockDispatchStrategy,
      );
    });

    setUpAll(() {
      registerFallbackValue(const DomainIntEvent(123));
    });

    group('requests', () {
      test('it returns the RequestManager', () {
        expect(
          eventManager.requests,
          mockRequestManager,
        );
      });
    });

    group('on{T}', () {
      test('it returns a new builder instance', () {
        expect(
          eventManager.on<DomainIntEvent>(),
          TypeMatcher<EventSubscriptionBuilder<DomainIntEvent>>(),
        );
      });
    });

    group('dispatch', () {
      const event = DomainIntEvent(123);
      test('it throws when no subscribers for the event', () async {
        when(() => mockEventHandlerStore.getHandlersFor<DomainIntEvent>())
            .thenReturn(const {});

        expect(
          () => eventManager.dispatch(event),
          throwsAssertionError,
        );
      });

      test('it executes the dispatch strategy', () async {
        final handlers = {MockEventHandler<DomainIntEvent>()};

        when(() => mockEventHandlerStore.getHandlersFor<DomainIntEvent>())
            .thenReturn(handlers);

        when(() => mockDispatchStrategy.execute<DomainIntEvent>(any(), any()))
            .thenAnswer((_) => Future.value());

        await eventManager.dispatch(event);

        verify(() => mockDispatchStrategy.execute(handlers, event));
      });
    });
  });
}
