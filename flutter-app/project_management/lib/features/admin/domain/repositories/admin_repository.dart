import '../entities/admin_stats.dart';

abstract class AdminRepository {
  Future<AdminStats> fetchStats();
}
