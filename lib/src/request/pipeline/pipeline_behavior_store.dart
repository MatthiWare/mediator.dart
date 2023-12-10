import 'package:dart_mediator/src/request/request.dart';
import 'package:dart_mediator/src/request/pipeline/pipeline_configurator.dart';
import 'package:dart_mediator/src/request/pipeline/pipeline_behavior.dart';

class PipelineBehaviorStore implements PipelineConfigurator {
  final _handlers = <PipelineBehavior<Object?, Object>>{};
  final _handlerFactories = <PipelineBehaviorFactory<Object?, Object>>{};
  final _genericHandlers = <PipelineBehavior>{};
  final _genericHandlerFactories = <PipelineBehaviorFactory>{};

  @override
  void register<TResponse extends Object?, TRequest extends Object>(
    PipelineBehavior<TResponse, TRequest> behavior,
  ) {
    _handlers.add(behavior);
  }

  @override
  void registerFactory<TResponse extends Object?, TRequest extends Object>(
    PipelineBehaviorFactory<TResponse, TRequest> factory,
  ) {
    _handlerFactories.add(factory);
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
    _handlers.remove(behavior);
    _genericHandlers.remove(behavior);
  }

  @override
  void unregisterFactory(PipelineBehaviorFactory factory) {
    _handlerFactories.remove(factory);
    _genericHandlerFactories.remove(factory);
  }

  /// Returns all [PipelineBehavior]'s that match.
  List<PipelineBehavior> getPipelines<TResponse extends Object?,
      TRequest extends Request<TResponse>>() {
    final handlerFactories = _handlerFactories
        .whereType<PipelineBehaviorFactory<TResponse, TRequest>>()
        .map((factory) => factory());

    final genericFactories =
        _genericHandlerFactories.map((factory) => factory());

    return [
      ..._handlers.whereType<PipelineBehavior<TResponse, TRequest>>(),
      ...handlerFactories,
      ..._genericHandlers,
      ...genericFactories,
    ];
  }
}
