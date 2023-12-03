import 'dart:async';

import 'package:dart_event_manager/contracts.dart';
import 'package:dart_event_manager/event_manager.dart';
import 'package:dart_event_manager/src/event_subscription_builder.dart';
import 'package:dart_event_manager/src/request_handler/request_handler.dart';
import 'package:dart_event_manager/src/request_pipeline/pipeline_behavior.dart';
import 'package:test/test.dart';

class Event implements DomainEvent {
  final int data;
  const Event(this.data);
}

class RequestEvent implements Query<String> {
  final int data;
  const RequestEvent(this.data);
}

class RequestEventHandler implements RequestHandler<String, RequestEvent> {
  @override
  FutureOr<String> handle(RequestEvent request) {
    // throw UnimplementedError("oops");
    return request.data.toString();
  }
}

class LoggingBehavior implements PipelineBehavior {
  @override
  FutureOr handle(request, RequestHandlerDelegate next) async {
    try {
      print('[$LoggingBehavior] [${request.runtimeType}] Before');
      return await next();
    } finally {
      print('[$LoggingBehavior] [${request.runtimeType}] After');
    }
  }
}

Future<void> main() async {
  final EventManager mediator = EventManager();

  mediator.pipeline.registerGeneric(LoggingBehavior());

  mediator.register(RequestEventHandler());

  mediator
      .on<Event>()
      .map((event) => event.data)
      .distinct()
      .subscribeFunction((event) => prints('[$Event handler] received $event'));

  final resp = await mediator.send<String, RequestEvent>(RequestEvent(123));

  print('Got ${resp.runtimeType} -> $resp');

  await mediator.dispatch(Event(123));

  print('done');
}
