import 'package:dart_mediator/src/request/pipeline/pipeline_behavior_store.dart';
import 'package:test/test.dart';

import '../../../mocks.dart';

void main() {
  group('PipelineBehaviorStore', () {
    late PipelineBehaviorStore pipelineBehaviorStore;
    late MockRequest<int> mockRequest;

    setUp(() {
      pipelineBehaviorStore = PipelineBehaviorStore();
      mockRequest = MockRequest();
    });

    group('register', () {
      final mockBehavior = MockPipelineBehavior<int, MockRequest<int>>();

      test('it registers the handler', () {
        expect(
          () => pipelineBehaviorStore.register(mockBehavior),
          returnsNormally,
        );

        expect(
          pipelineBehaviorStore.getPipelines(mockRequest),
          [mockBehavior],
        );
      });
    });

    group('registerFactory', () {
      final mockBehavior = MockPipelineBehavior<int, MockRequest<int>>();

      test('it registers the factory handler', () {
        expect(
          () => pipelineBehaviorStore.registerFactory(() => mockBehavior),
          returnsNormally,
        );

        expect(
          pipelineBehaviorStore.getPipelines(mockRequest),
          [mockBehavior],
        );
      });
    });

    group('registerGeneric', () {
      final mockBehavior = MockPipelineBehavior();

      test('it registers the handler', () {
        expect(
          () => pipelineBehaviorStore.registerGeneric(mockBehavior),
          returnsNormally,
        );

        expect(
          pipelineBehaviorStore.getPipelines(mockRequest),
          [mockBehavior],
        );
      });
    });

    group('registerGenericFactory', () {
      final mockBehavior = MockPipelineBehavior();

      test('it registers the handler', () {
        expect(
          () =>
              pipelineBehaviorStore.registerGenericFactory(() => mockBehavior),
          returnsNormally,
        );

        expect(
          pipelineBehaviorStore.getPipelines(mockRequest),
          [mockBehavior],
        );
      });
    });

    group('unregister', () {
      final mockBehavior = MockPipelineBehavior<int, MockRequest<int>>();
      final mockGenericBehavior = MockPipelineBehavior<int, MockRequest<int>>();

      test('it unregisters the behavior', () {
        pipelineBehaviorStore.register(mockBehavior);

        expect(
          () => pipelineBehaviorStore.unregister(mockBehavior),
          returnsNormally,
        );

        expect(
          pipelineBehaviorStore.getPipelines(mockRequest),
          [],
        );
      });
      test('it unregisters the generic behavior', () {
        pipelineBehaviorStore.registerGeneric(mockGenericBehavior);

        expect(
          () => pipelineBehaviorStore.unregister(mockGenericBehavior),
          returnsNormally,
        );

        expect(
          pipelineBehaviorStore.getPipelines(mockRequest),
          [],
        );
      });
    });

    group('unregisterFactory', () {
      mockBehaviorFactory() => MockPipelineBehavior<int, MockRequest<int>>();
      mockGenericBehaviorFactory() =>
          MockPipelineBehavior<int, MockRequest<int>>();

      test('it unregisters the behavior', () {
        pipelineBehaviorStore.registerFactory(mockBehaviorFactory);

        expect(
          () => pipelineBehaviorStore.unregisterFactory(mockBehaviorFactory),
          returnsNormally,
        );

        expect(
          pipelineBehaviorStore.getPipelines(mockRequest),
          [],
        );
      });
      test('it unregisters the generic behavior', () {
        pipelineBehaviorStore
            .registerGenericFactory(mockGenericBehaviorFactory);

        expect(
          () => pipelineBehaviorStore
              .unregisterFactory(mockGenericBehaviorFactory),
          returnsNormally,
        );

        expect(
          pipelineBehaviorStore.getPipelines(mockRequest),
          [],
        );
      });
    });

    group('getPipelines', () {
      test('it returns the correct pipelines for the given request', () {
        final correctBehavior = MockPipelineBehavior<int, MockRequest<int>>();
        final incorrectBehavior =
            MockPipelineBehavior<String, MockRequest<String>>();
        final logBehavior = MockPipelineBehavior();

        correctFactory() => correctBehavior;
        incorrectFactory() => incorrectBehavior;
        logBehaviorFactory() => logBehavior;

        pipelineBehaviorStore.register(correctBehavior);
        pipelineBehaviorStore.registerFactory(correctFactory);
        pipelineBehaviorStore.registerGeneric(logBehavior);
        pipelineBehaviorStore.registerGenericFactory(logBehaviorFactory);
        pipelineBehaviorStore.register(incorrectBehavior);
        pipelineBehaviorStore.registerFactory(incorrectFactory);

        expect(
          pipelineBehaviorStore.getPipelines(mockRequest),
          [correctBehavior, correctBehavior, logBehavior, logBehavior],
        );
      });
    });
  });
}
