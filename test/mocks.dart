import 'package:dart_mediator/mediator.dart';
import 'package:dart_mediator/src/request/handler/request_handler.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockMediator extends Mock implements Mediator {}

class MockRequestManager extends Mock implements RequestManager {}

class MockEventManager extends Mock implements EventManager {}

class MockDispatchStrategy extends Mock implements DispatchStrategy {}

class MockEventHandlerStore extends Mock implements EventHandlerStore {}

class MockRequestHandlerStore extends Mock implements RequestHandlerStore {}

class MockPipelineBehaviorStore extends Mock implements PipelineBehaviorStore {}

class MockEventHandler<T> extends Mock implements EventHandler<T> {}

class MockRequest<T> extends Mock implements Request<T> {}

class MockEventObserver extends Mock implements EventObserver {}

class CallbackMock extends Mock {
  void call();
}

class MockRequestHandler<Res, Req extends Request<Res>> extends Mock
    implements RequestHandler<Res, Req> {}

class MockPipelineBehavior<Res, Req> extends Mock
    implements PipelineBehavior<Res, Req> {}

class MockEventSubscription extends Mock implements EventSubscription {}

class MockEventSubscriptionBuilder<T> extends Mock
    implements EventSubscriptionBuilder<T> {}

final throwsAssertionError = throwsA(const TypeMatcher<AssertionError>());

final isEventSubscriptionBuilder = isA<EventSubscriptionBuilder>();
