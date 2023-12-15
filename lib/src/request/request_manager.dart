import 'dart:async';

import 'package:dart_mediator/src/request/handler/request_handler.dart';
import 'package:dart_mediator/src/request/handler/request_handler_store.dart';
import 'package:dart_mediator/src/request/pipeline/pipeline_behavior.dart';
import 'package:dart_mediator/src/request/pipeline/pipeline_behavior_store.dart';
import 'package:dart_mediator/src/request/pipeline/pipeline_configurator.dart';
import 'package:dart_mediator/src/request/request.dart';

class RequestManager {
  final RequestHandlerStore _requestHandlerStore;
  final PipelineBehaviorStore _pipelineBehaviorStore;

  RequestManager._(
    this._requestHandlerStore,
    this._pipelineBehaviorStore,
  );

  factory RequestManager({
    RequestHandlerStore? requestHandlerStore,
    PipelineBehaviorStore? pipelineBehaviorStore,
  }) {
    return RequestManager._(
      requestHandlerStore ?? RequestHandlerStore(),
      pipelineBehaviorStore ?? PipelineBehaviorStore(),
    );
  }

  /// Configures the request pipeline.
  ///
  /// See [PipelineConfigurator] on how to configure them using [PipelineBehavior].
  PipelineConfigurator get pipeline => _pipelineBehaviorStore;

  /// Registers the request [handler] for the given [TRequest].
  void register<TResponse, TRequest extends Request<TResponse>>(
    RequestHandler<TResponse, TRequest> handler,
  ) {
    _requestHandlerStore.register(handler);
  }

  /// Sends a [request] to a single [RequestHandler].
  ///
  /// Make sure the [RequestHandler] is [register]ed before calling this method.
  ///
  /// This request can be wrapped by [PipelineBehavior]'s see [pipeline].
  ///
  /// This will return [TResponse].
  Future<TResponse>
      send<TResponse extends Object?, TRequest extends Request<TResponse>>(
    TRequest request,
  ) async {
    final handler = _requestHandlerStore.getHandlerFor<TResponse, TRequest>();

    final pipelines =
        _pipelineBehaviorStore.getPipelines<TResponse, TRequest>();

    FutureOr<TResponse> handle() => handler.handle(request);

    final RequestHandlerDelegate executionPlan = pipelines.fold(
      handle,
      (next, pipeline) => () => pipeline.handle(request, next),
    );

    return await executionPlan();
  }
}
