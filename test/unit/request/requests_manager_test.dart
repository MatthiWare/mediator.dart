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
    });

    group('pipeline', () {
      test('it returns the PipelineConfigurator', () {
        expect(
          requestsManager.pipeline,
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

        final result = await requestsManager
            .send<String, MockRequest<String>>(mockRequest);

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

        final result = await requestsManager
            .send<String, MockRequest<String>>(mockRequest);

        verify(() => mockRequestHandler.handle(mockRequest));

        expect(
          result,
          output,
          reason: 'Should return the handler response',
        );

        expect(invoked, isTrue);
      });
    });
  });
}
