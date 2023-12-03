import 'package:dart_event_manager/src/request_pipeline/pipeline_behavior_store.dart';
import 'package:test/test.dart';

import '../mocks.dart';

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
        pipelineBehaviorStore.register(mockGenericBehavior);

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

    group('getPipelines{TResponse, TRequest}', () {
      test('it returns the request handler', () {
        final correctBehavior = MockPipelineBehavior<int, MockRequest<int>>();
        final incorrectBehavior =
            MockPipelineBehavior<int, MockRequest<String>>();
        final logBehavior = MockPipelineBehavior();

        pipelineBehaviorStore.register(correctBehavior);
        pipelineBehaviorStore.registerGeneric(logBehavior);
        pipelineBehaviorStore.register(incorrectBehavior);

        expect(
          pipelineBehaviorStore.getPipelines<int, MockRequest<int>>(),
          [correctBehavior, logBehavior],
        );
      });
    });
  });
}
