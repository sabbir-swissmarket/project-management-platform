class AdminStats {
  final int totalProjects;
  final int totalTasks;
  final int completedTasks;
  final int totalPayments;
  final int pendingPayments;
  final double totalDeveloperHours;
  final double revenueGenerated;

  AdminStats({
    required this.totalProjects,
    required this.totalTasks,
    required this.completedTasks,
    required this.totalPayments,
    required this.pendingPayments,
    required this.totalDeveloperHours,
    required this.revenueGenerated,
  });

  factory AdminStats.fromJson(Map<String, dynamic> json) {
    return AdminStats(
      totalProjects: json["total_projects"],
      totalTasks: json["total_tasks"],
      completedTasks: json["completed_tasks"],
      totalPayments: json["total_payments"],
      pendingPayments: json["pending_payments"],
      totalDeveloperHours: (json["total_developer_hours"] as num).toDouble(),
      revenueGenerated: (json["revenue_generated"] as num).toDouble(),
    );
  }
}
