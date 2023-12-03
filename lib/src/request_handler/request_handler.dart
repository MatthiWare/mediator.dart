import 'dart:async';

import 'package:dart_event_manager/src/request.dart';

/// Handler for [TRequest].
abstract interface class RequestHandler<TResponse,
    TRequest extends Request<TResponse>> {
  /// Handles the given [request].
  FutureOr<TResponse> handle(TRequest request);
}
