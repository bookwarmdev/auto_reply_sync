# auto_reply_sync

In-app floating logger for Flutter — structured events, levels, search/filter, **easy network capture**, and a DevTools-style overlay.

## How to view the floating log icon

Wrap your app (or any screen) with `AutoReplyLoggerViewer`. A **draggable terminal FAB** appears on top of your UI.

```dart
import 'package:auto_reply_sync/auto_reply_sync.dart';
import 'package:flutter/material.dart';

void main() {
  logger.configure(const LoggerConfig(enabled: true, maxEntries: 500));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AutoReplyLoggerViewer(
        // Optional: fabColor, backgroundColor, showFab: false
        child: const HomePage(),
      ),
    );
  }
}
```

### Using the overlay

1. **Open** — tap the floating terminal icon (drag it to reposition).
2. **Browse logs** — newest entries appear in the bottom panel.
3. **Search** — type in the search field.
4. **Filter** — tap the filter icon to select log levels and/or **Network only**.
5. **API detail** — tap a network row for **Timing / Headers / Payload / Preview / Response** (copy cURL from the toolbar).
6. **Toolbar** — pause/resume logging, clear, export (clipboard), expand/collapse, close.

Emit logs from anywhere:

```dart
logger.i('Hello', source: 'HomePage');
logger.e('Failed', source: 'Api', properties: {'status': 500});
```

Try the demo:

```bash
cd example && flutter run
```

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
