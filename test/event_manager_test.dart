import 'package:dart_event_manager/src/event_manager.dart';
import 'package:dart_event_manager/src/event_subscription_builder.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import 'mocks.dart';

void main() {
  group('EventManager', () {
    late EventManager eventManager;
    late MockEventHandlerStore mockEventHandlerStore;
    late MockDispatchStrategy mockDispatchStrategy;

    setUp(() {
      mockEventHandlerStore = MockEventHandlerStore();
      mockDispatchStrategy = MockDispatchStrategy();

      eventManager = EventManager(mockEventHandlerStore, mockDispatchStrategy);
    });

    group('on{T}', () {
      test('it returns a new builder instance', () {
        expect(
          eventManager.on<int>(),
          TypeMatcher<EventSubscriptionBuilder<int>>(),
        );
      });
    });

    group('dispatch', () {
      test('it throws when no subscribers for the event', () async {
        when(() => mockEventHandlerStore.getHandlersFor<int>())
            .thenReturn(const {});

        expect(
          () => eventManager.dispatch(123),
          throwsAssertionError,
        );
      });

      test('it executes the dispatch strategy', () async {
        final handlers = {MockEventHandler<int>()};

        when(() => mockEventHandlerStore.getHandlersFor<int>())
            .thenReturn(handlers);

        when(() => mockDispatchStrategy.execute<int>(any(), any()))
            .thenAnswer((_) => Future.value());

        await eventManager.dispatch(123);

        verify(() => mockDispatchStrategy.execute(handlers, 123));
      });
    });
  });
}
