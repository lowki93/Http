# Http
A lightweight Swift HTTP library

## Basic Usage

### Building a request
First step is to build a request. You make requests by providing extension on top of `Request` type:

```swift
extension Request {
  static func getUser() -> Self where Output == UserResponse {
    .get("getUser")
  }
}
```

And... voila! We defined a `getUser()` request which will request getUser endpoint  and waiting for a `UserResponse`.

You can also use an enum to define your Request path:

```swift
enum MyAppEndpoint: String, Path {
  case getUser
}

extension Request {
  static func getUser() -> Self where Output == UserResponse {
    .get(MyAppEndpoint.getUser)
  } 
}
```

### Sending a request

To send a request use a `Session` instance. `Session` is somewhat similar to `URLSession` but providing additional functionalities.

```swift
let session = Session(
  baseURL: URL(string: "https://github.com")!,
  configuration: SessionConfiguration(
    encoder: JSONEncoder(),
    decoder: JSONDecoder(),
  )
)

session.publisher(for: .getUser())
```

You can now use the returned publisher however you want. Its result is similar to what you have received with `URLSession.shared.dataTaskPublisher(for: ...).decode(type: UserResponse.self, decoder: JSONDecoder())`.

A few words about Session:

- `baseURL` will be prepended to all call endpoints
- You can skip encoder and decoder if you use JSON
- You can provide a custom `URLSession` instance if ever needed

## Send a body

### Encodable

You we build your request by sending your `body`  to construct it:

```swift
struct UserBody: Encodable {}

extension Request {
  static func login(_ body: UserBody) -> Self where Output == LoginResponse {
		.post("login", body: .encodable(body))	
  }
}
```

We defined a `login(_:)` request which will request login endpoint by sending a `UserBody` and waiting for a `LoginResponse`

### Multipart

You we build 2 request:

- send an `URL`
- send a `Data`

```swift
extension Request {
	static func send(audio: URL) throws -> Self where Output == SendAudioResponse {
    var multipart = MultipartFormData()
    try multipart.add(url: audio, name: "define_your_name")
    return .post("sendAudio", body: .multipart(multipart))
  }
  
  static func send(audio: Data) throws -> Self where Output == SendAudioResponse {
    var multipart = MultipartFormData()
    try multipartFormData.add(data: data, name: "your_name", fileName: "your_fileName", mimeType: "right_mimeType")
  	return .post("sendAudio", body: .multipart(multipart))
  }
}
```

We defined the 2  `send(audio:)` requests which will request `sendAudio` endpoint by sending an `URL` or a `Data` and waiting for a `SendAudioResponse`

We can add multiple `Data`/`URL` to the multipart

```swift
extension Request {
  static func send(audio: URL, image: Data) throws -> Self where Output == SendAudioImageResponse {
    var multipart = MultipartFormData()
    try multipart.add(url: audio, name: "define_your_name")
    try multipartFormData.add(data: image, name: "your_name", fileName: "your_fileName", mimeType: "right_mimeType")
    return .post("sendAudioImage", body: .multipart(multipart))
  }
}
```

## Interceptor

Protocol `Interceptor` enable powerful request interceptions. This include authentication, logging, request retrying, etc...

### `RequestInterceptor`

`RequestInterceptor` allow to adapt a or retry a request whenever it failed:

- `adaptRequest` method is called before making a request and allow you to transform it adding headers, changing path, ...
- `rescueRequestError` is called whenever the request fail. You'll have a chance to retry the request. This can be used to re-authenticate the user for instance

### `ResponseInterceptor`

`ResponseInterceptor` is dedicated to intercept and server responses:

- `adaptResponse` change the server output
- `receivedResponse` notify about the server final response (a valid output or error)
