import 'package:dart_mediator/event_manager.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../../../mocks.dart';
import '../../../test_data.dart';

void main() {
  group('SequentialDispatchStrategy', () {
    const strategy = DispatchStrategy.sequential();

    setUpAll(() {
      registerFallbackValue(StackTrace.empty);
    });

    group('execute', () {
      test('it executes all handlers', () async {
        final handlerA = MockEventHandler<DomainIntEvent>();
        final handlerB = MockEventHandler<DomainIntEvent>();
        final handlers = {handlerA, handlerB};
        const event = DomainIntEvent(123);

        when(() => handlerA.handle(event)).thenAnswer((_) => Future.value());
        when(() => handlerA.handle(event)).thenAnswer((_) => Future.value());

        await strategy.execute(handlers, event, []);

        verify(() => handlerA.handle(event));
        verify(() => handlerB.handle(event));
      });

      test('it calls onHandled on observer', () async {
        final handler = MockEventHandler<DomainIntEvent>();
        final observer = MockEventObserver();
        final handlers = {handler};
        const event = DomainIntEvent(123);

        when(() => handler.handle(event)).thenAnswer((_) => Future.value());

        await strategy.execute(handlers, event, [observer]);

        verify(() => observer.onHandled(event, handler));
      });

      test('it calls onError on observer', () async {
        final handler = MockEventHandler<DomainIntEvent>();
        final observer = MockEventObserver();
        final handlers = {handler};
        const event = DomainIntEvent(123);

        when(() => handler.handle(event))
            .thenAnswer((_) async => throw StateError('oops'));

        await expectLater(
          () => strategy.execute(handlers, event, [observer]),
          throwsStateError,
        );

        verify(
          () =>
              observer.onError(event, handler, isStateError, any<StackTrace>()),
        );
      });

      test('it executes all handlers sequentially', () async {
        var count = 0;

        Future<void> handle(DomainIntEvent event) async {
          final newCount = count + event.count;
          await Future.delayed(const Duration(milliseconds: 0));
          count = newCount;
        }

        final handlerA = EventHandler<DomainIntEvent>.function(handle);
        final handlerB = EventHandler<DomainIntEvent>.function(handle);
        final handlerC = EventHandler<DomainIntEvent>.function(handle);

        final handlers = {handlerA, handlerB, handlerC};
        const event = DomainIntEvent(1);

        await strategy.execute(handlers, event, []);

        expect(
          count,
          3,
          reason: 'Each handler should add one to the previous result',
        );
      });
    });
  });
}
