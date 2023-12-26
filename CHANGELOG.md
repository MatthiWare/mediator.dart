## 0.2.0

- `RequestManager.send` now only accepts a single generic argument, `TResponse`, which is the type of the response body. The `TRequest` type argument has been removed. The type of the Response will be inferred based on the given `Request<Response>` (#3)

## 0.1.1

- Add `registerFactory` and `registerFunction` methods to `RequestManager`.

## 0.1.0

- Initial version.
