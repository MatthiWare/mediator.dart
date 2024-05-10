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
  Future<TResponse> send<TResponse extends Object?>(
    Request<TResponse> request,
  ) async {
    final handler = _requestHandlerStore.getHandlerFor(request)
        as RequestHandler<TResponse, Request<TResponse>>;

    final pipelines = _pipelineBehaviorStore.getPipelines(request);

    FutureOr<TResponse> handle() => handler.handle(request);

    final RequestHandlerDelegate executionPlan = pipelines.fold(
      handle,
      (next, pipeline) => () => pipeline.handle(request, next),
    );

    final futureOrResult = executionPlan();
    final response =
        futureOrResult is Future ? await futureOrResult : futureOrResult;

    assert(
      response is TResponse,
      '$request expected a return type of $TResponse but '
      'got one of type ${response.runtimeType}. '
      'One of the registered pipelines is not correctly returning the '
      '`next()` call. Pipelines used: $pipelines',
    );

    return response;
  }
}

extension RequestManagerExtensions on RequestManager {
  /// Registers the given [handler].
  ///
  /// This will create a function based request handler.
  ///
  /// See [RequestHandler.function].
  void registerFunction<TResponse, TRequest extends Request<TResponse>>(
    FutureOr<TResponse> Function(TRequest) handler,
  ) {
    register(RequestHandler.function(handler));
  }

  /// Registers the given [factory].
  ///
  /// This will create a factory based request handler. This factory will be
  /// resolved into an actual [RequestHandler] at request time.
  ///
  /// See [RequestHandler.factory].
  void registerFactory<TResponse, TRequest extends Request<TResponse>>(
    RequestHandlerFactory<TResponse, TRequest> factory,
  ) {
    register(RequestHandler.factory(factory));
  }
}
