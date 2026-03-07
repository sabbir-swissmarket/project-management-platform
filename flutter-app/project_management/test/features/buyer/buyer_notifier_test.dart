import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:project_management/features/buyer/domain/repositories/buyer_repository.dart';
import 'package:project_management/features/shared/domain/entities/developer.dart';
import 'package:project_management/features/shared/domain/entities/project.dart';
import 'package:project_management/features/shared/domain/entities/task.dart';
import 'package:project_management/features/buyer/presentation/provider/buyer_provider.dart';

void main() {
  group('BuyerNotifier', () {
    late _FakeBuyerRepository repository;
    late BuyerNotifier notifier;

    setUp(() {
      repository = _FakeBuyerRepository();
      notifier = BuyerNotifier(repository, autoLoad: false);
    });

    test('loadProjects emits data on success', () async {
      repository.projects = [
        Project(id: '1', title: 'A', description: 'Alpha'),
        Project(id: '2', title: 'B', description: 'Beta'),
      ];

      await notifier.loadProjects();

      expect(notifier.state, isA<AsyncData<List<Project>>>());
      expect(notifier.state.asData?.value.length, 2);
    });

    test('loadProjects surfaces repository errors', () async {
      repository.shouldThrow = true;

      await notifier.loadProjects();

      expect(notifier.state, isA<AsyncError>());
    });

    test('createProject persists and refreshes the list', () async {
      await notifier.createProject('Project X', 'Desc');

      expect(repository.projects, isNotEmpty);
      expect(notifier.state.asData?.value.first.title, 'Project X');
    });

    test('createTask delegates to repository and reloads projects', () async {
      repository.projects = [
        Project(id: 'p1', title: 'Existing', description: ''),
      ];
      await notifier.loadProjects();

      await notifier.createTask(
        projectId: 'p1',
        title: 'Task 1',
        description: 'Implement feature',
        rate: 45,
        developerId: 'dev1',
      );

      expect(repository.lastCreateTask, isNotNull);
      expect(repository.lastCreateTask!['projectId'], 'p1');
      expect(notifier.state.asData?.value.length, 1);
    });

    test('fetchDevelopers returns repository entries', () async {
      repository.developers = [
        Developer(id: 'dev1', name: 'Sam', email: 'sam@test.dev'),
      ];

      final result = await notifier.fetchDevelopers();

      expect(result.length, 1);
      expect(result.first.name, 'Sam');
    });
  });
}

class _FakeBuyerRepository implements BuyerRepository {
  List<Project> projects = [];
  List<Developer> developers = [];
  bool shouldThrow = false;
  Map<String, dynamic>? lastCreateTask;

  @override
  Future<List<Project>> fetchProjects() async {
    if (shouldThrow) throw Exception('network');
    return List<Project>.from(projects);
  }

  @override
  Future<List<Task>> fetchTasks(String projectId) {
    throw UnimplementedError();
  }

  @override
  Future<void> createProject(String title, String description) async {
    projects = [
      ...projects,
      Project(
        id: 'p${projects.length + 1}',
        title: title,
        description: description,
      ),
    ];
  }

  @override
  Future<List<Developer>> fetchDevelopers() async {
    return List<Developer>.from(developers);
  }

  @override
  Future<void> createTask({
    required String projectId,
    required String title,
    required String description,
    required double hourlyRate,
    required String developerId,
  }) async {
    lastCreateTask = {
      'projectId': projectId,
      'title': title,
      'description': description,
      'hourlyRate': hourlyRate,
      'developerId': developerId,
    };
  }

  @override
  Future<void> payForTask(String taskId) {
    throw UnimplementedError();
  }

  @override
  Future<String> downloadSolution(String taskId) {
    throw UnimplementedError();
  }
}
