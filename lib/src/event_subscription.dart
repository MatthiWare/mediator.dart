import 'package:dart_event_manager/src/event_handler/event_handler.dart';

/// Can be used to [cancel] the given subscription of a [EventHandler].
class EventSubscription {
  final void Function() _unsubscribe;

  const EventSubscription(this._unsubscribe);

  void cancel() => _unsubscribe();
}
