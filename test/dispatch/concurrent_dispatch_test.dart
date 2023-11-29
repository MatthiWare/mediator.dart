import 'package:dart_event_manager/event_manager.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../mocks.dart';

void main() {
  group('ConcurrentDispatchStrategy', () {
    const strategy = DispatchStrategy.concurrent();

    group('execute', () {
      test('it executes all handlers', () async {
        final handlerA = MockEventHandler<int>();
        final handlerB = MockEventHandler<int>();
        final handlers = {handlerA, handlerB};
        const event = 123;

        when(() => handlerA.handle(event)).thenAnswer((_) => Future.value());
        when(() => handlerA.handle(event)).thenAnswer((_) => Future.value());

        await strategy.execute(handlers, event);

        verify(() => handlerA.handle(event));
        verify(() => handlerB.handle(event));
      });

      test('it executes all handlers concurrently', () async {
        var count = 0;

        Future<void> handle(int event) async {
          final newCount = count + event;
          await Future.delayed(const Duration(milliseconds: 0));
          count = newCount;
        }

        final handlerA = EventHandler<int>.function(handle);
        final handlerB = EventHandler<int>.function(handle);
        final handlerC = EventHandler<int>.function(handle);

        final handlers = {handlerA, handlerB, handlerC};
        const event = 1;

        await strategy.execute(handlers, event);

        expect(
          count,
          1,
          reason: 'Each handler should start at the same time',
        );
      });
    });
  });
}
