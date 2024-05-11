import 'dart:async';

import 'package:dart_mediator/mediator.dart';
import 'package:test/test.dart';

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
      test('it handles the request', () async {
        mediator.requests.register(GetDataQueryHandler());

        final data = await mediator.requests.send(const GetDataQuery(123));

        expect(data, '123');
      });

      test('it handles the request with pipeline', () async {
        var pipeline = false;
        final behavior = WrappingBehavior(
          () {
            print('pipeline callback');
            pipeline = true;
          },
        );

        mediator.requests.register(GetDataQueryHandler());
        mediator.requests.pipeline.registerGeneric(behavior);
        mediator.requests.pipeline.registerGeneric(DelayBehavior());

        await mediator.requests.send(const GetDataQuery(123));

        expect(pipeline, isTrue);
      });
    });
  });
}
