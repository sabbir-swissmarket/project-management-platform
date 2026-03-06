class AdminStats {
  final int totalProjects;
  final int totalTasks;
  final int completedTasks;
  final int totalPayments;
  final int pendingPayments;
  final double totalDeveloperHours;
  final double revenueGenerated;

  const AdminStats({
    required this.totalProjects,
    required this.totalTasks,
    required this.completedTasks,
    required this.totalPayments,
    required this.pendingPayments,
    required this.totalDeveloperHours,
    required this.revenueGenerated,
  });
}
