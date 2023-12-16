import 'dart:async';

import 'package:dart_mediator/src/request/request.dart';
import 'package:meta/meta.dart';

/// Handler for [TRequest].
@internal
abstract interface class RequestHandler<TResponse,
    TRequest extends Request<TResponse>> {
  /// Handles the given [request].
  FutureOr<TResponse> handle(TRequest request);
}

/// Command handler for [TCommand].
abstract interface class CommandHandler<TCommand extends Command>
    implements RequestHandler<void, TCommand> {}

/// Query handler for [TQuery].
abstract interface class QueryHandler<TResponse extends Object,
        TQuery extends Query<TResponse>>
    implements RequestHandler<TResponse, TQuery> {}
