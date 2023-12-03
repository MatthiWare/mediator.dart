import 'package:dart_event_manager/src/request_pipeline/pipeline_configurator.dart';
import 'package:dart_event_manager/src/request_pipeline/pipeline_behavior.dart';

class PipelineBehaviorStore implements PipelineConfigurator {
  final _handlers = <PipelineBehavior<Object?, Object>>[];
  final _genericHandlers = <PipelineBehavior>[];

  @override
  void register<TResponse extends Object?, TRequest extends Object>(
    PipelineBehavior<TResponse, TRequest> behavior,
  ) {
    _handlers.add(behavior);
  }

  @override
  void registerGeneric(
    PipelineBehavior behavior,
  ) {
    _genericHandlers.add(behavior);
  }

  @override
  void unregister(PipelineBehavior behavior) {
    _handlers.remove(behavior);
    _genericHandlers.remove(behavior);
  }

  /// Returns all [PipelineBehavior]'s that match.
  List<PipelineBehavior>
      getPipelines<TResponse extends Object?, TRequest extends Object>() {
    return [
      ..._handlers.whereType<PipelineBehavior<TResponse, TRequest>>(),
      ..._genericHandlers
    ];
  }
}
