import 'package:dart_mediator/src/request/handler/request_handler.dart';
import 'package:dart_mediator/src/request/pipeline/pipeline_behavior.dart';
import 'package:dart_mediator/src/request/request_manager.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../../mocks.dart';
import '../../test_data.dart';

void main() {
  group('RequestsManager', () {
    late RequestManager requestsManager;
    late MockRequestHandlerStore mockRequestHandlerStore;
    late MockPipelineBehaviorStore mockPipelineBehaviorStore;

    setUp(() {
      mockRequestHandlerStore = MockRequestHandlerStore();
      mockPipelineBehaviorStore = MockPipelineBehaviorStore();

      requestsManager = RequestManager(
        requestHandlerStore: mockRequestHandlerStore,
        pipelineBehaviorStore: mockPipelineBehaviorStore,
      );
    });

    setUpAll(() {
      registerFallbackValue(const DomainIntEvent(123));
      registerFallbackValue(MockRequestHandler<String, MockRequest<String>>());
    });

    group('pipeline', () {
      test('it returns the PipelineConfigurator', () {
        expect(
          requestsManager.pipeline,
          mockPipelineBehaviorStore,
        );
      });
    });

    group('register', () {
      test('it registers the handler', () {
        final mockRequestHandler =
            MockRequestHandler<String, MockRequest<String>>();

        requestsManager
            .register<String, MockRequest<String>>(mockRequestHandler);

        verify(() => mockRequestHandlerStore.register(mockRequestHandler));
      });
    });

    group('registerFactory', () {
      test('it registers the handler', () {
        MockRequestHandler<String, MockRequest<String>> factory() =>
            MockRequestHandler();

        requestsManager.registerFactory<String, MockRequest<String>>(
          factory,
        );

        verify(
          () => mockRequestHandlerStore.register<String, MockRequest<String>>(
            RequestHandler.factory(factory),
          ),
        );
      });
    });

    group('registerFunction', () {
      test('it registers the handler', () {
        String handle(MockRequest<String> req) {
          return '123';
        }

        requestsManager.registerFunction<String, MockRequest<String>>(handle);

        verify(
          () => mockRequestHandlerStore.register<String, MockRequest<String>>(
            RequestHandler.function(handle),
          ),
        );
      });
    });

    group('unregister', () {
      test('it unregisters the handler', () {
        final mockRequestHandler =
            MockRequestHandler<String, MockRequest<String>>();

        requestsManager.unregister(mockRequestHandler);

        verify(() => mockRequestHandlerStore.unregister(mockRequestHandler));
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

        when(() => mockRequestHandlerStore.getHandlerFor(mockRequest))
            .thenReturn(mockRequestHandler);

        when(() => mockPipelineBehaviorStore.getPipelines(mockRequest))
            .thenReturn({});

        final result = await requestsManager.send(mockRequest);

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

        when(() => mockRequestHandlerStore.getHandlerFor(mockRequest))
            .thenReturn(mockRequestHandler);

        when(() => mockBehavior.handle(mockRequest, captureAny()))
            .thenAnswer((invocation) async {
          invoked = true;

          final handler = invocation.positionalArguments[1]
              as RequestHandlerDelegate<String>;

          return handler();
        });

        when(() => mockPipelineBehaviorStore.getPipelines(mockRequest))
            .thenReturn({mockBehavior});

        final result = await requestsManager.send(mockRequest);

        verify(() => mockRequestHandler.handle(mockRequest));

        expect(
          result,
          output,
          reason: 'Should return the handler response',
        );

        expect(invoked, isTrue);
      });

      test('it handles the request with multiple behaviors', () async {
        final mockBehavior =
            MockPipelineBehavior<String, MockRequest<String>>();

        int invoked = 0;

        when(() => mockRequestHandler.handle(mockRequest)).thenReturn(output);

        when(() => mockRequestHandlerStore.getHandlerFor(mockRequest))
            .thenReturn(mockRequestHandler);

        when(() => mockBehavior.handle(mockRequest, captureAny()))
            .thenAnswer((invocation) async {
          invoked++;

          final handler = invocation.positionalArguments[1]
              as RequestHandlerDelegate<String>;

          return handler();
        });

        final behavior1 = PipelineBehavior.factory(() => mockBehavior);
        final behavior2 = PipelineBehavior.factory(() => mockBehavior);

        when(() => mockPipelineBehaviorStore.getPipelines(mockRequest))
            .thenReturn({behavior1, behavior2});

        final result = await requestsManager.send(mockRequest);

        verify(() => mockRequestHandler.handle(mockRequest));

        expect(
          result,
          output,
          reason: 'Should return the handler response',
        );

        expect(invoked, 2);
      });

      test('it throws when pipeline is misconfigured', () async {
        final mockWrongBehavior = MockPipelineBehavior();

        when(() => mockRequestHandler.handle(mockRequest)).thenReturn(output);

        when(() => mockRequestHandlerStore.getHandlerFor(mockRequest))
            .thenReturn(mockRequestHandler);

        when(() => mockWrongBehavior.handle(mockRequest, captureAny()))
            .thenAnswer((invocation) async {
          final handler = invocation.positionalArguments[1]
              as RequestHandlerDelegate<String>;

          await handler(); // don't return on purpose
        });

        when(() => mockPipelineBehaviorStore.getPipelines(mockRequest))
            .thenReturn({mockWrongBehavior});

        await expectLater(
          () => requestsManager.send(mockRequest),
          throwsAssertionError,
        );
      });
    });

    group('sendStream', () {
      const output = '123';
      late MockRequest<String> mockRequest;
      late MockRequestHandler<String, MockRequest<String>> mockRequestHandler;

      setUp(() {
        mockRequest = MockRequest<String>();
        mockRequestHandler = MockRequestHandler<String, MockRequest<String>>();
      });

      test('it handles the request', () async {
        when(() => mockRequestHandler.handle(mockRequest)).thenReturn(output);

        when(() => mockRequestHandlerStore.getHandlerFor(mockRequest))
            .thenReturn(mockRequestHandler);

        when(() => mockPipelineBehaviorStore.getPipelines(mockRequest))
            .thenReturn({});

        final inputStream = Stream.value(mockRequest);

        final result = await requestsManager.sendStream(inputStream).toList();

        verify(() => mockRequestHandler.handle(mockRequest));

        expect(
          result.first,
          output,
          reason: 'Should return the handler response',
        );
      });
    });
  });
}
