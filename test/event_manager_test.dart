import 'package:dart_event_manager/src/event_handler.dart';
import 'package:dart_event_manager/src/event_manager.dart';
import 'package:dart_event_manager/src/event_subscription_builder.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import 'mocks.dart';

void main() {
  group('EventManager', () {
    late EventManager eventManager;

    setUp(() {
      eventManager = EventManager();
    });

    group('on{T}', () {
      test('it returns a new builder instance', () {
        expect(
          eventManager.on<int>(),
          TypeMatcher<EventSubscriptionBuilder<int>>(),
        );
      });
    });

    group('subscribe', () {
      test('it subscribes to the event', () {
        expect(
          () => eventManager.subscribe(EventHandler<int>.function((event) {})),
          returnsNormally,
        );
      });

      test('it throws when registering the same handler multiple times', () {
        final handler = EventHandler<int>.function((event) {});

        eventManager.subscribe(handler);
        expect(
          () => eventManager.subscribe(handler),
          throwsAssertionError,
        );
      });
    });

    group('unsubscribe', () {
      test('it unsubscribes to the event', () {
        final handler = EventHandler<int>.function((event) {});

        eventManager.subscribe(handler);

        expect(
          () => eventManager.unsubscribe(handler),
          returnsNormally,
        );
      });

      test('it throws when unsubscribing the same handler multiple times', () {
        final handler = EventHandler<int>.function((event) {});

        eventManager.subscribe(handler);
        eventManager.unsubscribe(handler);

        expect(
          () => eventManager.unsubscribe(handler),
          throwsAssertionError,
        );
      });
    });

    group('dispatch', () {
      test('it throws when no subscribers for the event', () async {
        expect(
          () => eventManager.dispatch(123),
          throwsAssertionError,
        );
      });

      test('it invokes the handler', () async {
        final handler = MockEventHandler<int>();

        when(() => handler.handle(any())).thenAnswer((_) => Future.value());

        eventManager.subscribe(handler);

        await eventManager.dispatch(123);

        verify(() => handler.handle(123));
      });

      test('it invokes multiple handlers', () async {
        final handlerA = MockEventHandler<int>();
        final handlerB = MockEventHandler<int>();

        when(() => handlerA.handle(any())).thenAnswer((_) => Future.value());
        when(() => handlerB.handle(any())).thenAnswer((_) => Future.value());

        eventManager.subscribe(handlerA);
        eventManager.subscribe(handlerB);

        await eventManager.dispatch(123);

        verify(() => handlerA.handle(123));
        verify(() => handlerB.handle(123));
      });

      test('it invokes only handlers of the correct type', () async {
        final handlerInt = MockEventHandler<int>();
        final handlerString = MockEventHandler<String>();

        when(() => handlerInt.handle(any())).thenAnswer((_) => Future.value());
        when(() => handlerString.handle(any()))
            .thenAnswer((_) => Future.value());

        eventManager.subscribe(handlerInt);
        eventManager.subscribe(handlerString);

        await eventManager.dispatch(123);

        verify(() => handlerInt.handle(123));
        verifyNever(() => handlerString.handle(any()));
      });

      test('it does not invoke unsubscribed handlers', () async {
        final handlerA = MockEventHandler<int>();
        final handlerB = MockEventHandler<int>();

        when(() => handlerA.handle(any())).thenAnswer((_) => Future.value());
        when(() => handlerB.handle(any())).thenAnswer((_) => Future.value());

        eventManager.subscribe(handlerA);
        eventManager.subscribe(handlerB);

        eventManager.unsubscribe(handlerA);

        await eventManager.dispatch(123);

        verifyNever(() => handlerA.handle(123));
        verify(() => handlerB.handle(123));
      });
    });
  });
}
