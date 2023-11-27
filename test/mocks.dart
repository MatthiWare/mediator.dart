import 'package:dart_event_manager/event_manager.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockEventManager extends Mock implements EventManager {}

class MockEventHandler<T> extends Mock implements EventHandler<T> {}

class MockEventSubscription extends Mock implements EventSubscription {}

final throwsAssertionError = throwsA(TypeMatcher<AssertionError>());
