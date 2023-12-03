import 'package:dart_event_manager/contracts.dart';
import 'package:dart_event_manager/event_manager.dart';
import 'package:dart_event_manager/src/event/handler/event_handler_store.dart';
import 'package:dart_event_manager/src/request/handler/request_handler.dart';
import 'package:dart_event_manager/src/request/handler/request_handler_store.dart';
import 'package:dart_event_manager/src/request/pipeline/pipeline_behavior.dart';
import 'package:dart_event_manager/src/request/pipeline/pipeline_behavior_store.dart';
import 'package:dart_event_manager/src/request/request_manager.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockMediator extends Mock implements Mediator {}

class MockRequestManager extends Mock implements RequestManager {}

class MockDispatchStrategy extends Mock implements DispatchStrategy {}

class MockEventHandlerStore extends Mock implements EventHandlerStore {}

class MockRequestHandlerStore extends Mock implements RequestHandlerStore {}

class MockPipelineBehaviorStore extends Mock implements PipelineBehaviorStore {}

class MockEventHandler<T> extends Mock implements EventHandler<T> {}

class MockRequest<T> extends Mock implements Request<T> {}

class MockRequestHandler<Res, Req extends Request<Res>> extends Mock
    implements RequestHandler<Res, Req> {}

class MockPipelineBehavior<Res, Req> extends Mock
    implements PipelineBehavior<Res, Req> {}

class MockEventSubscription extends Mock implements EventSubscription {}

final throwsAssertionError = throwsA(TypeMatcher<AssertionError>());
