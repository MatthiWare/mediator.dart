import 'package:dart_mediator/src/request/request.dart';
import 'package:dart_mediator/src/request/pipeline/pipeline_configurator.dart';
import 'package:dart_mediator/src/request/pipeline/pipeline_behavior.dart';

class PipelineBehaviorStore implements PipelineConfigurator {
  final _handlers = <Type, Set<PipelineBehavior>>{};
  final _genericHandlers = <PipelineBehavior>{};

  @override
  void register<TResponse extends Object?, TRequest extends Request<TResponse>>(
    PipelineBehavior<TResponse, TRequest> behavior,
  ) {
    final handlers = _handlers.putIfAbsent(
      TRequest,
      () => <PipelineBehavior>{},
    );

    assert(
      !handlers.contains(behavior),
      'register<$TResponse, $TRequest> was called with an already registered behavior',
    );

    handlers.add(behavior);
  }

  @override
  void registerGeneric(
    PipelineBehavior behavior,
  ) {
    assert(
      !_genericHandlers.contains(behavior),
      'registerGeneric was called with an already registered behavior',
    );

    _genericHandlers.add(behavior);
  }

  @override
  void unregister<TResponse extends Object?,
      TRequest extends Request<TResponse>>(
    PipelineBehavior<TResponse, TRequest> behavior,
  ) {
    final handlers = _handlers[TRequest];

    assert(
      handlers != null && handlers.contains(behavior),
      'unregister<$TResponse, $TRequest> was called for a behavior that was never registered',
    );

    handlers!.remove(behavior);
  }

  @override
  void unregisterGeneric(PipelineBehavior behavior) {
    assert(
      _genericHandlers.contains(behavior),
      'unregisterGeneric was called for a behavior that was never registered',
    );

    _genericHandlers.remove(behavior);
  }

  /// Returns all [PipelineBehavior]'s that match.
  List<PipelineBehavior> getPipelines(
    Request request,
  ) {
    final requestType = request.runtimeType;

    final handlers = _handlers[requestType];

    return [
      if (handlers != null) ...handlers,
      ..._genericHandlers,
    ];
  }
}
