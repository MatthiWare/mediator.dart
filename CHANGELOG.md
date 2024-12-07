## 0.3.2

- Add `combineLatest`, `merge` and `zip` event extension methods (#20)
- Add `sendStream` method to `RequestManager` (#21)
- Add more cancellation functionality (#19)

## 0.3.1

- Avoid concurrent modification errors (#14)
- Remove empty event handlers assert (#15)
- Fix unhandled exception when using multiple concrete pipelines (#17)

## 0.3.0

- Reworked `registerFactory` methods used on `RequestManager`, `EventManager` and `PipelineConfigurator` to be extension methods (#9)
- The built-in `EventHandler`, `RequestHandler` and `PipelineBehavior` are now immutable (#9)
- Only 1 pipeline behavior will be returned if the same instance is registered multiple times using `register` and `registerGeneric` methods (#10)
- `RequestManager.unregister` added (#11)

## 0.2.0

- `RequestManager.send` now only accepts a single generic argument, `TResponse`, which is the type of the response body. The `TRequest` type argument has been removed. The type of the Response will be inferred based on the given `Request<Response>` (#3)

## 0.1.1

- Add `registerFactory` and `registerFunction` methods to `RequestManager`.

## 0.1.0

- Initial version.
