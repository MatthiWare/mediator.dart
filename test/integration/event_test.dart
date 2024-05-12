import 'dart:async';

import 'package:dart_mediator/mediator.dart';
import 'package:test/test.dart';

import '../test_data.dart';

void main() {
  group('Mediator', () {
    late Mediator mediator;

    setUp(() {
      mediator = Mediator.create();
    });

    group('events', () {
      test('it unsubscribes from the event', () async {
        final results = <int>[];
        final sub =
            mediator.events.on<DomainIntEvent>().subscribeFunction((event) {
          results.add(event.count);
        });
        mediator.events.on<DomainIntEvent>().subscribeFunction((event) {
          results.add(event.count);
        });

        sub.cancel();

        await mediator.events.dispatch(const DomainIntEvent(1));

        expect(
          results,
          [1],
        );
      });

      test('it handles the event', () async {
        final results = <int>[];
        mediator.events
            .on<DomainIntEvent>()
            .asyncMap((event) async {
              await Future.delayed(const Duration(milliseconds: 10));
              return ('id', event);
            })
            .map((event) => event.$2.count)
            .expand((element) => [element, element])
            .where((event) => event > 10)
            .distinct()
            .subscribeFunction((event) async {
              await Future.delayed(const Duration(milliseconds: 10));
              results.add(event);
            });

        final events = Iterable.generate(20, (index) => index);

        for (final event in events.skip(10)) {
          await mediator.events.dispatch(DomainIntEvent(event));
        }

        expect(
          results,
          [11, 12, 13, 14, 15, 16, 17, 18, 19],
        );
      });

      test('it handles multiple events', () async {
        final handler1 = <int>[];
        mediator.events
            .on<DomainIntEvent>()
            .map((event) => event.count)
            .where((event) => event > 10)
            .subscribeFunction((event) async {
          await Future.delayed(const Duration(milliseconds: 10));
          handler1.add(event);
        });

        final handler2 = <int>[];
        mediator.events
            .on<DomainIntEvent>()
            .map((event) => event.count)
            .where((event) => event > 10)
            .subscribeFunction((event) async {
          await Future.delayed(const Duration(milliseconds: 10));
          handler2.add(event);
        });

        final handler3 = <int>[];
        EventHandler<int> factory() => EventHandler<int>.function(
              (event) async {
                await Future.delayed(const Duration(milliseconds: 10));
                handler3.add(event);
              },
            );

        mediator.events
            .on<DomainIntEvent>()
            .map((event) => event.count)
            .where((event) => event > 10)
            .subscribeFactory(factory);

        final eventHandler = _CollectingEventSubscriber();

        mediator.events
            .on<DomainIntEvent>()
            .where((event) => event.count > 10)
            .subscribe(eventHandler);

        final events = Iterable.generate(20, (index) => index);

        for (final event in events.skip(10)) {
          await mediator.events.dispatch(DomainIntEvent(event));
        }

        const expected = [11, 12, 13, 14, 15, 16, 17, 18, 19];

        expect(handler1, expected);
        expect(handler2, expected);
        expect(handler3, expected);
        expect(eventHandler.events, expected);
      });
    });
  });
}

class _CollectingEventSubscriber implements EventHandler<DomainIntEvent> {
  final events = <int>[];

  @override
  void handle(DomainIntEvent event) {
    if (event.count > 10) {
      events.add(event.count);
    }
  }
}
