import 'package:dart_mediator/request_manager.dart';
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

      test('it registers the behavior', () {
        expect(
          () => pipelineBehaviorStore.register(mockBehavior),
          returnsNormally,
        );

        expect(
          pipelineBehaviorStore.getPipelines(mockRequest),
          [mockBehavior],
        );
      });

      test('it throws when the behavior was already registered', () {
        expect(
          () => pipelineBehaviorStore.register(mockBehavior),
          returnsNormally,
        );

        expect(
          () => pipelineBehaviorStore.register(mockBehavior),
          throwsAssertionError,
        );
      });
    });

    group('registerGenericFunction', () {
      final behavior = MockPipelineBehavior();

      test('it registers the generic function behavior', () {
        expect(
          () => pipelineBehaviorStore.registerGenericFunction(behavior.handle),
          returnsNormally,
        );

        expect(
          pipelineBehaviorStore.getPipelines(mockRequest),
          [PipelineBehavior.function(behavior.handle)],
        );
      });
    });

    group('registerFactory', () {
      MockPipelineBehavior<int, MockRequest<int>> factory() =>
          MockPipelineBehavior();

      test('it registers the factory behavior', () {
        expect(
          () => pipelineBehaviorStore.registerFactory(factory),
          returnsNormally,
        );

        expect(
          pipelineBehaviorStore.getPipelines(mockRequest),
          [PipelineBehavior.factory(factory)],
        );
      });
    });

    group('registerFunction', () {
      final behavior = MockPipelineBehavior<int, MockRequest<int>>();

      test('it registers the function behavior', () {
        expect(
          () => pipelineBehaviorStore.registerFunction(behavior.handle),
          returnsNormally,
        );

        expect(
          pipelineBehaviorStore.getPipelines(mockRequest),
          [PipelineBehavior.function(behavior.handle)],
        );
      });
    });

    group('registerGeneric', () {
      final mockBehavior = MockPipelineBehavior();

      test('it registers the behavior', () {
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
      MockPipelineBehavior factory() => MockPipelineBehavior();

      test('it registers the behavior', () {
        expect(
          () => pipelineBehaviorStore.registerGenericFactory(factory),
          returnsNormally,
        );

        expect(
          pipelineBehaviorStore.getPipelines(mockRequest),
          [PipelineBehavior.factory(factory)],
        );
      });
    });

    group('unregister', () {
      final mockBehavior = MockPipelineBehavior<int, MockRequest<int>>();

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

      test('it throws when behavior type does not exist', () {
        expect(
          () => pipelineBehaviorStore.unregister(mockBehavior),
          throwsAssertionError,
        );
      });

      test('it throws when the behavior does not exist', () {
        pipelineBehaviorStore.register(mockBehavior);

        expect(
          () => pipelineBehaviorStore.unregister(mockBehavior),
          returnsNormally,
        );

        expect(
          () => pipelineBehaviorStore.unregister(mockBehavior),
          throwsAssertionError,
        );
      });
    });

    group('unregisterFunction', () {
      final behavior = MockPipelineBehavior<int, MockRequest<int>>();

      test('it unregisters the behavior', () {
        pipelineBehaviorStore.registerFunction(behavior.handle);

        expect(
          () => pipelineBehaviorStore
              .unregister(PipelineBehavior.function(behavior.handle)),
          returnsNormally,
        );

        expect(
          pipelineBehaviorStore.getPipelines(mockRequest),
          [],
        );
      });
    });

    group('unregisterFactory', () {
      MockPipelineBehavior<int, MockRequest<int>> mockBehaviorFactory() =>
          MockPipelineBehavior<int, MockRequest<int>>();

      test('it unregisters the behavior', () {
        pipelineBehaviorStore.registerFactory(mockBehaviorFactory);

        expect(
          () => pipelineBehaviorStore
              .unregister(PipelineBehavior.factory(mockBehaviorFactory)),
          returnsNormally,
        );

        expect(
          pipelineBehaviorStore.getPipelines(mockRequest),
          [],
        );
      });
    });

    group('unregisterGeneric', () {
      final mockGenericBehavior = MockPipelineBehavior();

      test('it unregisters the behavior', () {
        pipelineBehaviorStore.registerGeneric(mockGenericBehavior);

        expect(
          () => pipelineBehaviorStore.unregisterGeneric(mockGenericBehavior),
          returnsNormally,
        );

        expect(
          pipelineBehaviorStore.getPipelines(mockRequest),
          [],
        );
      });

      test('it throws when behavior does not exist', () {
        expect(
          () => pipelineBehaviorStore.unregisterGeneric(mockGenericBehavior),
          throwsAssertionError,
        );
      });
    });

    group('getPipelines', () {
      test('it returns the correct pipelines for the given request', () {
        final correctBehavior = MockPipelineBehavior<int, MockRequest<int>>();
        final incorrectBehavior =
            MockPipelineBehavior<String, MockRequest<String>>();
        final logBehavior = MockPipelineBehavior();

        MockPipelineBehavior<int, MockRequest<int>> correctFactory() =>
            correctBehavior;
        MockPipelineBehavior<String, MockRequest<String>> incorrectFactory() =>
            incorrectBehavior;
        MockPipelineBehavior logBehaviorFactory() => logBehavior;

        pipelineBehaviorStore.register(correctBehavior);
        pipelineBehaviorStore.registerFunction(correctBehavior.handle);
        pipelineBehaviorStore.registerFactory(correctFactory);
        pipelineBehaviorStore.registerGeneric(logBehavior);
        pipelineBehaviorStore.registerGenericFunction(logBehavior.handle);
        pipelineBehaviorStore.registerGenericFactory(logBehaviorFactory);

        // Will not be returned in the getPipelines call.
        pipelineBehaviorStore.register(incorrectBehavior);
        pipelineBehaviorStore.registerFactory(incorrectFactory);
        pipelineBehaviorStore.registerFunction(incorrectBehavior.handle);

        expect(
          pipelineBehaviorStore.getPipelines(mockRequest),
          [
            correctBehavior,
            PipelineBehavior.function(correctBehavior.handle),
            PipelineBehavior.factory(correctFactory),
            logBehavior,
            PipelineBehavior.function(logBehavior.handle),
            PipelineBehavior.factory(logBehaviorFactory),
          ],
        );
      });
    });
  });
}
