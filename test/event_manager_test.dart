import 'package:dart_event_manager/src/event_manager.dart';
import 'package:dart_event_manager/src/event_subscription_builder.dart';
import 'package:dart_event_manager/src/request_pipeline/pipeline_behavior.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import 'mocks.dart';
import 'test_data.dart';

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
        eventHandlerStore: mockEventHandlerStore,
        requestHandlerStore: mockRequestHandlerStore,
        pipelineBehaviorStore: mockPipelineBehaviorStore,
        defaultEventDispatchStrategy: mockDispatchStrategy,
      );
    });

    setUpAll(() {
      registerFallbackValue(const DomainIntEvent(123));
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
      const output = '123';
      late MockRequest<String> mockRequest;
      late MockRequestHandler<String, MockRequest<String>> mockRequestHandler;

      setUp(() {
        mockRequest = MockRequest<String>();
        mockRequestHandler = MockRequestHandler<String, MockRequest<String>>();
      });

      test('it handles the request', () async {
        when(() => mockRequestHandler.handle(mockRequest)).thenReturn(output);

        when(() => mockRequestHandlerStore
                .getHandlerFor<String, MockRequest<String>>())
            .thenReturn(mockRequestHandler);

        when(() => mockPipelineBehaviorStore
            .getPipelines<String, MockRequest<String>>()).thenReturn([]);

        final result =
            await eventManager.send<String, MockRequest<String>>(mockRequest);

        verify(() => mockRequestHandler.handle(mockRequest));

        expect(
          result,
          output,
          reason: 'Should return the handler response',
        );
      });

      test('it handles the request with behaviors', () async {
        final mockBehavior =
            MockPipelineBehavior<String, MockRequest<String>>();

        bool invoked = false;

        when(() => mockRequestHandler.handle(mockRequest)).thenReturn(output);

        when(() => mockRequestHandlerStore
                .getHandlerFor<String, MockRequest<String>>())
            .thenReturn(mockRequestHandler);

        when(() => mockBehavior.handle(mockRequest, captureAny()))
            .thenAnswer((invocation) async {
          invoked = true;

          final handler = invocation.positionalArguments[1]
              as RequestHandlerDelegate<String>;

          return handler();
        });

        when(() => mockPipelineBehaviorStore
                .getPipelines<String, MockRequest<String>>())
            .thenReturn([mockBehavior]);

        final result =
            await eventManager.send<String, MockRequest<String>>(mockRequest);

        verify(() => mockRequestHandler.handle(mockRequest));

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
