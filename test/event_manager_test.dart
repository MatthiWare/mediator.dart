import 'package:dart_event_manager/src/event_manager.dart';
import 'package:dart_event_manager/src/event_subscription_builder.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import 'mocks.dart';

void main() {
  group('EventManager', () {
    late EventManager eventManager;
    late MockEventHandlerStore mockEventHandlerStore;
    late MockRequestHandlerStore mockRequestHandlerStore;
    late MockDispatchStrategy mockDispatchStrategy;

    setUp(() {
      mockEventHandlerStore = MockEventHandlerStore();
      mockRequestHandlerStore = MockRequestHandlerStore();
      mockDispatchStrategy = MockDispatchStrategy();

      eventManager = EventManager(
        mockEventHandlerStore,
        mockRequestHandlerStore,
        mockDispatchStrategy,
      );
    });

    group('send{TResponse, TRequest}', () {
      test('it handles the request', () async {
        const input = 123;
        const output = '123';
        final mockRequestHandler = MockRequestHandler<String, int>();

        when(() => mockRequestHandler.handle(input)).thenReturn(output);

        when(() => mockRequestHandlerStore.getHandlerFor<String, int>())
            .thenReturn(mockRequestHandler);

        final result = await eventManager.send<String, int>(input);

        verify(() => mockRequestHandler.handle(input));

        expect(
          result,
          output,
          reason: 'Should return the handler response',
        );
      });
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
