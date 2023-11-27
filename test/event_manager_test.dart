import 'package:dart_event_manager/src/event_manager.dart';
import 'package:dart_event_manager/src/event_subscription_builder.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import 'mocks.dart';

void main() {
  group('EventManager', () {
    late EventManager eventManager;
    late MockEventHandlerStore mockEventHandlerStore;

    setUp(() {
      mockEventHandlerStore = MockEventHandlerStore();

      eventManager = EventManager(mockEventHandlerStore);
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

      test('it invokes the handler', () async {
        final handler = MockEventHandler<int>();

        when(() => handler.handle(any())).thenAnswer((_) => Future.value());

        when(() => mockEventHandlerStore.getHandlersFor<int>())
            .thenReturn({handler});

        await eventManager.dispatch(123);

        verify(() => handler.handle(123));
      });

      test('it invokes multiple handlers', () async {
        final handlerA = MockEventHandler<int>();
        final handlerB = MockEventHandler<int>();

        when(() => handlerA.handle(any())).thenAnswer((_) => Future.value());
        when(() => handlerB.handle(any())).thenAnswer((_) => Future.value());

        when(() => mockEventHandlerStore.getHandlersFor<int>())
            .thenReturn({handlerA, handlerB});

        await eventManager.dispatch(123);

        verify(() => handlerA.handle(123));
        verify(() => handlerB.handle(123));
      });
    });
  });
}
