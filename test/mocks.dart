import 'package:dart_event_manager/contracts.dart';
import 'package:dart_event_manager/event_manager.dart';
import 'package:dart_event_manager/src/event_handler/event_handler_store.dart';
import 'package:dart_event_manager/src/request_handler/request_handler.dart';
import 'package:dart_event_manager/src/request_handler/request_handler_store.dart';
import 'package:dart_event_manager/src/request_pipeline/pipeline_behavior.dart';
import 'package:dart_event_manager/src/request_pipeline/pipeline_behavior_store.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockEventManager extends Mock implements Mediator {}

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
