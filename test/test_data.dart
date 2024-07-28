import 'dart:async';

import 'package:dart_mediator/contracts.dart';
import 'package:dart_mediator/request_manager.dart';
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

class GenericSyncBehavior implements PipelineBehavior {
  @override
  FutureOr handle(request, RequestHandlerDelegate next) {
    print('GenericSyncBehavior: Before');
    return next();
  }
}

class GetDataQueryHandlerAsync implements QueryHandler<String, GetDataQuery> {
  @override
  Future<String> handle(GetDataQuery request) async {
    await Future.delayed(const Duration(milliseconds: 10));
    return request.id.toString();
  }
}

class GetDataQueryHandlerSync implements QueryHandler<String, GetDataQuery> {
  @override
  String handle(GetDataQuery request) {
    return request.id.toString();
  }
}

class GetDataQueryHandlerBehaviorAsync
    implements PipelineBehavior<String, GetDataQuery> {
  @override
  FutureOr<String> handle(
    GetDataQuery request,
    RequestHandlerDelegate<String> next,
  ) async {
    try {
      await Future.delayed(Duration.zero);
      return await next();
    } catch (e) {
      return 'error';
    }
  }
}

class GetDataQueryHandlerBehaviorSync
    implements PipelineBehavior<String, GetDataQuery> {
  @override
  FutureOr<String> handle(
    GetDataQuery request,
    RequestHandlerDelegate<String> next,
  ) {
    try {
      return next();
    } catch (e) {
      return 'error';
    }
  }
}

class EventA implements DomainEvent {
  final int a;

  EventA(this.a);

  @override
  String toString() => 'EventA(a: $a)';
}

class EventB implements DomainEvent {
  final int b;

  EventB(this.b);

  @override
  String toString() => 'EventB(b: $b)';
}

class EventC implements DomainEvent {
  final int c;

  EventC(this.c);

  @override
  String toString() => 'EventC(c: $c)';
}

class EventD implements DomainEvent {
  final int d;

  EventD(this.d);

  @override
  String toString() => 'EventD(d: $d)';
}

class EventE implements DomainEvent {
  final int e;

  EventE(this.e);

  @override
  String toString() => 'EventE(e: $e)';
}

class EventF implements DomainEvent {
  final int f;

  EventF(this.f);

  @override
  String toString() => 'EventF(f: $f)';
}

class EventG implements DomainEvent {
  final int g;

  EventG(this.g);

  @override
  String toString() => 'EventG(g: $g)';
}

class EventH implements DomainEvent {
  final int h;

  EventH(this.h);

  @override
  String toString() => 'EventH(h: $h)';
}

class EventI implements DomainEvent {
  final int i;

  EventI(this.i);

  @override
  String toString() => 'EventI(i: $i)';
}
