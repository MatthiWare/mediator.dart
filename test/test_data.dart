import 'dart:async';

import 'package:dart_mediator/contracts.dart';
import 'package:dart_mediator/src/request/pipeline/pipeline_behavior.dart';

class DomainIntEvent implements DomainEvent {
  final int count;

  const DomainIntEvent(this.count);

  DomainIntEvent copyWith({
    required int count,
  }) {
    return DomainIntEvent(count);
  }
}

class GetDataQuery implements Query<String> {
  final int id;

  const GetDataQuery(this.id);
}

class WrappingBehavior implements PipelineBehavior {
  final Function() callback;
  WrappingBehavior(this.callback);

  @override
  FutureOr handle(request, RequestHandlerDelegate next) {
    callback();
    return next();
  }
}

class DelayBehavior implements PipelineBehavior {
  @override
  Future handle(request, RequestHandlerDelegate next) async {
    print('$DelayBehavior: Before');
    await Future.delayed(const Duration(milliseconds: 10));
    await next();
    print('$DelayBehavior: After');
  }
}
