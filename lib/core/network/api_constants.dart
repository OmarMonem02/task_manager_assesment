class ApiConstants {
  // Auth API - dummyjson
  static const String authBaseUrl = 'https://dummyjson.com';
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/users/add';
  static const String getMeEndpoint = '/auth/me';
  static const String refreshTokenEndpoint = '/auth/refresh';

  // Projects & Tasks API - mockapi
  static const String projectsBaseUrl = 'https://6a3e00650443193a1a0b4a35.mockapi.io/';
  static const String albumsEndpoint = '/projects';
  static const String todosEndpoint = '/tasks';

  // Timeouts
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;
}