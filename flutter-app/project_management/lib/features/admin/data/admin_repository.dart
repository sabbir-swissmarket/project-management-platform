import 'package:dio/dio.dart';

import '../domain/admin_stats_model.dart';

class AdminRepository {
  final Dio dio;

  AdminRepository(this.dio);

  Future<AdminStats> fetchStats() async {
    final response = await dio.get("/admin/stats");

    return AdminStats.fromJson(response.data);
  }
}
