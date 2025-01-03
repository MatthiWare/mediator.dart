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

      test('it does not cause concurrent modification error', () async {
        mediator.events.on<DomainIntEvent>().subscribeFunction((event) {
          // While the handlers are being process, register a new one for the
          // event that is currently being processed.
          mediator.events.on<DomainIntEvent>().subscribeFunction((e) {});
        });

        await mediator.events.dispatch(const DomainIntEvent(1));

        late final EventSubscription sub;

        mediator.events.on<DomainIntEvent>().subscribeFunction((event) {
          // While the handlers are being process, unregister the next one for
          // the event that is currently being processed.
          sub.cancel();
        });

        sub = mediator.events.on<DomainIntEvent>().subscribeFunction((e) {});

        await mediator.events.dispatch(const DomainIntEvent(2));
      });

      test('it does not throw when no subscribers for the event', () async {
        await expectLater(
          mediator.events.dispatch(const DomainIntEvent(3)),
          completes,
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

      test('it uses instance and compile event type to dispatch', () async {
        late final bool concreteEventHandled;
        late final bool baseEventHandled;

        mediator.events
            .on<BaseEvent>()
            .subscribeFunction((e) => baseEventHandled = true);

        mediator.events
            .on<ConcreteEvent>()
            .subscribeFunction((e) => concreteEventHandled = true);

        await mediator.events.dispatchBaseEvent(const BaseEvent.concrete());

        expect(
          baseEventHandled,
          isTrue,
          reason: 'Compile type should be used to dispatch events',
        );

        expect(
          concreteEventHandled,
          isTrue,
          reason: 'Instance type should be used to dispatch events',
        );
      });
    });
  });
}

extension _BaseEventExtension on EventManager {
  Future<void> dispatchBaseEvent(BaseEvent event) => dispatch(event);
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
