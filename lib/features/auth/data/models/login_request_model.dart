class LoginRequestModel {
  const LoginRequestModel({
    required this.username,
    required this.password,
    this.expiresInMins = 60,
  });

  final String username;
  final String password;
  final int expiresInMins;

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
      'expiresInMins': expiresInMins,
    };
  }
}
