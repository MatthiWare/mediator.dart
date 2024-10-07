# Mediator.dart

[![Dart](https://github.com/MatthiWare/mediator.dart/actions/workflows/dart.yml/badge.svg?branch=master)](https://github.com/MatthiWare/mediator.dart/actions/workflows/dart.yml)
[![pub package](https://img.shields.io/pub/v/dart_mediator.svg?label=dart_mediator&color=blue)](https://pub.dartlang.org/packages/dart_mediator)
[![codecov](https://codecov.io/gh/MatthiWare/mediator.dart/graph/badge.svg?token=W1WQDQEZIJ)](https://codecov.io/gh/MatthiWare/mediator.dart)

# Description

A Mediator implementation for Dart inspired by [MediatR](https://github.com/jbogard/MediatR).

This package provides a simple yet configurable solution.

## Features

- [x] Request/Response
- [x] Commands
- [x] Request/Command Pipelines
- [x] Events
- [x] Event Observers

## Sending events

An event can have multiple handlers. All handlers will be executed in parallel (by default).

```dart
import 'package:dart_mediator/mediator.dart';

/// Strongly typed event class containing the event data.
/// All events must implement the [DomainEvent] interface.
class MyEvent implements DomainEvent {}

Future<void> main() async {
  final mediator = Mediator.create();

  // Subscribe to the event.
  mediator.events.on<MyEvent>()
    .subscribeFunction(
      (event) => print('event received'),
    );

  // Sends the event to all handlers.
  // This will print 'event received'.
  await mediator.events.dispatch(MyEvent());
}
```

## Sending Commands

A command can only have one handler and doesn't return a value.

```dart
/// This command will not return a value.
class MyCommand implements Command {}

class MyCommandHandler implements CommandHandler<MyCommand> {
  @override
  FutureOr<void> handle(MyCommand request) {
    // Do something
  }
}

Future<void> main() async {
  final mediator = Mediator.create();

  mediator.requests.register(MyCommandHandler());

  /// Sends the command request. Return value is [void].
  await mediator.requests.send(MyCommand());
}
```

## Sending Requests

A request can only have one handler and returns a value.

```dart
import 'package:dart_mediator/mediator.dart';

class Something {}

/// This query will return a [Something] object.
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

  // Sends the query request and returns the response.
  final Something response = await mediator.requests.send(MyQuery());

  print(response);
}
```

## Event Observers

An observer can be used to observe events being dispatched, handled or when an error occurs. For example logging events.

```dart
class LoggingEventObserver implements EventObserver {

  /// Called when an event is dispatched but before any handlers have
  /// been called.
  @override
  void onDispatch<TEvent extends DomainEvent>(
    TEvent event,
    Set<EventHandler<TEvent>> handlers,
  ) {
    print(
      '[LoggingEventObserver] onDispatch "$event" with ${handlers.length} handlers',
    );
  }

  /// Called when an event returned an error for a given handler.
  @override
  void onError<TEvent extends DomainEvent>(
    TEvent event,
    EventHandler<TEvent> handler,
    Object error,
    StackTrace stackTrace,
  ) {
    print('[LoggingEventObserver] onError $event -> $handler ($error)');
  }

  /// Called when an event has been handled by a handler.
  @override
  void onHandled<TEvent extends DomainEvent>(
    TEvent event,
    EventHandler<TEvent> handler,
  ) {
    print('[LoggingEventObserver] onHandled $event -> $handler');
  }
}

void main() {
  final mediator = Mediator.create(
    // Adds the logging event observer.
    observers: [LoggingEventObserver()],
  );

  // Dispatch an event.
}

```

## Request/Command Pipeline Behavior

A pipeline behavior can be used to add cross cutting concerns to requests/commands. For example logging.

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
