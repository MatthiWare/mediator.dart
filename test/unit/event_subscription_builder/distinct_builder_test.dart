import 'package:dart_event_manager/event_manager.dart';
import 'package:dart_event_manager/src/event_subscription_builder.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../../mocks.dart';

class _TestEvent {
  final int _hashCode;

  _TestEvent(this._hashCode);

  @override
  int get hashCode => _hashCode;

  @override
  bool operator ==(Object other) {
    return false;
  }
}

void main() {
  group('EventSubscriptionBuilder', () {
    late MockEventHandlerStore mockEventHandlerStore;

    setUpAll(() {
      registerFallbackValue(MockEventHandler<String>());
      registerFallbackValue(MockEventHandler<int>());
      registerFallbackValue(MockEventHandler<_TestEvent>());
    });

    setUp(() {
      mockEventHandlerStore = MockEventHandlerStore();
    });

    group('distinct', () {
      test('it creates a distinct instance', () {
        final builder =
            EventSubscriptionBuilder<int>.create(mockEventHandlerStore)
                .distinct();

        expect(builder, isNotNull);
      });

      test('it only executes when the event was distinct', () {
        const inputs = [2, 6, 6, 8, 12, 8, 8, 2];
        const expected = [2, 6, 8, 12, 8, 2];
        final outputs = <int>[];

        EventSubscriptionBuilder<int>.create(mockEventHandlerStore)
            .distinct()
            .subscribeFunction((event) => outputs.add(event));

        final captureResult = verify(
          () => mockEventHandlerStore.register<int>(captureAny()),
        );
        final handler = captureResult.captured.first as EventHandler<int>;

        for (final input in inputs) {
          handler.handle(input);
        }

        expect(
          outputs,
          expected,
          reason: 'Output should have only distinct values',
        );
      });

      test('it overrides equals', () {
        final a = _TestEvent(1);
        final b = _TestEvent(2);
        final inputs = [a, a, b, b];
        final outputs = <_TestEvent>[];

        EventSubscriptionBuilder<_TestEvent>.create(mockEventHandlerStore)
            .distinct((curr, prev) => curr.hashCode == prev.hashCode)
            .subscribeFunction((event) => outputs.add(event));

        final captureResult = verify(
          () => mockEventHandlerStore.register<_TestEvent>(captureAny()),
        );
        final handler =
            captureResult.captured.first as EventHandler<_TestEvent>;

        for (final input in inputs) {
          handler.handle(input);
        }

        expect(
          outputs.length,
          2,
          reason: 'Should use hashcode as equals function',
        );
      });
    });
  });
}
