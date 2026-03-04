import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../../core/network/dio_provider.dart';
import '../../data/buyer_repository.dart';
import '../../domain/project_model.dart';
import '../../domain/developer_model.dart';

final buyerProvider =
    StateNotifierProvider<BuyerNotifier, AsyncValue<List<Project>>>((ref) {
      final dio = DioProvider.createDio();
      return BuyerNotifier(BuyerRepository(dio));
    });

class BuyerNotifier extends StateNotifier<AsyncValue<List<Project>>> {
  final BuyerRepository repository;

  BuyerNotifier(this.repository) : super(const AsyncLoading()) {
    loadProjects();
  }

  Future<void> loadProjects() async {
    try {
      final projects = await repository.fetchProjects();
      state = AsyncData(projects);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<void> createProject(String title, String description) async {
    try {
      await repository.createProject(title, description);
      await loadProjects();
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<List<Developer>> fetchDevelopers() {
    return repository.fetchDevelopers();
  }

  Future<void> createTask({
    required String projectId,
    required String title,
    required String description,
    required double rate,
    required String developerId,
  }) async {
    try {
      await repository.createTask(
        projectId: projectId,
        title: title,
        description: description,
        hourlyRate: rate,
        developerId: developerId,
      );

      await loadProjects();
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }
}
