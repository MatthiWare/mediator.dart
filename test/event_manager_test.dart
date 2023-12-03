import 'package:dart_event_manager/src/event_manager.dart';
import 'package:dart_event_manager/src/event_subscription_builder.dart';
import 'package:dart_event_manager/src/request_pipeline/pipeline_behavior.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import 'mocks.dart';

void main() {
  group('EventManager', () {
    late EventManager eventManager;
    late MockEventHandlerStore mockEventHandlerStore;
    late MockRequestHandlerStore mockRequestHandlerStore;
    late MockPipelineBehaviorStore mockPipelineBehaviorStore;
    late MockDispatchStrategy mockDispatchStrategy;

    setUp(() {
      mockEventHandlerStore = MockEventHandlerStore();
      mockRequestHandlerStore = MockRequestHandlerStore();
      mockPipelineBehaviorStore = MockPipelineBehaviorStore();
      mockDispatchStrategy = MockDispatchStrategy();

      eventManager = EventManager(
        mockEventHandlerStore,
        mockRequestHandlerStore,
        mockPipelineBehaviorStore,
        mockDispatchStrategy,
      );
    });

    group('pipeline', () {
      test('it returns the PipelineConfigurator', () {
        expect(
          eventManager.pipeline,
          mockPipelineBehaviorStore,
        );
      });
    });

    group('send{TResponse, TRequest}', () {
      test('it handles the request', () async {
        const input = 123;
        const output = '123';
        final mockRequestHandler = MockRequestHandler<String, int>();

        when(() => mockRequestHandler.handle(input)).thenReturn(output);

        when(() => mockRequestHandlerStore.getHandlerFor<String, int>())
            .thenReturn(mockRequestHandler);

        when(() => mockPipelineBehaviorStore.getPipelines<String, int>())
            .thenReturn([]);

        final result = await eventManager.send<String, int>(input);

        // final x = await eventManager.send(123);

        verify(() => mockRequestHandler.handle(input));

        expect(
          result,
          output,
          reason: 'Should return the handler response',
        );
      });

      test('it handles the request with behaviors', () async {
        const input = 123;
        const output = '123';
        final mockRequestHandler = MockRequestHandler<String, int>();
        final mockBehavior = MockPipelineBehavior<String, int>();

        bool invoked = false;

        when(() => mockRequestHandler.handle(input)).thenReturn(output);

        when(() => mockRequestHandlerStore.getHandlerFor<String, int>())
            .thenReturn(mockRequestHandler);

        when(() => mockBehavior.handle(input, captureAny()))
            .thenAnswer((invocation) async {
          invoked = true;

          final handler = invocation.positionalArguments[1]
              as RequestHandlerDelegate<String>;

          return handler();
        });

        when(() => mockPipelineBehaviorStore.getPipelines<String, int>())
            .thenReturn([mockBehavior]);

        final result = await eventManager.send<String, int>(input);

        verify(() => mockRequestHandler.handle(input));

        expect(
          result,
          output,
          reason: 'Should return the handler response',
        );

        expect(invoked, isTrue);
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
