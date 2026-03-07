import 'package:dio/dio.dart';

import '../../domain/entities/admin_stats.dart';
import '../../domain/repositories/admin_repository.dart';
import '../models/admin_stats_model.dart';

class AdminRepositoryImpl implements AdminRepository {
  AdminRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<AdminStats> fetchStats() async {
    final response = await _dio.get('/admin/stats');
    return AdminStatsModel.fromJson(response.data as Map<String, dynamic>);
  }
}
