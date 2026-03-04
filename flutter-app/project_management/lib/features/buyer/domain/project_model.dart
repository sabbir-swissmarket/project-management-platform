class Project {
  final String id;
  final String title;
  final String description;

  Project({required this.id, required this.title, required this.description});

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json["id"],
      title: json["title"],
      description: json["description"] ?? "",
    );
  }
}
