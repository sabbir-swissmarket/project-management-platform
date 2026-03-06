import '../../domain/entities/developer.dart';

class DeveloperModel extends Developer {
  const DeveloperModel({
    required super.id,
    required super.name,
    required super.email,
  });

  factory DeveloperModel.fromJson(Map<String, dynamic> json) {
    return DeveloperModel(
      id: json['id'] as String,
      name: (json['name'] ?? '') as String,
      email: (json['email'] ?? '') as String,
    );
  }
}
