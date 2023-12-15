import 'dart:async';

import 'package:dart_mediator/mediator.dart';
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
  final Mediator mediator = Mediator();

  mediator.requests.pipeline.registerGeneric(LoggingBehavior());

  mediator.requests.register(RequestEventHandler());

  mediator.events
      .on<Event>()
      .map((event) => event.data)
      .distinct()
      .subscribeFunction((event) => prints('[$Event handler] received $event'));

  final resp =
      await mediator.requests.send<String, RequestEvent>(RequestEvent(123));

  print('Got ${resp.runtimeType} -> $resp');

  await mediator.events.dispatch(Event(123));

  print('done');
}
