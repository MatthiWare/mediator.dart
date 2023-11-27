import 'package:dart_event_manager/event_manager.dart';
import 'package:test/test.dart';

void main() {
  group('EventSubscription', () {
    group('cancel', () {
      test('it cancels the event subscription using the callback', () {
        bool cancelled = false;

        final sub = EventSubscription(() {
          cancelled = true;
        });

        sub.cancel();

        expect(
          cancelled,
          isTrue,
          reason: 'Provided callback needs to be executed on cancel',
        );
      });
    });
  });
}
