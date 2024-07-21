import 'package:dart_mediator/src/event/handler/event_handler.dart';

/// Canceled callback function.
typedef CancelCallback = void Function();

/// Can be used to [cancel] the given subscription of a [EventHandler].
class EventSubscription {
  bool _isCanceled = false;

  final CancelCallback _unsubscribe;

  final _onCancelCallbacks = List<CancelCallback>.empty(growable: true);

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

    for (final callback in _onCancelCallbacks) {
      callback();
    }
  }

  /// Adds a callback [callback] that will be invoked when [cancel] is called.
  void doOnCancel(CancelCallback callback) {
    assert(
      !isCanceled,
      'This subscription was already canceled.',
    );

    _onCancelCallbacks.add(callback);
  }
}
