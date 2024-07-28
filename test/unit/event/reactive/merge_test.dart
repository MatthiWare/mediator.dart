import 'package:dart_mediator/event_manager.dart';
import 'package:dart_mediator/src/event/reactive/merge.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../../../mocks.dart';
import '../../../test_data.dart';
import '../utils/test_utils.dart';

void main() {
  group('Reactive', () {
    group('merge', () {
      late MockEventHandlerStore mockEventHandlerStore;

      setUpAll(() {
        registerFallbackValue(MockEventHandler<EventA>());
        registerFallbackValue(MockEventHandler<EventB>());
        registerFallbackValue(MockEventHandler<EventC>());
      });

      setUp(() {
        mockEventHandlerStore = MockEventHandlerStore();
      });

      test('it throws if no events are provided', () {
        expect(
          () => merge([]),
          throwsArgumentError,
        );
      });

      test('it returns a builder', () {
        final a = EventSubscriptionBuilder.create(mockEventHandlerStore);
        final b = EventSubscriptionBuilder.create(mockEventHandlerStore);

        final builder = merge([a, b]);

        expect(builder, isEventSubscriptionBuilder);
      });

      test('it merges the values', () async {
        final a = TestableEventSubscriptionBuilder<EventA>();
        final b = TestableEventSubscriptionBuilder<EventB>();
        final c = TestableEventSubscriptionBuilder<EventC>();

        final values = <int>[];

        merge([
          a.map((e) => e.a),
          b.map((e) => e.b),
          c.map((e) => e.c),
        ]).subscribeFunction((value) => values.add(value));

        final aHandler = a.handler;
        final bHandler = b.handler;
        final cHandler = c.handler;

        await aHandler.handle(EventA(1));
        await bHandler.handle(EventB(2));
        await cHandler.handle(EventC(3));
        await cHandler.handle(EventC(3));
        await bHandler.handle(EventB(2));
        await aHandler.handle(EventA(1));

        expect(values, [1, 2, 3, 3, 2, 1]);
      });

      test('it cancels all underlying subscriptions', () {
        final mockBuilder = MockEventSubscriptionBuilder<EventA>();
        final mockSub = MockEventSubscription();

        when(() => mockBuilder.subscribe(any())).thenReturn(mockSub);

        final sub = merge([mockBuilder]).subscribeFunction((e) {});

        sub.cancel();

        verify(() => mockSub.cancel());
      });
    });
  });
}
