import 'package:dart_event_manager/event_manager.dart';
import 'package:dart_event_manager/src/subscriber_builder.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import 'mocks.dart';

void main() {
  group('SubscriberBulder', () {
    late MockEventManager mockEventManager;

    setUpAll(() {
      registerFallbackValue(MockEventHandler<String>());
      registerFallbackValue(MockEventHandler<int>());
    });

    setUp(() {
      mockEventManager = MockEventManager();
    });

    group('create', () {
      test('it creates an instance', () {
        final builder = SubscriberBuilder.create(mockEventManager);

        expect(builder, isNotNull);
      });
    });

    group('map', () {
      test('it creates a mapped instance', () {
        final builder = SubscriberBuilder.create(mockEventManager).map(
          (event) => 123,
        );

        expect(builder, isNotNull);
      });

      test('it executes the mapped value', () {
        const expected = 1234;
        late final int output;

        SubscriberBuilder<String>.create(mockEventManager)
            .map((event) => expected)
            .subscribeFunction((event) => output = event);

        final captureResult = verify(
          () => mockEventManager.subscribe<String>(captureAny()),
        );
        final handler = captureResult.captured.first as EventHandler<String>;

        handler.handle('not 1234');

        expect(
          output,
          expected,
          reason: 'Output should have been mapped',
        );
      });
    });

    group('where', () {
      test('it creates a where instance', () {
        final builder = SubscriberBuilder<int>.create(mockEventManager).where(
          (event) => event > 0,
        );

        expect(builder, isNotNull);
      });

      test('it only executes when the where condition is true', () {
        const expected = [0, 55, 99];
        final outputs = <int>[];

        SubscriberBuilder<int>.create(mockEventManager)
            .where((event) => event < 100)
            .subscribeFunction((event) => outputs.add(event));

        final captureResult = verify(
          () => mockEventManager.subscribe<int>(captureAny()),
        );
        final handler = captureResult.captured.first as EventHandler<int>;

        handler.handle(1000);
        handler.handle(0);
        handler.handle(100);
        handler.handle(55);
        handler.handle(99);
        handler.handle(333);

        expect(
          outputs,
          expected,
          reason: 'Output should have only values <100',
        );
      });
    });
  });
}
