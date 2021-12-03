# Http
A lightweight Swift HTTP library

## Basic Usage

### Building a request
First step is to build a request. You make requests by providing extension on top of `Request` type:

```swift
enum MyAppEndpoint: String, Path {
  case login
}

extension Request {
  static let func login(_ body: UserBody) -> Self where Output == UserResponse {
    .post(MyAppEndpoint.login, body: body)
  }
}
```

And... voila! We defined a `login(_:)` request which will request login endpoint by sending a `UserBody` and waiting for a `UserResponse`. Now it's time to use it.

### Sending a request

To send a request use a `Session` instance. `Session` is somewhat similar to `URLSession` but providing additional functionalities.

```swift

let session = Session(baseURL: URL(string: "https://github.com")!, encoder: JSONEncoder(), decoder: JSONDecoder())

session.publisher(for: .login(UserBody(username: "pjechris", password: "MyPassword")))

```

You can now use the returned publisher however you want. Its result is similar to what you have received with `URLSession.shared.dataTaskPublisher(for: ...).decode(type: UserResponse.self, decoder: JSONDecoder())`.

A few words about Session:

- `baseURL` will be prepended to all call endpoints
- You can skip encoder and decoder if you use JSON
- You can provide a custom `URLSession` instance if ever needed
