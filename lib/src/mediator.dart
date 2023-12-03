import 'dart:async';

import 'package:dart_event_manager/src/dispatch_strategy.dart';
import 'package:dart_event_manager/src/event.dart';
import 'package:dart_event_manager/src/event_handler/event_handler.dart';
import 'package:dart_event_manager/src/request.dart';
import 'package:dart_event_manager/src/request_handler/request_handler.dart';
import 'package:dart_event_manager/src/event_handler/event_handler_store.dart';
import 'package:dart_event_manager/src/event_subscription_builder.dart';
import 'package:dart_event_manager/src/request_handler/request_handler_store.dart';
import 'package:dart_event_manager/src/request_pipeline/pipeline_configurator.dart';
import 'package:dart_event_manager/src/request_pipeline/pipeline_behavior.dart';
import 'package:dart_event_manager/src/request_pipeline/pipeline_behavior_store.dart';

class Mediator {
  final EventHandlerStore _eventHandlerStore;
  final RequestHandlerStore _requestHandlerStore;
  final PipelineBehaviorStore _pipelineBehaviorStore;
  final DispatchStrategy _defaultDispatchStrategy;

  /// Configures the request pipeline.
  ///
  /// See [PipelineConfigurator] on how to configure them using [PipelineBehavior].
  PipelineConfigurator get pipeline => _pipelineBehaviorStore;

  Mediator._(
    this._eventHandlerStore,
    this._requestHandlerStore,
    this._pipelineBehaviorStore,
    this._defaultDispatchStrategy,
  );

  factory Mediator({
    EventHandlerStore? eventHandlerStore,
    RequestHandlerStore? requestHandlerStore,
    PipelineBehaviorStore? pipelineBehaviorStore,
    DispatchStrategy defaultEventDispatchStrategy =
        const DispatchStrategy.concurrent(),
  }) {
    return Mediator._(
      eventHandlerStore ?? EventHandlerStore(),
      requestHandlerStore ?? RequestHandlerStore(),
      pipelineBehaviorStore ?? PipelineBehaviorStore(),
      defaultEventDispatchStrategy,
    );
  }

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
  Future<TResponse>
      send<TResponse extends Object?, TRequest extends Request<TResponse>>(
    TRequest request,
  ) async {
    final handler = _requestHandlerStore.getHandlerFor<TResponse, TRequest>();

    final pipelines =
        _pipelineBehaviorStore.getPipelines<TResponse, TRequest>();

    FutureOr<TResponse> handle() => handler.handle(request);

    final RequestHandlerDelegate executionPlan = pipelines.fold(
      handle,
      (next, pipeline) => () => pipeline.handle(request, next),
    );

    return await executionPlan();
  }

  /// Subscribe on the given [T] event.
  ///
  /// Returns a [EventSubscriptionBuilder] that allows to build a specific
  /// subscription.
  EventSubscriptionBuilder<T> on<T extends DomainEvent>() =>
      EventSubscriptionBuilder.create(_eventHandlerStore);

  /// Dispatches the given [event] to the registered [EventHandler]'s.
  Future<void> dispatch<TEvent extends DomainEvent>(
    TEvent event, [
    DispatchStrategy? dispatchStrategy,
  ]) async {
    final handlers = _eventHandlerStore.getHandlersFor<TEvent>();

    assert(
      handlers.isNotEmpty,
      'dispatch<$TEvent> was invoked but no handlers are registered to handle this',
    );

    await (dispatchStrategy ?? _defaultDispatchStrategy)
        .execute(handlers, event);
  }
}
