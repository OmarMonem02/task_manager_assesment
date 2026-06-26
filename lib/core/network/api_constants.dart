class ApiConstants {
  // Auth API - dummyjson
  static const String authBaseUrl = 'https://dummyjson.com';
  static const String loginEndpoint = '/auth/login';
  static const String getMeEndpoint = '/auth/me';
  static const String refreshTokenEndpoint = '/auth/refresh';

  // Projects & Tasks API - jsonplaceholder
  static const String projectsBaseUrl = 'https://jsonplaceholder.typicode.com';
  static const String albumsEndpoint = '/albums';
  static const String todosEndpoint = '/todos';

  // Timeouts
  static const int connectTimeout = 300;
  static const int receiveTimeout = 300;
}