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
      });

      test('it throws when registering the same handler multiple times', () {
        pipelineBehaviorStore.register(mockBehavior);
        expect(
          () => pipelineBehaviorStore.register(mockBehavior),
          throwsAssertionError,
        );
      });
    });

    group('unregister', () {
      final mockBehavior = MockPipelineBehavior<int, String>();

      test('it unsubscribes to the event', () {
        pipelineBehaviorStore.register(mockBehavior);

        expect(
          () => pipelineBehaviorStore.unregister(mockBehavior),
          returnsNormally,
        );
      });

      test('it throws when unsubscribing the same handler multiple times', () {
        pipelineBehaviorStore.register(mockBehavior);
        pipelineBehaviorStore.unregister(mockBehavior);

        expect(
          () => pipelineBehaviorStore.unregister(mockBehavior),
          throwsAssertionError,
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
