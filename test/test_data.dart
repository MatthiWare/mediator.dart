import 'package:dart_event_manager/contracts.dart';

class DomainIntEvent implements DomainEvent {
  final int count;

  const DomainIntEvent(this.count);

  DomainIntEvent copyWith({
    required int count,
  }) {
    return DomainIntEvent(count);
  }
}
