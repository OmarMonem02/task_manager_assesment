class RegisterRequestModel {
  const RegisterRequestModel({
    required this.username,
    required this.email,
    required this.password,
    this.expiresInMins = 60,
  });

  final String username;
  final String email;
  final String password;
  final int expiresInMins;

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'password': password,
      'expiresInMins': expiresInMins,
    };
  }
}
