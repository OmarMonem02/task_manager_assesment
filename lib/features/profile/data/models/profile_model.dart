import '../../../auth/domain/entities/user_entity.dart';
import '../../domain/entities/profile_entity.dart';

class ProfileModel extends ProfileEntity {
  const ProfileModel({
    required super.username,
    required super.email,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      username: json['username'] ?? '',
      email: json['email'] ?? '',
    );
  }

  factory ProfileModel.fromUserEntity(UserEntity user) {
    return ProfileModel(
      username: user.username,
      email: user.email,
    );
  }

  factory ProfileModel.fromCache(Map<String, String> cache) {
    return ProfileModel(
      username: cache['username'] ?? '',
      email: cache['email'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
    };
  }
}
