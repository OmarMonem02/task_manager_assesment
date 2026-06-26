import 'package:equatable/equatable.dart';

class ProfileEntity extends Equatable {
  final String username;
  final String email;

  const ProfileEntity({
    required this.username,
    required this.email,
  });

  @override
  List<Object?> get props => [username, email];
}
