import 'package:dart_mediator/src/request/pipeline/pipeline_behavior_store.dart';
import 'package:test/test.dart';

import '../../../mocks.dart';

void main() {
  group('PipelineBehaviorStore', () {
    late PipelineBehaviorStore pipelineBehaviorStore;

    setUp(() {
      pipelineBehaviorStore = PipelineBehaviorStore();
    });

    group('register', () {
      final mockBehavior = MockPipelineBehavior<int, MockRequest<int>>();

      test('it registers the handler', () {
        expect(
          () => pipelineBehaviorStore.register(mockBehavior),
          returnsNormally,
        );

        expect(
          pipelineBehaviorStore.getPipelines<int, MockRequest<int>>(),
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
          pipelineBehaviorStore.getPipelines<int, MockRequest<int>>(),
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
          pipelineBehaviorStore.getPipelines<int, MockRequest<int>>(),
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
          pipelineBehaviorStore.getPipelines<int, MockRequest<int>>(),
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
          pipelineBehaviorStore.getPipelines<int, MockRequest<int>>(),
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
          pipelineBehaviorStore.getPipelines<int, MockRequest<int>>(),
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
          pipelineBehaviorStore.getPipelines<int, MockRequest<int>>(),
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
          pipelineBehaviorStore.getPipelines<int, MockRequest<int>>(),
          [],
        );
      });
    });

    group('getPipelines{TResponse, TRequest}', () {
      test('it returns the request handler', () {
        final correctBehavior = MockPipelineBehavior<int, MockRequest<int>>();
        final incorrectBehavior =
            MockPipelineBehavior<int, MockRequest<String>>();
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
          pipelineBehaviorStore.getPipelines<int, MockRequest<int>>(),
          [correctBehavior, correctBehavior, logBehavior, logBehavior],
        );
      });
    });
  });
}
