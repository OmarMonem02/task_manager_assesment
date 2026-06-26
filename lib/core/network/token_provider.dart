import '../storage/session_storage.dart';

abstract class TokenProvider {
  Future<String?> getAccessToken();
}

class SessionTokenProvider implements TokenProvider {
  SessionTokenProvider(this._sessionStorage);

  final SessionStorage _sessionStorage;

  @override
  Future<String?> getAccessToken() => _sessionStorage.getAccessToken();
}
