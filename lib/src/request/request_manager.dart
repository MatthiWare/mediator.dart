import 'dart:async';

import 'package:dart_mediator/src/request/handler/request_handler.dart';
import 'package:dart_mediator/src/request/handler/request_handler_store.dart';
import 'package:dart_mediator/src/request/pipeline/pipeline_behavior.dart';
import 'package:dart_mediator/src/request/pipeline/pipeline_behavior_store.dart';
import 'package:dart_mediator/src/request/pipeline/pipeline_configurator.dart';
import 'package:dart_mediator/src/request/request.dart';

/// Send requests through the mediator to be handled by a single handler.
class RequestManager {
  final RequestHandlerStore _requestHandlerStore;
  final PipelineBehaviorStore _pipelineBehaviorStore;

  /// Creates a new [RequestManager].
  ///
  /// [requestHandlerStore] is used to store the registered [RequestHandler]'s.
  ///
  /// [pipelineBehaviorStore] is used to store the registered [PipelineBehavior]'s.
  RequestManager({
    required RequestHandlerStore requestHandlerStore,
    required PipelineBehaviorStore pipelineBehaviorStore,
  })  : _requestHandlerStore = requestHandlerStore,
        _pipelineBehaviorStore = pipelineBehaviorStore;

  /// Creates a default [RequestManager].
  factory RequestManager.create() {
    return RequestManager(
      pipelineBehaviorStore: PipelineBehaviorStore(),
      requestHandlerStore: RequestHandlerStore(),
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

    final response = await executionPlan();

    assert(
      response is TResponse,
      '$TRequest expected a return type of $TResponse but '
      'got one of type ${response.runtimeType}. '
      'One of the registered pipelines is not correctly returning the '
      '`next()` call. Pipelines used: $pipelines',
    );

    return response;
  }
}
