import 'package:dart_event_manager/event_manager.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _CallbackMock extends Mock {
  void call();
}

void main() {
  group('EventSubscription', () {
    group('cancel', () {
      test('it cancels the event subscription using the callback', () {
        final callbackMock = _CallbackMock();

        final sub = EventSubscription(callbackMock.call);

        sub.cancel();

        verify(() => callbackMock.call());
      });
    });
  });
}
