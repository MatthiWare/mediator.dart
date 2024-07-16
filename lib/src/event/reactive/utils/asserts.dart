import 'package:dart_mediator/event_manager.dart';
import 'package:dart_mediator/src/event/event_manager.dart';
import 'package:dart_mediator/src/event/interfaces/event_manager_provider.dart';

void assertEventManagersTheSame(List<EventSubscriptionBuilder> builders) {
  final eventManagers =
      builders.map((e) => (e as EventManagerProvider).eventManager).map((e) {
    if (e is EventManagerForked) {
      return e.parent;
    }

    return e;
  }).toList();

  if (eventManagers.isEmpty || eventManagers.length == 1) {
    return;
  }

  final first = eventManagers.first;

  for (final instance in eventManagers) {
    if (first != instance) {
      throw StateError(
        'The provided event subscriptions are not created from the '
        'same `EventManager` instance. \n\n'
        '$instance differs from $first.',
      );
    }
  }
}
