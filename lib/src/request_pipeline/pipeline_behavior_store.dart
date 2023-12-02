import 'package:dart_event_manager/src/request_pipeline/pipeline_behavior.dart';

class PipelineBehaviorStore {
  final _handlers = <PipelineBehavior<Object, Object>>[];
  final _genericHandlers = <PipelineBehavior>[];

  /// Registers the [behavior].
  ///
  /// When using a generic [PipelineBehavior] the [registerGeneric] should be
  /// used instead.
  void register<TResponse extends Object, TRequest extends Object>(
    PipelineBehavior<TResponse, TRequest> behavior,
  ) {
    _handlers.add(behavior);
  }

  /// Registers the generic [behavior].
  ///
  /// Note, this should only be used when [register] is not possible.
  void registerGeneric(
    PipelineBehavior behavior,
  ) {
    _genericHandlers.add(behavior);
  }

  /// Unregisters the given [behavior].
  void unregister(PipelineBehavior behavior) {
    _handlers.remove(behavior);
    _genericHandlers.remove(behavior);
  }

  /// Returns all [PipelineBehavior]'s that match.
  List<PipelineBehavior> getPipelines<TResponse, TRequest>() {
    return [
      ..._handlers.whereType<PipelineBehavior<TResponse, TRequest>>(),
      ..._genericHandlers
    ];
  }
}
