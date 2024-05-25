import 'package:dart_mediator/mediator.dart';
import 'package:test/test.dart';

import '../mocks.dart';
import '../test_data.dart';

void main() {
  group('Mediator', () {
    late Mediator mediator;

    setUp(() {
      mediator = Mediator.create();
    });

    group('requests', () {
      test('it unregisters the request handler', () async {
        final handler = GetDataQueryHandlerAsync();

        mediator.requests.register(handler);
        mediator.requests.unregister(handler);

        await expectLater(
          mediator.requests.send(const GetDataQuery(123)),
          throwsAssertionError,
        );
      });

      test('it handles the normal request', () async {
        mediator.requests.register(GetDataQueryHandlerAsync());

        final data = await mediator.requests.send(const GetDataQuery(123));

        expect(data, '123');
      });

      test('it handles the function request', () async {
        mediator.requests.registerFunction(GetDataQueryHandlerAsync().handle);

        final data = await mediator.requests.send(const GetDataQuery(123));

        expect(data, '123');
      });

      test('it handles the factory request', () async {
        mediator.requests.registerFactory(() => GetDataQueryHandlerAsync());

        final data = await mediator.requests.send(const GetDataQuery(123));

        expect(data, '123');
      });

      test('it handles the request with pipeline', () async {
        var pipeline = false;

        mediator.requests.register(GetDataQueryHandlerAsync());
        mediator.requests.pipeline.registerGenericFunction((req, next) {
          pipeline = true;
          return next();
        });
        mediator.requests.pipeline.registerGenericFactory(
          () => DelayBehavior(),
        );

        final data = await mediator.requests.send(const GetDataQuery(123));

        expect(pipeline, isTrue);
        expect(data, '123');
      });

      test('it handles the request with multiple pipelines', () async {
        mediator.requests.register(GetDataQueryHandlerAsync());

        // See: https://github.com/MatthiWare/mediator.dart/issues/16
        mediator.requests.pipeline.register(GetDataQueryHandlerBehaviorAsync());
        mediator.requests.pipeline.register(GetDataQueryHandlerBehaviorAsync());

        mediator.requests.pipeline.registerGeneric(DelayBehavior());

        final data = await mediator.requests.send(const GetDataQuery(123));

        expect(data, '123');
      });

      test('it handles the async request with mixed pipelines', () async {
        mediator.requests.register(GetDataQueryHandlerAsync());

        for (var i = 0; i < 2; i++) {
          mediator.requests.pipeline
              .register(GetDataQueryHandlerBehaviorAsync());
          mediator.requests.pipeline
              .register(GetDataQueryHandlerBehaviorSync());

          mediator.requests.pipeline.registerGeneric(DelayBehavior());
          mediator.requests.pipeline.registerGeneric(GenericSyncBehavior());
        }

        final data = await mediator.requests.send(const GetDataQuery(123));

        expect(data, '123');
      });

      test('it handles the sync request with mixed pipelines', () async {
        mediator.requests.register(GetDataQueryHandlerSync());

        for (var i = 0; i < 2; i++) {
          mediator.requests.pipeline
              .register(GetDataQueryHandlerBehaviorAsync());
          mediator.requests.pipeline
              .register(GetDataQueryHandlerBehaviorSync());

          mediator.requests.pipeline.registerGeneric(DelayBehavior());
          mediator.requests.pipeline.registerGeneric(GenericSyncBehavior());
        }

        final data = await mediator.requests.send(const GetDataQuery(123));

        expect(data, '123');
      });

      test('it handles the stream request with pipeline', () async {
        final pipelineCalls = <bool>[];

        mediator.requests.register(GetDataQueryHandlerAsync());

        mediator.requests.pipeline.register(GetDataQueryHandlerBehaviorAsync());
        mediator.requests.pipeline.register(GetDataQueryHandlerBehaviorSync());
        mediator.requests.pipeline.registerGenericFunction((req, next) {
          pipelineCalls.add(true);
          return next();
        });
        mediator.requests.pipeline.registerGenericFactory(
          () => DelayBehavior(),
        );

        final stream = Stream.fromIterable(
          Iterable.generate(3, (i) => GetDataQuery(i)),
        );

        final output = await mediator.requests.sendStream(stream).toList();

        expect(pipelineCalls, [true, true, true]);
        expect(output, ['0', '1', '2']);
      });
    });
  });
}
