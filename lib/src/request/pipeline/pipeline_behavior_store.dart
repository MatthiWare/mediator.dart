import 'package:dart_mediator/src/request/request.dart';
import 'package:dart_mediator/src/request/pipeline/pipeline_configurator.dart';
import 'package:dart_mediator/src/request/pipeline/pipeline_behavior.dart';

class PipelineBehaviorStore implements PipelineConfigurator {
  final _handlers = <Type, List<PipelineBehavior>>{};
  final _handlerFactories = <Type, List<PipelineBehaviorFactory>>{};
  final _genericHandlers = <PipelineBehavior>{};
  final _genericHandlerFactories = <PipelineBehaviorFactory>{};

  @override
  void register<TResponse extends Object?, TRequest extends Request<TResponse>>(
    PipelineBehavior<TResponse, TRequest> behavior,
  ) {
    final handlers = _handlers.putIfAbsent(
      TRequest,
      () => <PipelineBehavior>[],
    );

    handlers.add(behavior);
  }

  @override
  void registerFactory<TResponse extends Object?,
      TRequest extends Request<TResponse>>(
    PipelineBehaviorFactory<TResponse, TRequest> factory,
  ) {
    final handlers = _handlerFactories.putIfAbsent(
      TRequest,
      () => <PipelineBehaviorFactory>[],
    );

    handlers.add(factory);
  }

  @override
  void registerGeneric(
    PipelineBehavior behavior,
  ) {
    _genericHandlers.add(behavior);
  }

  @override
  void registerGenericFactory(
    PipelineBehaviorFactory factory,
  ) {
    _genericHandlerFactories.add(factory);
  }

  @override
  void unregister(PipelineBehavior behavior) {
    for (final handlers in _handlers.values) {
      handlers.remove(behavior);
    }
    _genericHandlers.remove(behavior);
  }

  @override
  void unregisterFactory(PipelineBehaviorFactory factory) {
    for (final handlers in _handlerFactories.values) {
      handlers.remove(factory);
    }
    _genericHandlerFactories.remove(factory);
  }

  /// Returns all [PipelineBehavior]'s that match.
  List<PipelineBehavior> getPipelines(
    Request request,
  ) {
    final requestType = request.runtimeType;

    final handlerFactories =
        _handlerFactories[requestType]?.map((factory) => factory());

    final genericFactories =
        _genericHandlerFactories.map((factory) => factory());

    final handlers = _handlers[requestType];

    return [
      if (handlers != null) ...handlers,
      if (handlerFactories != null) ...handlerFactories,
      ..._genericHandlers,
      ...genericFactories,
    ];
  }
}
