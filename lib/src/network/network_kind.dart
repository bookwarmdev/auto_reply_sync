/// High-level networking family from the integration map.
enum NetworkKind {
  rest,
  grpc,
  graphql,
  websocket,
  sse,
}

/// Concrete client / stack that produced the call.
enum NetworkStack {
  http,
  dio,
  retrofit,
  chopper,
  openapi,
  graphql,
  websocket,
  sse,
  grpc,
  custom,
}

extension NetworkKindX on NetworkKind {
  String get label {
    switch (this) {
      case NetworkKind.rest:
        return 'REST';
      case NetworkKind.grpc:
        return 'gRPC';
      case NetworkKind.graphql:
        return 'GraphQL';
      case NetworkKind.websocket:
        return 'WebSocket';
      case NetworkKind.sse:
        return 'SSE';
    }
  }
}

extension NetworkStackX on NetworkStack {
  String get label {
    switch (this) {
      case NetworkStack.http:
        return 'http';
      case NetworkStack.dio:
        return 'Dio';
      case NetworkStack.retrofit:
        return 'Retrofit';
      case NetworkStack.chopper:
        return 'Chopper';
      case NetworkStack.openapi:
        return 'OpenAPI';
      case NetworkStack.graphql:
        return 'GraphQL';
      case NetworkStack.websocket:
        return 'WebSocket';
      case NetworkStack.sse:
        return 'SSE';
      case NetworkStack.grpc:
        return 'gRPC';
      case NetworkStack.custom:
        return 'custom';
    }
  }
}
