# Mediator.dart

[![Dart](https://github.com/MatthiWare/mediator.dart/actions/workflows/dart.yml/badge.svg?branch=master)](https://github.com/MatthiWare/mediator.dart/actions/workflows/dart.yml)

# Description

A Mediator implementation for Dart inspired by [MediatR](https://github.com/jbogard/MediatR).

This package provides a simple yet configurable solution.

## Features

- [x] Request/Response
- [x] Pipelines
- [x] Events

## Sending events

An event can have multiple handlers. All handlers will be executed in parallel (by default).

```dart
import 'package:dart_mediator/mediator.dart';

class MyEvent extends DomainEvent {}

Future<void> main() async {
  final mediator = Mediator.create();

  mediator.events.on<MyEvent>()
    .subscribeFunction(
      (event) => print('event received'),
    );

  await mediator.events.dispatch(MyEvent());
}
```

## Sending Requests

A request can only have one handler.

```dart
import 'package:dart_mediator/mediator.dart';

class Something {}

class MyQuery implements Query<Something> {}

class MyQueryHandler implements QueryHandler<Something, MyQuery> {
  @override
  FutureOr<Something> handle(MyQuery request) {
    // do something
    return Something();
  }
}

Future<void> main() async {
  final mediator = Mediator.create();

  mediator.requests.register(MyQueryHandler());

  final response = await mediator.requests
    .send<Something, MyQuery>(MyQuery());

  print(response);
}
```

## Add event logging

An observer can be used to log events being dispatched and handled.

```dart
class LoggingEventObserver implements EventObserver {
  @override
  void onDispatch<TEvent extends DomainEvent>(
    TEvent event,
    Set<EventHandler<TEvent>> handlers,
  ) {
    print(
      '[$LoggingEventObserver] onDispatch "$event" with ${handlers.length} handlers',
    );
  }

  @override
  void onError<TEvent extends DomainEvent>(
    TEvent event,
    EventHandler<TEvent> handler,
    Object error,
    StackTrace stackTrace,
  ) {
    print('[$LoggingEventObserver] onError $event -> $handler ($error)');
  }

  @override
  void onHandled<TEvent extends DomainEvent>(
    TEvent event,
    EventHandler<TEvent> handler,
  ) {
    print('[$LoggingEventObserver] onHandled $event -> $handler');
  }
}

void main() {
  final mediator = Mediator.create(
    observers: [LoggingEventObserver()],
  );

  // do something
}

```

## Request pipeline behavior

A pipeline behavior can be used to add cross cutting concerns to requests. For example logging.

```dart

class LoggingBehavior implements PipelineBehavior {
  @override
  Future handle(request, RequestHandlerDelegate next) async {
    try {
      print('[$LoggingBehavior] [${request.runtimeType}] Before');
      return await next();
    } finally {
      print('[$LoggingBehavior] [${request.runtimeType}] After');
    }
  }
}

void main() {
    final mediator = Mediator.create();

    // add logging behavior
    mediator.requests.pipeline.registerGeneric(LoggingBehavior());
}
```

## Credits

- [MediatR](https://github.com/jbogard/MediatR)
