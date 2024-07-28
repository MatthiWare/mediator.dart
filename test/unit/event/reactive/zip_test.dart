import 'package:dart_mediator/event_manager.dart';
import 'package:dart_mediator/src/event/reactive/zip.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../../../mocks.dart';
import '../../../test_data.dart';
import '../utils/test_utils.dart';

void main() {
  group('Reactive', () {
    late MockEventHandlerStore mockEventHandlerStore;

    final eventA = EventA(1);
    final eventB = EventB(2);
    final eventC = EventC(3);
    final eventD = EventD(4);
    final eventE = EventE(5);
    final eventF = EventF(6);
    final eventG = EventG(7);
    final eventH = EventH(8);
    final eventI = EventI(9);

    late TestableEventSubscriptionBuilder<EventA> a;
    late TestableEventSubscriptionBuilder<EventB> b;
    late TestableEventSubscriptionBuilder<EventC> c;
    late TestableEventSubscriptionBuilder<EventD> d;
    late TestableEventSubscriptionBuilder<EventE> e;
    late TestableEventSubscriptionBuilder<EventF> f;
    late TestableEventSubscriptionBuilder<EventG> g;
    late TestableEventSubscriptionBuilder<EventH> h;
    late TestableEventSubscriptionBuilder<EventI> i;

    setUpAll(() {
      registerFallbackValue(MockEventHandler<EventA>());
      registerFallbackValue(MockEventHandler<EventB>());
      registerFallbackValue(MockEventHandler<EventC>());
    });

    setUp(() {
      mockEventHandlerStore = MockEventHandlerStore();

      a = TestableEventSubscriptionBuilder();
      b = TestableEventSubscriptionBuilder();
      c = TestableEventSubscriptionBuilder();
      d = TestableEventSubscriptionBuilder();
      e = TestableEventSubscriptionBuilder();
      f = TestableEventSubscriptionBuilder();
      g = TestableEventSubscriptionBuilder();
      h = TestableEventSubscriptionBuilder();
      i = TestableEventSubscriptionBuilder();
    });

    group('zip', () {
      test('it throws if no events are provided', () {
        expect(
          () => zip([], (events) {}),
          throwsArgumentError,
        );
      });

      test('it returns a builder', () {
        final a = EventSubscriptionBuilder.create(mockEventHandlerStore);
        final b = EventSubscriptionBuilder.create(mockEventHandlerStore);

        final builder = zip([a, b], (events) {});

        expect(builder, isEventSubscriptionBuilder);
      });

      test('it zips the values', () async {
        final a = TestableEventSubscriptionBuilder<EventA>();
        final b = TestableEventSubscriptionBuilder<EventB>();
        final c = TestableEventSubscriptionBuilder<EventC>();

        final values = <String>[];

        zip(
          [
            a.map((e) => e.a),
            b.map((e) => e.b),
            c.map((e) => e.c),
          ],
          (events) => events.join(' '),
        ).subscribeFunction((value) => values.add(value));

        final aHandler = a.handler;
        final bHandler = b.handler;
        final cHandler = c.handler;

        await aHandler.handle(EventA(1));
        await bHandler.handle(EventB(2));
        await cHandler.handle(EventC(3));

        await aHandler.handle(EventA(10));
        await aHandler.handle(EventA(20));
        await bHandler.handle(EventB(10));
        await bHandler.handle(EventB(20));
        await cHandler.handle(EventC(30));

        expect(values, ['1 2 3', '20 20 30']);
      });

      test('it cancels all underlying subscriptions', () {
        final mockBuilder = MockEventSubscriptionBuilder<dynamic>();
        final mockSub = MockEventSubscription();

        when(() => mockBuilder.cast()).thenReturn(mockBuilder);

        when(() => mockBuilder.subscribe(any())).thenReturn(mockSub);

        final sub = zip([mockBuilder], (e) {}).subscribeFunction((e) {});

        sub.cancel();

        verify(() => mockSub.cancel());
      });
    });

    group('zip2', () {
      test('it zips the values', () async {
        zip2(
          a,
          b,
          (a, b) => [a, b],
        ).subscribeFunction(
          (output) => expect(output, [eventA, eventB]),
        );

        await a.handler.handle(eventA);
        await b.handler.handle(eventB);
      });
    });

    group('zip3', () {
      test('it zips the values', () async {
        zip3(
          a,
          b,
          c,
          (a, b, c) => [a, b, c],
        ).subscribeFunction(
          (output) => expect(output, [eventA, eventB, eventC]),
        );

        await a.handler.handle(eventA);
        await b.handler.handle(eventB);
        await c.handler.handle(eventC);
      });
    });

    group('zip4', () {
      test('it zips the values', () async {
        zip4(
          a,
          b,
          c,
          d,
          (a, b, c, d) => [a, b, c, d],
        ).subscribeFunction(
          (output) => expect(output, [eventA, eventB, eventC, eventD]),
        );

        await a.handler.handle(eventA);
        await b.handler.handle(eventB);
        await c.handler.handle(eventC);
        await d.handler.handle(eventD);
      });
    });

    group('zip5', () {
      test('it zips the values', () async {
        zip5(
          a,
          b,
          c,
          d,
          e,
          (a, b, c, d, e) => [a, b, c, d, e],
        ).subscribeFunction(
          (output) => expect(output, [eventA, eventB, eventC, eventD, eventE]),
        );

        await a.handler.handle(eventA);
        await b.handler.handle(eventB);
        await c.handler.handle(eventC);
        await d.handler.handle(eventD);
        await e.handler.handle(eventE);
      });
    });

    group('zip6', () {
      test('it zips the values', () async {
        zip6(
          a,
          b,
          c,
          d,
          e,
          f,
          (a, b, c, d, e, f) => [a, b, c, d, e, f],
        ).subscribeFunction(
          (output) => expect(output, [
            eventA,
            eventB,
            eventC,
            eventD,
            eventE,
            eventF,
          ]),
        );

        await a.handler.handle(eventA);
        await b.handler.handle(eventB);
        await c.handler.handle(eventC);
        await d.handler.handle(eventD);
        await e.handler.handle(eventE);
        await f.handler.handle(eventF);
      });
    });

    group('zip7', () {
      test('it zips the values', () async {
        zip7(
          a,
          b,
          c,
          d,
          e,
          f,
          g,
          (a, b, c, d, e, f, g) => [a, b, c, d, e, f, g],
        ).subscribeFunction(
          (output) => expect(output, [
            eventA,
            eventB,
            eventC,
            eventD,
            eventE,
            eventF,
            eventG,
          ]),
        );

        await a.handler.handle(eventA);
        await b.handler.handle(eventB);
        await c.handler.handle(eventC);
        await d.handler.handle(eventD);
        await e.handler.handle(eventE);
        await f.handler.handle(eventF);
        await g.handler.handle(eventG);
      });
    });

    group('zip8', () {
      test('it zips the values', () async {
        zip8(
          a,
          b,
          c,
          d,
          e,
          f,
          g,
          h,
          (a, b, c, d, e, f, g, h) => [a, b, c, d, e, f, g, h],
        ).subscribeFunction(
          (output) => expect(output, [
            eventA,
            eventB,
            eventC,
            eventD,
            eventE,
            eventF,
            eventG,
            eventH,
          ]),
        );

        await a.handler.handle(eventA);
        await b.handler.handle(eventB);
        await c.handler.handle(eventC);
        await d.handler.handle(eventD);
        await e.handler.handle(eventE);
        await f.handler.handle(eventF);
        await g.handler.handle(eventG);
        await h.handler.handle(eventH);
      });
    });

    group('zip9', () {
      test('it zips the values', () async {
        zip9(
          a,
          b,
          c,
          d,
          e,
          f,
          g,
          h,
          i,
          (a, b, c, d, e, f, g, h, i) => [a, b, c, d, e, f, g, h, i],
        ).subscribeFunction(
          (output) => expect(output, [
            eventA,
            eventB,
            eventC,
            eventD,
            eventE,
            eventF,
            eventG,
            eventH,
            eventI
          ]),
        );

        await a.handler.handle(eventA);
        await b.handler.handle(eventB);
        await c.handler.handle(eventC);
        await d.handler.handle(eventD);
        await e.handler.handle(eventE);
        await f.handler.handle(eventF);
        await g.handler.handle(eventG);
        await h.handler.handle(eventH);
        await i.handler.handle(eventI);
      });
    });
  });
}
