import 'package:dart_event_manager/event_manager.dart';
import 'package:dart_event_manager/src/event/subscription_builder/event_subscription_builder.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../../../mocks.dart';

void main() {
  group('EventSubscriptionBuilder', () {
    late MockEventHandlerStore mockEventHandlerStore;

    setUpAll(() {
      registerFallbackValue(MockEventHandler<int>());
    });

    setUp(() {
      mockEventHandlerStore = MockEventHandlerStore();
    });

    group('expand', () {
      test('it creates a expand instance', () {
        final builder =
            EventSubscriptionBuilder<int>.create(mockEventHandlerStore)
                .expand((i) => [i, i]);

        expect(builder, isNotNull);
      });

      test('it expands the inputs', () async {
        const inputs = [1, 2];
        const expected = [1, 1, 2, 2];
        final outputs = <int>[];

        EventSubscriptionBuilder<int>.create(mockEventHandlerStore)
            .expand((input) => [input, input])
            .subscribeFunction((event) => outputs.add(event));

        final captureResult = verify(
          () => mockEventHandlerStore.register<int>(captureAny()),
        );
        final handler = captureResult.captured.first as EventHandler<int>;

        for (final input in inputs) {
          await handler.handle(input);
        }

        expect(
          outputs,
          expected,
          reason: 'Output should have expanded the original inputs',
        );
      });
    });

    group('asyncExpand', () {
      test('it creates a expand instance', () {
        final builder =
            EventSubscriptionBuilder<int>.create(mockEventHandlerStore)
                .asyncExpand((i) async* {
          yield i;
          yield i;
        });

        expect(builder, isNotNull);
      });

      test('it expands the inputs', () async {
        const inputs = [1, 2];
        const expected = [1, 1, 2, 2];
        final outputs = <int>[];

        EventSubscriptionBuilder<int>.create(mockEventHandlerStore)
            .asyncExpand((input) async* {
          yield input;
          yield input;
        }).subscribeFunction((event) => outputs.add(event));

        final captureResult = verify(
          () => mockEventHandlerStore.register<int>(captureAny()),
        );
        final handler = captureResult.captured.first as EventHandler<int>;

        for (final input in inputs) {
          await handler.handle(input);
        }

        expect(
          outputs,
          expected,
          reason: 'Output should have expanded the original inputs',
        );
      });
    });
  });
}
