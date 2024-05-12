import 'package:dart_mediator/src/request/request.dart';
import 'package:dart_mediator/src/request/pipeline/pipeline_configurator.dart';
import 'package:dart_mediator/src/request/pipeline/pipeline_behavior.dart';

class PipelineBehaviorStore implements PipelineConfigurator {
  final _typedBehaviors = <Type, Set<PipelineBehavior>>{};
  final _genericBehaviors = <PipelineBehavior>{};

  @override
  void register<TResponse extends Object?, TRequest extends Request<TResponse>>(
    PipelineBehavior<TResponse, TRequest> behavior,
  ) {
    final handlers = _typedBehaviors.putIfAbsent(
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
      !_genericBehaviors.contains(behavior),
      'registerGeneric was called with an already registered behavior',
    );

    _genericBehaviors.add(behavior);
  }

  @override
  void unregister<TResponse extends Object?,
      TRequest extends Request<TResponse>>(
    PipelineBehavior<TResponse, TRequest> behavior,
  ) {
    final behaviors = _typedBehaviors[TRequest];

    assert(
      behaviors != null && behaviors.contains(behavior),
      'unregister<$TResponse, $TRequest> was called for a behavior that was never registered',
    );

    behaviors!.remove(behavior);
  }

  @override
  void unregisterGeneric(PipelineBehavior behavior) {
    assert(
      _genericBehaviors.contains(behavior),
      'unregisterGeneric was called for a behavior that was never registered',
    );

    _genericBehaviors.remove(behavior);
  }

  /// Returns all [PipelineBehavior]'s that match.
  List<PipelineBehavior> getPipelines(
    Request request,
  ) {
    final requestType = request.runtimeType;

    final behaviors = _typedBehaviors[requestType];

    return [
      if (behaviors != null) ...behaviors,
      ..._genericBehaviors,
    ];
  }
}
