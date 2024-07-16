import 'package:dart_mediator/contracts.dart';
import 'package:meta/meta.dart';

@internal
@immutable
class WrappedEvent<TEvent> implements DomainEvent {
  final TEvent unwrapped;

  const WrappedEvent(this.unwrapped);

  @override
  int get hashCode => Object.hash(runtimeType, unwrapped);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is WrappedEvent<TEvent> &&
            other.unwrapped == unwrapped);
  }
}
