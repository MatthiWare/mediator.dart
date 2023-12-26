import 'package:dart_mediator/mediator.dart';
import 'package:meta/meta.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../mocks.dart';

void main() {
  group('External Integration', () {
    late MockMediator mockMediator;
    late MockEventManager mockEventManager;
    late MockRequestManager mockRequestManager;
    late ExternalClass externalClass;

    setUp(() {
      mockMediator = MockMediator();
      mockEventManager = MockEventManager();
      mockRequestManager = MockRequestManager();

      when(() => mockMediator.events).thenReturn(mockEventManager);
      when(() => mockMediator.requests).thenReturn(mockRequestManager);

      externalClass = ExternalClass(mockMediator);
    });

    setUpAll(() {
      registerFallbackValue(MockEventHandler<WorkCompletedEvent>());
    });

    group('subscribe', () {
      test('should subscribe to event', () async {
        // Arrange
        final mockEventSubscriptionBuilder =
            MockEventSubscriptionBuilder<WorkCompletedEvent>();

        when(() => mockEventManager.on<WorkCompletedEvent>())
            .thenReturn(mockEventSubscriptionBuilder);

        when(() => mockEventSubscriptionBuilder.subscribe(any()))
            .thenReturn(MockEventSubscription());

        // Act
        externalClass.subscribe();

        // Assert
        verify(() => mockEventSubscriptionBuilder
            .subscribe(any<EventHandler<WorkCompletedEvent>>()));
      });
    });

    group('doSomeWorkAsync', () {
      test('should send query and dispatch event', () async {
        // Arrange
        const query = DoSomethingQuery(1);
        const event = WorkCompletedEvent('1');

        when(() => mockRequestManager.send(query)).thenAnswer((_) async => '1');
        when(() => mockEventManager.dispatch(event)).thenAnswer((_) async {});

        // Act
        await externalClass.doSomeWorkAsync();

        // Assert
        verify(() => mockMediator.requests.send(query));
        verify(() => mockMediator.events.dispatch(event));
      });
    });
  });
}

@immutable
class DoSomethingQuery implements Query<String> {
  final int param;

  const DoSomethingQuery(this.param);

  @override
  bool operator ==(Object other) {
    return other is DoSomethingQuery && other.param == param;
  }

  @override
  int get hashCode => param.hashCode;
}

class DoSomethingQueryHandler
    implements QueryHandler<String, DoSomethingQuery> {
  @override
  Future<String> handle(DoSomethingQuery query) async {
    return query.param.toString();
  }
}

@immutable
class WorkCompletedEvent implements DomainEvent {
  final String result;

  const WorkCompletedEvent(this.result);

  @override
  bool operator ==(Object other) {
    return other is WorkCompletedEvent && other.result == result;
  }

  @override
  int get hashCode => result.hashCode;
}

class WorkCompletedEventHandler implements EventHandler<WorkCompletedEvent> {
  @override
  Future<void> handle(WorkCompletedEvent event) async {
    print(event.result);
  }
}

class ExternalClass {
  final Mediator mediator;

  ExternalClass(this.mediator);

  void subscribe() {
    mediator.events
        .on<WorkCompletedEvent>()
        .subscribe(WorkCompletedEventHandler());
  }

  Future<void> doSomeWorkAsync() async {
    final result = await mediator.requests.send(DoSomethingQuery(1));
    mediator.events.dispatch(WorkCompletedEvent(result));
  }
}
