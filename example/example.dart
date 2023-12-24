import 'dart:async';

import 'package:dart_mediator/mediator.dart';

Future<void> main() async {
  final mediator = Mediator.create(
    observers: [LoggingEventObserver()],
  );

  // Add a request logging behavior.
  mediator.requests.pipeline.registerGeneric(LoggingBehavior());

  // Register a request handlers.
  mediator.requests.register(GetUserByIdQueryHandler());
  mediator.requests.register(MyCommandHandler());

  // Subscribe to the count event.
  mediator.events
      .on<CountEvent>()
      .map((event) => event.count)
      .distinct()
      .subscribeFunction(
        (count) => print('[$CountEvent handler] received count: $count'),
      );

  const getUserQuery = GetUserByIdQuery(123);

  print('Sending $getUserQuery request');

  final resp = await mediator.requests.send(getUserQuery);

  print('Got $GetUserByIdQuery response: $resp');

  print('---');

  const order66Command = MyCommand('Order 66');

  print('Sending command $order66Command');

  await mediator.requests.send(order66Command);

  print('Command $order66Command completed');

  print('---');

  const countEvent = CountEvent(123);

  await mediator.events.dispatch(countEvent);

  await mediator.events.dispatch(countEvent);

  print('done');
}

class CountEvent implements DomainEvent {
  final int count;
  const CountEvent(this.count);

  @override
  String toString() => '$CountEvent(count: $count)';
}

class MyCommand implements Command {
  final String command;
  const MyCommand(this.command);

  @override
  String toString() => '$MyCommand(command: $command)';
}

class MyCommandHandler implements CommandHandler<MyCommand> {
  @override
  Future<void> handle(MyCommand request) async {
    print('[$MyCommandHandler] Executing "$request"');
    await Future.delayed(const Duration(milliseconds: 500));
    print('[$MyCommandHandler] "$request" completed');
  }
}

class GetUserByIdQuery implements Query<User> {
  final int userId;
  const GetUserByIdQuery(this.userId);

  @override
  String toString() => '$GetUserByIdQuery(userId: $userId)';
}

class GetUserByIdQueryHandler implements QueryHandler<User, GetUserByIdQuery> {
  @override
  Future<User> handle(GetUserByIdQuery request) async {
    print('[$GetUserByIdQueryHandler] handeling $request');
    final user = await getUserByIdAsync(request.userId);
    print('[$GetUserByIdQueryHandler] got $user');
    return user;
  }
}

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
  ) {}
}

class User {
  final int id;
  final String name;

  const User(this.id, this.name);

  @override
  String toString() => '$User(id: $id, name: $name)';
}

Future<User> getUserByIdAsync(int id) async {
  await Future.delayed(const Duration(seconds: 1));
  return User(id, 'John Doe');
}
