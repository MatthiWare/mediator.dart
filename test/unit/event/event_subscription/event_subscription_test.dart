import 'package:dart_mediator/event_manager.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../../../mocks.dart';

void main() {
  group('EventSubscription', () {
    group('isCanceled', () {
      test('it returns canceled state', () {
        final sub = EventSubscription(() {});

        expect(
          sub.isCanceled,
          isFalse,
          reason: 'isCanceled should return false when not canceled',
        );

        sub.cancel();

        expect(
          sub.isCanceled,
          isTrue,
          reason: 'isCanceled should return true when canceled',
        );
      });
    });

    group('cancel', () {
      test('it throws when it was already canceled', () {
        final sub = EventSubscription(() {});

        sub.cancel();

        expect(
          () => sub.cancel(),
          throwsAssertionError,
        );
      });

      test('it cancels the event subscription using the callback', () {
        final callbackMock = CallbackMock();

        final sub = EventSubscription(callbackMock.call);

        sub.cancel();

        verify(() => callbackMock.call());
      });
    });
  });
}
