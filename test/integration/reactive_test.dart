import 'dart:async';

import 'package:dart_mediator/event_manager.dart';
import 'package:dart_mediator/reactive.dart';
import 'package:test/test.dart';

import '../test_data.dart';
import 'choreography_test.dart';

void main() {
  group('Reactive', () {
    late EventManager eventManager;

    setUp(() {
      eventManager = EventManager.create(
        observers: [LoggingEventObserver()],
        defaultDispatchStrategy: const DispatchStrategy.sequential(),
      );
    });

    group('combineLatest', () {
      Future<void> sendEvents() async {
        await eventManager.dispatch(EventA(1));
        await eventManager.dispatch(EventA(2));

        await eventManager.dispatch(EventB(1));

        await eventManager.dispatch(EventC(1));

        await eventManager.dispatch(EventA(3));
        await eventManager.dispatch(EventB(2));
        await eventManager.dispatch(EventC(2));
      }

      test('it combines the latest emitted values', () async {
        final combined = combineLatest3(
          eventManager.on<EventA>(),
          eventManager.on<EventB>(),
          eventManager.on<EventC>(),
          (a, b, c) => 'a: ${a.a} b: ${b.b} c: ${c.c}',
        );

        final results = <String>[];

        combined.subscribeFunction((e) => results.add(e));

        await sendEvents();

        expect(results, [
          'a: 2 b: 1 c: 1',
          'a: 3 b: 1 c: 1',
          'a: 3 b: 2 c: 1',
          'a: 3 b: 2 c: 2'
        ]);
      });
    });

    group('zip', () {
      Future<void> sendEvents() async {
        await eventManager.dispatch(EventA(1));
        await eventManager.dispatch(EventA(2));

        await eventManager.dispatch(EventS('A'));
        await eventManager.dispatch(EventS('B'));
        await eventManager.dispatch(EventS('C'));
        await eventManager.dispatch(EventS('D'));

        await eventManager.dispatch(EventA(3));
        await eventManager.dispatch(EventA(4));
      }

      test('it zips the latest emitted values', () async {
        final zipped = zip2(
          eventManager.on<EventA>(),
          eventManager.on<EventS>(),
          (a, s) => '${a.a}${s.s}',
        );

        final results = <String>[];

        zipped.subscribeFunction((e) => results.add(e));

        await sendEvents();

        expect(results, [
          '1A',
          '2B',
          '3C',
          '4D',
        ]);
      });
    });

    group('merge', () {
      Future<void> sendEvents() async {
        await eventManager.dispatch(EventA(1));
        await eventManager.dispatch(EventA(2));

        await eventManager.dispatch(EventB(1));

        await eventManager.dispatch(EventC(1));

        await eventManager.dispatch(EventA(3));
        await eventManager.dispatch(EventB(2));
        await eventManager.dispatch(EventC(2));
      }

      test('it merges the emitted values', () async {
        final merged = merge([
          eventManager.on<EventA>().map((e) => 'a: ${e.a}'),
          eventManager.on<EventB>().map((e) => 'b: ${e.b}'),
          eventManager.on<EventC>().map((e) => 'c: ${e.c}'),
        ]);

        final results = <String>[];

        merged.subscribeFunction((e) => results.add(e));

        await sendEvents();

        expect(results, [
          'a: 1',
          'a: 2',
          'b: 1',
          'c: 1',
          'a: 3',
          'b: 2',
          'c: 2',
        ]);
      });
    });
  });
}
