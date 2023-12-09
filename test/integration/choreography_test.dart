import 'dart:async';

import 'package:dart_event_manager/contracts.dart';
import 'package:dart_event_manager/event_manager.dart';
import 'package:dart_event_manager/src/request/handler/request_handler.dart';
import 'package:dart_event_manager/src/request/pipeline/pipeline_behavior.dart';
import 'package:test/test.dart';

late Mediator mediator;
late Inventory inventory;
late List<String> events;

void main() {
  group('Mediator', () {
    setUp(() {
      mediator = Mediator();
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
          PlaceOrderCommand(
            '123',
            {'mouse': 2, 'keyboard': 1},
          ),
        );

        expect(inventory.inventory, {
          'mouse': 8,
          'keyboard': 9,
        });
      });
    });
  });
}

class Inventory {
  final Map<String, int> inventory;

  const Inventory(this.inventory);

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
    print('$LoggingBehavior: Handeling ${request.runtimeType}');
    await next();
    print('$LoggingBehavior: ${request.runtimeType} completed');
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

class PlaceOrderCommand implements Command {
  final String orderId;
  final Map<String, int> items;

  const PlaceOrderCommand(this.orderId, this.items);
}

class PlaceOrderCommandHandler
    implements RequestHandler<void, PlaceOrderCommand> {
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
}

class InventoryAdjustedEventHandler
    implements EventHandler<InventoryAdjustedEvent> {
  @override
  FutureOr<void> handle(InventoryAdjustedEvent event) {
    final itemId = event.itemId;
    final adjustment = event.adjustment;
    final after = event.after;

    print('Item $itemId adjusted by $adjustment new stock $after');
  }
}
