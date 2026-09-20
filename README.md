# auto_reply_sync

In-app floating logger for Flutter — structured events, levels, search/filter, **easy network capture**, and a DevTools-style overlay.

## Network map → one-line wiring

```
NETWORKING
    ├── REST
    │     ├── http      → LoggingHttpClient()
    │     ├── Dio       → AutoReplyDioInterceptor()
    │     ├── Retrofit  → RetrofitNetwork.interceptor()
    │     ├── Chopper   → AutoReplyChopperInterceptor() / ChopperNetwork.interceptor()
    │     └── OpenAPI   → OpenApiNetwork.dioInterceptor() or OpenApiNetwork.httpClient()
    ├── GraphQL         → GraphQlNetwork.trace(...) / NetworkLogger.graphql(...)
    ├── gRPC            → NetworkLogger.grpc(...)
    ├── WebSocket       → RealtimeNetwork.ws(...)
    └── SSE             → RealtimeNetwork.listenSse(...) / NetworkLogger.sse(...)
```

### Dio

```dart
final dio = Dio()..interceptors.add(AutoReplyDioInterceptor());
```

### Retrofit (`package:retrofit`)

```dart
final dio = Dio()..interceptors.add(RetrofitNetwork.interceptor());
final api = RestClient(dio);
```

### Chopper

```dart
final chopper = ChopperClient(
  baseUrl: Uri.parse('https://api.example.com'),
  interceptors: [ChopperNetwork.interceptor()],
);
```

### OpenAPI / Swagger generated clients

```dart
// Dio-based generator
final dio = Dio()..interceptors.add(OpenApiNetwork.dioInterceptor());

// http-based generator
final api = DefaultApi(OpenApiNetwork.httpClient());
```

### http package

```dart
final client = LoggingHttpClient();
```

Open the floating terminal and tap **NET**. Detail sheet can **Copy cURL**. Stack shows as `retrofit` / `chopper` / `openapi` in log properties.
