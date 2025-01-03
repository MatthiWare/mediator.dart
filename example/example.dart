import 'dart:async';

import 'package:dart_mediator/mediator.dart';
import 'package:meta/meta.dart';

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
  mediator.events.on<CountEvent>().subscribeFactory(createCountEventHandler);

  mediator.events
      .on<CountEvent>()
      .distinct()
      .map((event) => event.count)
      .subscribeFunction(
    (count) {
      // Only distinct count events will get to this point.
      // LoggingEventObserver will still see the event.
      print('[CountEvent Handler] received distinct count: $count');
    },
  );

  print('--- Query Example ---');

  const getUserQuery = GetUserByIdQuery(123);

  print('Sending $getUserQuery request');

  final resp = await mediator.requests.send(getUserQuery);

  print('Got $getUserQuery response: $resp');

  print('\n--- Command Example ---');

  const order66Command = MyCommand('Order 66');

  print('Sending $order66Command');

  await mediator.requests.send(order66Command);

  print('$order66Command completed');

  print('\n--- Events Example ---');

  const countEvent = CountEvent(123);

  // Event will be handled by 2 event handlers.
  await mediator.events.dispatch(countEvent);

  // Event will only be handled by 1 event handler (distinct).
  await mediator.events.dispatch(countEvent);

  print('done');
}

@immutable
class CountEvent implements DomainEvent {
  final int count;
  const CountEvent(this.count);

  @override
  String toString() => 'CountEvent(count: $count)';

  @override
  int get hashCode => Object.hash(runtimeType, count);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is CountEvent &&
            other.count == count);
  }
}

class CountEventHandler implements EventHandler<CountEvent> {
  @override
  FutureOr<void> handle(CountEvent event) {
    final count = event.count;
    print('[CountEvent Handler] received count: $count');
  }
}

CountEventHandler createCountEventHandler() => CountEventHandler();

class MyCommand implements Command {
  final String command;
  const MyCommand(this.command);

  @override
  String toString() => 'MyCommand(command: $command)';
}

class MyCommandHandler implements CommandHandler<MyCommand> {
  @override
  Future<void> handle(MyCommand request) async {
    final command = request.command;
    print('[MyCommandHandler] Execute $command');
    {
      await Future.delayed(const Duration(milliseconds: 300));
      for (var i = 0; i < 3; i++) {
        print('[MyCommandHandler] pew');
        await Future.delayed(const Duration(milliseconds: 300));
      }
    }
    print('[MyCommandHandler] $request executed!');
  }
}

class GetUserByIdQuery implements Query<User> {
  final int userId;
  const GetUserByIdQuery(this.userId);

  @override
  String toString() => 'GetUserByIdQuery(userId: $userId)';
}

class GetUserByIdQueryHandler implements QueryHandler<User, GetUserByIdQuery> {
  @override
  Future<User> handle(GetUserByIdQuery request) async {
    print('[GetUserByIdQueryHandler] handling $request');
    final user = await getUserByIdAsync(request.userId);
    print('[GetUserByIdQueryHandler] got $user');
    return user;
  }
}

class LoggingBehavior implements PipelineBehavior {
  @override
  Future handle(request, RequestHandlerDelegate next) async {
    try {
      print('[LoggingBehavior] [$request] Before');
      return await next();
    } finally {
      print('[LoggingBehavior] [$request] After');
    }
  }
}

class LoggingEventObserver implements EventObserver {
  @override
  void onDispatch<TEvent>(
    TEvent event,
    Set<EventHandler> handlers,
  ) {
    print(
      '[LoggingEventObserver] onDispatch "$event" with ${handlers.length} handlers',
    );
  }

  @override
  void onError<TEvent>(
    TEvent event,
    EventHandler handler,
    Object error,
    StackTrace stackTrace,
  ) {
    print('[LoggingEventObserver] onError $event -> $handler ($error)');
  }

  @override
  void onHandled<TEvent>(
    TEvent event,
    EventHandler handler,
  ) {
    print('[LoggingEventObserver] onHandled $event handled by $handler');
  }
}

class User {
  final int id;
  final String name;

  const User(this.id, this.name);

  @override
  String toString() => 'User(id: $id, name: $name)';
}

Future<User> getUserByIdAsync(int id) async {
  await Future.delayed(const Duration(seconds: 1));
  return User(id, 'John Doe');
}
