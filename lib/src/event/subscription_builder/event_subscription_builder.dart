import 'dart:async';
import 'package:dart_mediator/src/utils/sentinel.dart';
import 'package:meta/meta.dart';
import 'package:dart_mediator/src/mediator.dart';
import 'package:dart_mediator/src/event/handler/event_handler.dart';
import 'package:dart_mediator/src/event/handler/event_handler_store.dart';
import 'package:dart_mediator/src/event/event_subscription.dart';

part 'distinct_builder.dart';
part 'expand_builder.dart';
part 'map_builder.dart';
part 'where_builder.dart';

/// Builder that is able to subscribe to the [Mediator].
///
/// This is a builder pattern that allows you to manipulate the [T] event
/// before it reaches the handler defined in either [subscribe] or [subscribeFunction].
///
/// To transform the events [map] can be used.
///
/// To filter the events [where] can be used.
abstract class EventSubscriptionBuilder<T> {
  EventSubscriptionBuilder();

  /// Creates a new [EventSubscriptionBuilder] this can be used to mutate
  /// the events before they reach the [EventHandler] using the builder pattern.
  factory EventSubscriptionBuilder.create(EventHandlerStore store) =
      _EventSubscriptionBuilder;

  /// Transforms each event.
  ///
  /// It extends the current builder by converting the
  /// input [T] using the provided [mapper] function into
  /// output [S]. Only events of type [S] will reach the
  /// [EventHandler].
  EventSubscriptionBuilder<S> map<S>(S Function(T event) mapper) {
    return _MapEventSubscriptionBuilder(parent: this, mapper: mapper);
  }

  /// Transforms each event.
  ///
  /// It extends the current builder by converting the
  /// input [T] using the provided [mapper] function into
  /// output [S]. Only events of type [S] will reach the
  /// [EventHandler].
  EventSubscriptionBuilder<S> asyncMap<S>(Future<S> Function(T event) mapper) {
    return _AsyncMapEventSubscriptionBuilder(parent: this, mapper: mapper);
  }

  /// Transforms each event.
  ///
  /// It extends the current builder by converting the
  /// input [T] using the provided [mapper] function into
  /// output [S]. Only events of type [S] will reach the
  /// [EventHandler].
  EventSubscriptionBuilder<S> cast<S>() {
    return _MapEventSubscriptionBuilder(
      parent: this,
      mapper: (input) => input as S,
    );
  }

  /// Filters the events
  ///
  /// It extends the current builder so that only inputs
  /// that pass the [test] clause will be kept for the [EventHandler].
  EventSubscriptionBuilder<T> where(bool Function(T event) test) {
    return _WhereEventSubscriptionBuilder(parent: this, test: test);
  }

  /// Skips data events if they are equal to the previous data event.
  ///
  /// It extends the current builder so that only distinct inputs
  /// that pass the [equals] clause will be kept for the [EventHandler].
  EventSubscriptionBuilder<T> distinct([
    bool Function(T previous, T next)? equals,
  ]) {
    return _DistinctEventSubscriptionBuilder(
      parent: this,
      equals: equals ?? (prev, curr) => prev == curr,
    );
  }

  /// Transforms each element of this handler into a sequence of elements.
  ///
  /// It extends the current builder where each element of this [EventHandler]
  /// is replaced by zero or more data events.
  EventSubscriptionBuilder<T> expand(
    Iterable<T> Function(T element) convert,
  ) {
    return _ExpandEventSubscriptionBuilder(parent: this, convert: convert);
  }

  /// Transforms each element of this handler into a sequence of elements.
  ///
  /// It extends the current builder where each element of this [EventHandler]
  /// is replaced by zero or more data events.
  EventSubscriptionBuilder<T> asyncExpand(
    Stream<T> Function(T element) convert,
  ) {
    return _AsyncExpandEventSubscriptionBuilder(parent: this, convert: convert);
  }

  /// Subscribes to the given [handler].
  ///
  /// This finalizes the builder and applies all the steps
  /// before subscribing.
  EventSubscription subscribe(EventHandler<T> handler);
}

extension EventSubscriptionBuilderExtensions<T> on EventSubscriptionBuilder<T> {
  /// Subscribes to the given [handler].
  ///
  /// This finalizes the builder and applies all the steps
  /// before subscribing.
  EventSubscription subscribeFunction(
    FutureOr<void> Function(T event) handler,
  ) {
    return subscribe(EventHandler.function(handler));
  }

  /// Subscribes to the given [factory].
  ///
  /// This finalizes the builder and applies all the steps
  /// before subscribing.
  ///
  /// This factory will be resolved into an actual [EventHandler] at request time.
  EventSubscription subscribeFactory(
    EventHandlerFactory<T> factory,
  ) {
    return subscribe(EventHandler.factory(factory));
  }
}

class _EventSubscriptionBuilder<T> extends EventSubscriptionBuilder<T> {
  final EventHandlerStore _store;

  _EventSubscriptionBuilder(this._store);

  @override
  EventSubscription subscribe(EventHandler<T> handler) {
    final subscription = EventSubscription(
      () => _store.unregister(handler),
    );

    _store.register(handler);

    return subscription;
  }
}

/// Base for implementing custom [EventSubscriptionBuilder].
///
/// [TInput] is the input received by the handler
/// [TOutput] is the output being send to the next handler
abstract class BaseEventSubscriptionBuilder<TInput, TOutput>
    extends EventSubscriptionBuilder<TOutput> {
  /// The parent [EventSubscriptionBuilder] that this builder is wrapping.
  final EventSubscriptionBuilder<TInput> parent;

  /// Creates a new [EventSubscriptionBuilder].
  BaseEventSubscriptionBuilder({
    required this.parent,
  });

  /// Creates the [EventHandler] for this builder based on the parent [handler].
  @protected
  @mustBeOverridden
  EventHandler<TInput> createHandler(EventHandler<TOutput> handler);

  @override
  EventSubscription subscribe(EventHandler<TOutput> handler) {
    return parent.subscribe(createHandler(handler));
  }
}
