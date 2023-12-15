import 'package:dart_mediator/src/mediator.dart';

/// Base request that can be used to send requests to their handlers.
///
/// Use [Query] if you want to return data.
///
/// Use [Command] if you don't have return data.
///
/// See [Mediator.send]
abstract interface class Request<TResponse extends Object?> {}

/// A query [Request] that will return [TResponse].
abstract interface class Query<TResponse extends Object>
    implements Request<TResponse> {}

/// A command [Request] that doesn't return any data.
abstract interface class Command implements Request<void> {}
