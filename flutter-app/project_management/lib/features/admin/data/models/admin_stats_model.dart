import '../../domain/entities/admin_stats.dart';

class AdminStatsModel extends AdminStats {
  const AdminStatsModel({
    required super.totalProjects,
    required super.totalTasks,
    required super.completedTasks,
    required super.totalPayments,
    required super.pendingPayments,
    required super.totalDeveloperHours,
    required super.revenueGenerated,
  });

  factory AdminStatsModel.fromJson(Map<String, dynamic> json) {
    return AdminStatsModel(
      totalProjects: json['total_projects'] as int,
      totalTasks: json['total_tasks'] as int,
      completedTasks: json['completed_tasks'] as int,
      totalPayments: json['total_payments'] as int,
      pendingPayments: json['pending_payments'] as int,
      totalDeveloperHours: (json['total_developer_hours'] as num).toDouble(),
      revenueGenerated: (json['revenue_generated'] as num).toDouble(),
    );
  }
}
