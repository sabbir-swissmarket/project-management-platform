import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../../core/network/dio_provider.dart';
import '../../data/admin_repository.dart';
import '../../domain/admin_stats_model.dart';

final adminProvider =
    StateNotifierProvider<AdminNotifier, AsyncValue<AdminStats>>((ref) {
      final dio = DioProvider.createDio();
      return AdminNotifier(AdminRepository(dio));
    });

class AdminNotifier extends StateNotifier<AsyncValue<AdminStats>> {
  final AdminRepository repository;

  AdminNotifier(this.repository) : super(const AsyncLoading()) {
    loadStats();
  }

  Future<void> loadStats() async {
    try {
      final stats = await repository.fetchStats();
      state = AsyncData(stats);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    await loadStats();
  }
}
