import 'dart:async';

import 'package:dart_mediator/mediator.dart';
import 'package:test/test.dart';

late Mediator mediator;
late Inventory inventory;
late List<String> events;

void main() {
  group('Mediator', () {
    setUp(() {
      mediator = Mediator.create(
        observers: [LoggingEventObserver()],
      );
      inventory = Inventory({
        'mouse': 10,
        'keyboard': 10,
      });
      events = [];
    });

    group('choreography', () {
      test('it places the order', () async {
        // Requests
        mediator.requests.register(PlaceOrderCommandHandler());
        mediator.requests.register(GetInventoryQueryHandler());
        mediator.requests.pipeline.register(PlaceOrderValidationBehavior());
        mediator.requests.pipeline.registerGeneric(LoggingBehavior());

        // Events
        mediator.events
            .on<OrderPlacedEvent>()
            .subscribe(OrderPlacedEventHandler());
        mediator.events
            .on<InventoryAdjustedEvent>()
            .subscribe(InventoryAdjustedEventHandler());

        // Start flow
        await mediator.requests.send(
          const PlaceOrderCommand(
            '123',
            {'mouse': 2, 'keyboard': 1},
          ),
        );

        final stock = await mediator.requests.send(GetInventoryQuery());

        expect(stock, {
          'mouse': 8,
          'keyboard': 9,
        });
      });

      test('it does not place the failed order', () async {
        // Requests
        mediator.requests.register(PlaceOrderCommandHandler());
        mediator.requests.register(GetInventoryQueryHandler());
        mediator.requests.pipeline.register(PlaceOrderValidationBehavior());
        mediator.requests.pipeline.registerGeneric(LoggingBehavior());

        // Events
        mediator.events
            .on<OrderPlacedEvent>()
            .subscribe(OrderPlacedEventHandler());
        mediator.events
            .on<InventoryAdjustedEvent>()
            .subscribe(InventoryAdjustedEventHandler());

        // Start flow
        await expectLater(
          mediator.requests.send(
            const PlaceOrderCommand(
              '123',
              {'mouse': 20, 'keyboard': 10},
            ),
          ),
          throwsStateError,
        );
      });
    });
  });
}

class Inventory {
  final Map<String, int> inventory;

  Inventory(this.inventory);

  bool hasEnough(String item, int amount) {
    final stock = inventory[item]!;

    return stock >= amount;
  }

  int adjust(String item, int amount) {
    return inventory.update(
      item,
      (value) => value + amount,
    );
  }
}

class LoggingBehavior implements PipelineBehavior {
  @override
  FutureOr handle(request, RequestHandlerDelegate next) async {
    try {
      print('$LoggingBehavior: Handling $request');
      return await next();
    } finally {
      print('$LoggingBehavior: $request completed');
    }
  }
}

class PlaceOrderValidationBehavior
    implements PipelineBehavior<void, PlaceOrderCommand> {
  @override
  Future<void> handle(
    PlaceOrderCommand request,
    RequestHandlerDelegate<void> next,
  ) async {
    for (final order in request.items.entries) {
      if (!inventory.hasEnough(order.key, order.value)) {
        throw StateError('Not enough ${order.key} in stock');
      }
    }

    await next();
  }
}

class GetInventoryQuery implements Query<Map<String, int>> {
  GetInventoryQuery();

  @override
  String toString() => '$GetInventoryQuery';
}

class GetInventoryQueryHandler
    implements QueryHandler<Map<String, int>, GetInventoryQuery> {
  @override
  Future<Map<String, int>> handle(GetInventoryQuery query) async {
    return inventory.inventory;
  }
}

class PlaceOrderCommand implements Command {
  final String orderId;
  final Map<String, int> items;

  const PlaceOrderCommand(this.orderId, this.items);

  @override
  String toString() => '$PlaceOrderCommand(orderId: $orderId, items: $items)';
}

class PlaceOrderCommandHandler implements CommandHandler<PlaceOrderCommand> {
  @override
  Future<void> handle(PlaceOrderCommand request) async {
    await mediator.events.dispatch(
      OrderPlacedEvent(request.orderId, request.items),
    );
  }
}

class OrderPlacedEvent implements DomainEvent {
  final String orderId;
  final Map<String, int> items;

  const OrderPlacedEvent(this.orderId, this.items);

  @override
  String toString() => '$OrderPlacedEvent(orderId: $orderId, items: $items)';
}

class OrderPlacedEventHandler implements EventHandler<OrderPlacedEvent> {
  @override
  Future<void> handle(OrderPlacedEvent event) async {
    for (final order in event.items.entries) {
      final itemId = order.key;
      final adjustment = -order.value;
      final newStockAmount = inventory.adjust(itemId, adjustment);

      await mediator.events.dispatch(
        InventoryAdjustedEvent(itemId, adjustment, newStockAmount),
      );
    }
  }
}

class InventoryAdjustedEvent implements DomainEvent {
  final String itemId;
  final int adjustment;
  final int after;

  const InventoryAdjustedEvent(
    this.itemId,
    this.adjustment,
    this.after,
  );

  @override
  String toString() =>
      '$InventoryAdjustedEvent(itemId: $itemId, adjustment: $adjustment, after: $after)';
}

class InventoryAdjustedEventHandler
    implements EventHandler<InventoryAdjustedEvent> {
  @override
  FutureOr<void> handle(InventoryAdjustedEvent event) {
    final itemId = event.itemId;
    final adjustment = event.adjustment;
    final after = event.after;

    print(
        '$InventoryAdjustedEventHandler: Item $itemId adjusted by $adjustment new stock $after');
  }
}

class LoggingEventObserver implements EventObserver {
  @override
  void onDispatch<TEvent>(
    TEvent event,
    Set<EventHandler> handlers,
  ) {
    print(
      '$LoggingEventObserver: onDispatch $event with ${handlers.length} handlers',
    );
  }

  @override
  void onError<TEvent>(
    TEvent event,
    EventHandler handler,
    Object error,
    StackTrace stackTrace,
  ) {
    print(
        '$LoggingEventObserver: onError $event -> ${handler.runtimeType} ($error)');
  }

  @override
  void onHandled<TEvent>(
    TEvent event,
    EventHandler handler,
  ) {
    print('$LoggingEventObserver: onHandled $event -> ${handler.runtimeType}');
  }
}
