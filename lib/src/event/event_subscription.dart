import 'package:dart_mediator/src/event/handler/event_handler.dart';

/// Can be used to [cancel] the given subscription of a [EventHandler].
class EventSubscription {
  bool _isCanceled = false;

  final void Function() _unsubscribe;

  /// Whether the current subscription has been canceled.
  bool get isCanceled => _isCanceled;

  /// Creates a new [EventSubscription] that will trigger the [_unsubscribe]
  /// on [cancel].
  EventSubscription(this._unsubscribe);

  /// Cancels the current subscription.
  void cancel() {
    assert(
      !isCanceled,
      'Cancel can only be called once.',
    );

    _unsubscribe();
    _isCanceled = true;
  }
}
