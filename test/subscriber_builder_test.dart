import 'package:dart_event_manager/src/subscriber_builder.dart';
import 'package:test/test.dart';

import 'mocks.dart';

void main() {
  group('SubscriberBulder', () {
    test('it creates an instance', () {
      final builder = SubscriberBuilder.create(MockEventManager());

      expect(builder, isNotNull);
    });

    test('it creates a mapped instance', () {
      final builder = SubscriberBuilder.create(MockEventManager()).map(
        (event) => 123,
      );

      expect(builder, isNotNull);
    });
  });
}
