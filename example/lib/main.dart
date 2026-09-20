import 'package:auto_reply_sync/auto_reply_sync.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

final dio = Dio(
  BaseOptions(
    baseUrl: 'https://jsonplaceholder.typicode.com',
    connectTimeout: const Duration(seconds: 10),
  ),
)..interceptors.add(AutoReplyDioInterceptor());

final httpClient = LoggingHttpClient();

void main() {
  logger.configure(
    const LoggerConfig(
      enabled: true,
      maxEntries: 500,
      mirrorToConsole: true,
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'auto_reply_sync demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const AutoReplyLoggerViewer(
        child: DemoHomePage(),
      ),
    );
  }
}

class DemoHomePage extends StatefulWidget {
  const DemoHomePage({super.key});

  @override
  State<DemoHomePage> createState() => _DemoHomePageState();
}

class _DemoHomePageState extends State<DemoHomePage> {
  String _status = 'Tap a button to emit traffic';

  Future<void> _dioGet() async {
    setState(() => _status = 'Dio GET…');
    try {
      final res = await dio.get('/posts/1');
      setState(() => _status = 'Dio GET ${res.statusCode}');
    } catch (e) {
      setState(() => _status = 'Dio error: $e');
    }
  }

  Future<void> _dioFail() async {
    setState(() => _status = 'Dio 404…');
    try {
      await dio.get('/this-will-404');
    } catch (_) {
      setState(() => _status = 'Dio 404 logged');
    }
  }

  Future<void> _httpGet() async {
    setState(() => _status = 'http GET…');
    try {
      final res = await httpClient.get(
        Uri.parse('https://jsonplaceholder.typicode.com/todos/1'),
      );
      setState(() => _status = 'http GET ${res.statusCode}');
    } catch (e) {
      setState(() => _status = 'http error: $e');
    }
  }


  void _restClientStacks() {
    // Shows how each named stack appears in the NET filter.
    // In real apps: attach RetrofitNetwork.interceptor() / ChopperNetwork.interceptor()
    // / OpenApiNetwork.dioInterceptor() to the shared client once.
    NetworkLogger.rest(
      method: 'GET',
      url: 'https://api.example.com/retrofit/users',
      stack: NetworkStack.retrofit,
      statusCode: 200,
      durationMs: 40,
      responseBody: {'id': 1},
    );
    NetworkLogger.rest(
      method: 'POST',
      url: 'https://api.example.com/chopper/users',
      stack: NetworkStack.chopper,
      statusCode: 201,
      durationMs: 55,
      requestBody: {'name': 'Ada'},
      responseBody: {'id': 2},
    );
    NetworkLogger.rest(
      method: 'GET',
      url: 'https://api.example.com/openapi/pets/1',
      stack: NetworkStack.openapi,
      statusCode: 200,
      durationMs: 33,
      responseBody: {'id': 1, 'name': 'doggie'},
    );
    setState(() => _status = 'Retrofit / Chopper / OpenAPI stacks logged');
  }

  void _manualSamples() {
    NetworkLogger.graphql(
      operationName: 'GetUser',
      url: 'https://api.example.com/graphql',
      query: 'query GetUser(\$id: ID!) { user(id: \$id) { name } }',
      variables: {'id': '1'},
      statusCode: 200,
      responseBody: {
        'data': {'user': {'name': 'Ada'}},
      },
    );
    NetworkLogger.grpc(
      method: 'GetUser',
      service: 'user.v1.UserService',
      statusCode: 0,
      durationMs: 42,
      requestBody: {'id': '1'},
      responseBody: {'name': 'Ada'},
    );
    RealtimeNetwork.ws(
      url: 'wss://echo.example.com',
      event: 'message',
      payload: {'type': 'ping'},
    );
    NetworkLogger.sse(
      url: 'https://api.example.com/events',
      event: 'update',
      data: {'count': 3},
      statusCode: 200,
    );
    setState(() => _status = 'Manual GraphQL / gRPC / WS / SSE logged');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Network logger demo')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_status, textAlign: TextAlign.center),
              const SizedBox(height: 8),
              const Text(
                'Open the floating terminal → filter with NET',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _dioGet,
                icon: const Icon(Icons.cloud_download),
                label: const Text('Dio GET (covers Retrofit/OpenAPI on Dio)'),
              ),
              const SizedBox(height: 8),
              FilledButton.tonalIcon(
                onPressed: _dioFail,
                icon: const Icon(Icons.error_outline),
                label: const Text('Dio failing request'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _httpGet,
                icon: const Icon(Icons.http),
                label: const Text('http Client GET'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _restClientStacks,
                icon: const Icon(Icons.extension),
                label: const Text('Retrofit / Chopper / OpenAPI samples'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _manualSamples,
                icon: const Icon(Icons.hub),
                label: const Text('GraphQL / gRPC / WS / SSE samples'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
