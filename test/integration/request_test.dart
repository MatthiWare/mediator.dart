import 'dart:async';

import 'package:dart_mediator/mediator.dart';
import 'package:test/test.dart';

import '../mocks.dart';
import '../test_data.dart';

class GetDataQueryHandler implements QueryHandler<String, GetDataQuery> {
  @override
  Future<String> handle(GetDataQuery request) async {
    await Future.delayed(const Duration(milliseconds: 10));
    return request.id.toString();
  }
}

void main() {
  group('Mediator', () {
    late Mediator mediator;

    setUp(() {
      mediator = Mediator.create();
    });

    group('requests', () {
      test('it unregisters the request handler', () async {
        final handler = GetDataQueryHandler();

        mediator.requests.register(handler);
        mediator.requests.unregister(handler);

        await expectLater(
          mediator.requests.send(const GetDataQuery(123)),
          throwsAssertionError,
        );
      });

      test('it handles the normal request', () async {
        mediator.requests.register(GetDataQueryHandler());

        final data = await mediator.requests.send(const GetDataQuery(123));

        expect(data, '123');
      });

      test('it handles the function request', () async {
        mediator.requests.registerFunction(GetDataQueryHandler().handle);

        final data = await mediator.requests.send(const GetDataQuery(123));

        expect(data, '123');
      });

      test('it handles the factory request', () async {
        mediator.requests.registerFactory(() => GetDataQueryHandler());

        final data = await mediator.requests.send(const GetDataQuery(123));

        expect(data, '123');
      });

      test('it handles the request with pipeline', () async {
        var pipeline = false;

        mediator.requests.register(GetDataQueryHandler());
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
    });
  });
}
