class Task {
  final String id;
  final String title;
  final String description;
  final String status;
  final double hourlyRate;
  final double hoursLogged;

  const Task({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.hourlyRate,
    required this.hoursLogged,
  });
}
