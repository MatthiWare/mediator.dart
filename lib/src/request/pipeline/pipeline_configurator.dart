import 'package:dart_mediator/src/request/pipeline/pipeline_behavior.dart';

/// Factory to create a [PipelineBehavior].
typedef PipelineBehaviorFactory<TRequest, TResponse>
    = PipelineBehavior<TRequest, TResponse> Function();

abstract interface class PipelineConfigurator {
  /// Registers the [behavior].
  ///
  /// When using a generic [PipelineBehavior] the [registerGeneric] should be
  /// used instead.
  void register<TResponse extends Object?, TRequest extends Object>(
    PipelineBehavior<TResponse, TRequest> behavior,
  );

  /// Registers the [factory].
  ///
  /// When using a generic [PipelineBehavior] the [registerGenericFactory] should
  /// be used instead.
  void registerFactory<TResponse extends Object?, TRequest extends Object>(
    PipelineBehaviorFactory<TResponse, TRequest> factory,
  );

  /// Registers the generic [behavior].
  ///
  /// Note, this should only be used when [register] is not possible.
  void registerGeneric(
    PipelineBehavior behavior,
  );

  /// Registers the generic [factory].
  ///
  /// Note, this should only be used when [registerFactory] is not possible.
  void registerGenericFactory(
    PipelineBehaviorFactory factory,
  );

  /// Unregisters the given [behavior].
  void unregister(PipelineBehavior behavior);

  /// Unregisters the given [factory].
  void unregisterFactory(PipelineBehaviorFactory factory);
}
