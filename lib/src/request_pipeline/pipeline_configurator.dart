import 'package:dart_event_manager/src/request_pipeline/pipeline_behavior.dart';

abstract interface class PipelineConfigurator {
  /// Registers the [behavior].
  ///
  /// When using a generic [PipelineBehavior] the [registerGeneric] should be
  /// used instead.
  void register<TResponse extends Object?, TRequest extends Object>(
    PipelineBehavior<TResponse, TRequest> behavior,
  );

  /// Registers the generic [behavior].
  ///
  /// Note, this should only be used when [register] is not possible.
  void registerGeneric(
    PipelineBehavior behavior,
  );

  /// Unregisters the given [behavior].
  void unregister(PipelineBehavior behavior);
}
