import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:project_management/features/shared/domain/entities/project.dart';

import '../../domain/repositories/buyer_repository.dart';
import 'buyer_repository_provider.dart';

final projectProvider =
    StateNotifierProvider<ProjectNotifier, AsyncValue<List<Project>>>((ref) {
      final repository = ref.read(buyerRepositoryProvider);
      return ProjectNotifier(repository);
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
