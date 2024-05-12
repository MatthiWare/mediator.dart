import 'package:dart_mediator/request_manager.dart';

abstract interface class PipelineConfigurator {
  /// Registers the [behavior].
  ///
  /// When using a generic [PipelineBehavior] the [registerGeneric] should be
  /// used instead.
  void register<TResponse extends Object?, TRequest extends Request<TResponse>>(
    PipelineBehavior<TResponse, TRequest> behavior,
  );

  /// Registers the generic [behavior].
  ///
  /// Note, this should only be used when [register] is not possible.
  void registerGeneric(
    PipelineBehavior behavior,
  );

  /// Unregisters the given [behavior].
  void unregister<TResponse extends Object?,
      TRequest extends Request<TResponse>>(
    PipelineBehavior<TResponse, TRequest> behavior,
  );

  /// Unregisters the generic [behavior].
  void unregisterGeneric(PipelineBehavior behavior);
}

extension PipelineConfiguratorExtensions on PipelineConfigurator {
  /// Registers the given [handler].
  ///
  /// This will create a function based [PipelineBehavior].
  ///
  /// See [PipelineBehavior.function].
  void registerFunction<TResponse extends Object?,
      TRequest extends Request<TResponse>>(
    PipelineHandler<TResponse, TRequest> handler,
  ) {
    register(PipelineBehavior.function(handler));
  }

  /// Registers the given [factory].
  ///
  /// This will create a factory based [PipelineBehavior]. This factory will be
  /// resolved into an actual [PipelineBehavior] at request time.
  ///
  /// See [PipelineBehavior.factory].
  void registerFactory<TResponse extends Object?,
      TRequest extends Request<TResponse>>(
    PipelineBehaviorFactory<TResponse, TRequest> factory,
  ) {
    register(PipelineBehavior.factory(factory));
  }

  /// Registers the given generic [handler].
  ///
  /// This will create a function based [PipelineBehavior].
  ///
  ///
  /// See [registerGeneric].
  /// See [PipelineBehavior.function].
  void registerGenericFunction(
    PipelineHandler handler,
  ) {
    registerGeneric(PipelineBehavior.function(handler));
  }

  /// Registers the given generic [factory].
  ///
  /// This will create a factory based [PipelineBehavior]. This factory will be
  /// resolved into an actual [PipelineBehavior] at request time.
  ///
  /// See [registerGeneric].
  /// See [PipelineBehavior.factory].
  void registerGenericFactory(
    PipelineBehaviorFactory factory,
  ) {
    registerGeneric(PipelineBehavior.factory(factory));
  }
}
