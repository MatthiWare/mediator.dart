import 'dart:async';

import 'package:dart_mediator/contracts.dart';
import 'package:dart_mediator/src/request/pipeline/pipeline_behavior.dart';
import 'package:meta/meta.dart';

@immutable
class DomainIntEvent implements DomainEvent {
  final int count;

  const DomainIntEvent(this.count);

  DomainIntEvent copyWith({
    required int count,
  }) {
    return DomainIntEvent(count);
  }

  @override
  int get hashCode => Object.hash(runtimeType, count);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is DomainIntEvent &&
            other.count == count);
  }
}

@immutable
class GetDataQuery implements Query<String> {
  final int id;

  const GetDataQuery(this.id);

  @override
  int get hashCode => Object.hash(runtimeType, id);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is GetDataQuery &&
            other.id == id);
  }
}

class DelayBehavior implements PipelineBehavior {
  @override
  Future handle(request, RequestHandlerDelegate next) async {
    try {
      print('$DelayBehavior: Before');
      await Future.delayed(const Duration(milliseconds: 10));
      return await next();
    } finally {
      print('$DelayBehavior: After');
    }
  }
}
