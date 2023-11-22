import 'package:dart_event_manager/event_manager.dart';
import 'package:mocktail/mocktail.dart';

class MockEventManager extends Mock implements EventManager {}

class MockEventHandler<T> extends Mock implements EventHandler<T> {}
