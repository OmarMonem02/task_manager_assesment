import 'package:equatable/equatable.dart';

class ProjectEntity extends Equatable {
  final int id;
  final String title;
  final int userId;

  const ProjectEntity({
    required this.id,
    required this.title,
    required this.userId,
  });

  @override
  List<Object?> get props => [id, title, userId];
}