class Task {
  final String id;
  final String title;
  final String description;
  final String status;
  final double hourlyRate;
  final double hoursLogged;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.hourlyRate,
    required this.hoursLogged,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json["id"],
      title: json["title"],
      description: json["description"] ?? "",
      status: json["status"],
      hourlyRate: (json["hourly_rate"] as num).toDouble(),
      hoursLogged: (json["hours_logged"] ?? 0).toDouble(),
    );
  }
}
