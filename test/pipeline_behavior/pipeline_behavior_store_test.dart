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
      final mockBehavior = MockPipelineBehavior<int, String>();

      test('it registers the handler', () {
        expect(
          () => pipelineBehaviorStore.register(mockBehavior),
          returnsNormally,
        );

        expect(
          pipelineBehaviorStore.getPipelines<int, String>(),
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
          pipelineBehaviorStore.getPipelines<int, String>(),
          [mockBehavior],
        );
      });
    });

    group('unregister', () {
      final mockBehavior = MockPipelineBehavior<int, String>();
      final mockGenericBehavior = MockPipelineBehavior<int, String>();

      test('it unregisters the behavior', () {
        pipelineBehaviorStore.register(mockBehavior);

        expect(
          () => pipelineBehaviorStore.unregister(mockBehavior),
          returnsNormally,
        );

        expect(
          pipelineBehaviorStore.getPipelines<int, String>(),
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
          pipelineBehaviorStore.getPipelines<int, String>(),
          [],
        );
      });
    });

    group('getPipelines{TResponse, TRequest}', () {
      test('it returns the request handler', () {
        final correctBehavior = MockPipelineBehavior<int, String>();
        final incorrectBehavior = MockPipelineBehavior<int, int>();
        final logBehavior = MockPipelineBehavior();

        pipelineBehaviorStore.register(correctBehavior);
        pipelineBehaviorStore.registerGeneric(logBehavior);
        pipelineBehaviorStore.register(incorrectBehavior);

        expect(
          pipelineBehaviorStore.getPipelines<int, String>(),
          [correctBehavior, logBehavior],
        );
      });
    });
  });
}
