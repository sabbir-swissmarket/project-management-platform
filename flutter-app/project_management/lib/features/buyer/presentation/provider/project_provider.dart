import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:project_management/core/network/dio_provider.dart';
import 'package:project_management/features/buyer/domain/project_model.dart';

import '../../data/buyer_repository.dart';

final projectProvider =
    StateNotifierProvider<ProjectNotifier, AsyncValue<List<Project>>>((ref) {
      final dio = DioProvider.createDio();
      return ProjectNotifier(BuyerRepository(dio));
    });

class ProjectNotifier extends StateNotifier<AsyncValue<List<Project>>> {
  final BuyerRepository repository;

  ProjectNotifier(this.repository) : super(const AsyncLoading()) {
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

  Future<void> refresh() async {
    state = const AsyncLoading();
    await loadProjects();
  }
}
