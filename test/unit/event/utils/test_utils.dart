import 'package:dart_mediator/event_manager.dart';
import 'package:mocktail/mocktail.dart';

import '../../../mocks.dart';

EventHandler<T> getRegisteredEventHandler<T>(MockEventHandlerStore store) {
  final captureResult = verify(
    () => store.register<T>(captureAny()),
  );

  return captureResult.captured.first as EventHandler<T>;
}

class TestableEventSubscriptionBuilder<T> extends EventSubscriptionBuilder<T> {
  late final EventHandler<T> handler;

  @override
  EventSubscription subscribe(EventHandler<T> handler) {
    this.handler = handler;
    return MockEventSubscription();
  }
}
