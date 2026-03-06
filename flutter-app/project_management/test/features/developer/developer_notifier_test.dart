import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:project_management/features/shared/domain/entities/task.dart';
import 'package:project_management/features/developer/domain/repositories/developer_repository.dart';
import 'package:project_management/features/developer/presentation/provider/developer_provider.dart';

void main() {
  group('DeveloperNotifier', () {
    late _FakeDeveloperRepository repository;
    late DeveloperNotifier notifier;

    setUp(() {
      repository = _FakeDeveloperRepository();
      notifier = DeveloperNotifier(repository, autoLoad: false);
    });

    test('loadTasks emits AsyncData when repository succeeds', () async {
      repository.tasks = [
        Task(
          id: 't1',
          title: 'Build feature',
          description: 'Implement UI',
          status: 'todo',
          hourlyRate: 40,
          hoursLogged: 0,
        ),
      ];

      await notifier.loadTasks();

      expect(notifier.state, isA<AsyncData<List<Task>>>());
      expect(notifier.state.asData?.value.length, 1);
    });

    test('loadTasks captures repository errors', () async {
      repository.fetchShouldThrow = true;

      await notifier.loadTasks();

      expect(notifier.state, isA<AsyncError>());
    });

    test('submitTask delegates to repository and refreshes tasks', () async {
      repository.tasks = [
        Task(
          id: 't2',
          title: 'Fix bug',
          description: '',
          status: 'in_progress',
          hourlyRate: 60,
          hoursLogged: 4,
        ),
      ];

      await notifier.submitTask(
        taskId: 't2',
        hours: 5,
        filePath: '/tmp/file.zip',
      );

      expect(repository.submitCallCount, 1);
      expect(notifier.state.asData?.value.length, 1);
    });

    test('updateTaskStatus updates repository and reloads list', () async {
      repository.tasks = [
        Task(
          id: 't3',
          title: 'Docs',
          description: 'Write docs',
          status: 'todo',
          hourlyRate: 30,
          hoursLogged: 1,
        ),
      ];

      await notifier.updateTaskStatus(taskId: 't3', newStatus: 'in_progress');

      expect(repository.lastUpdate, equals({'taskId': 't3', 'status': 'in_progress'}));
      expect(notifier.state.asData?.value.length, 1);
    });
  });
}

class _FakeDeveloperRepository implements DeveloperRepository {
  List<Task> tasks = [];
  bool fetchShouldThrow = false;
  int submitCallCount = 0;
  Map<String, String>? lastUpdate;

  @override
  Future<List<Task>> fetchAssignedTasks() async {
    if (fetchShouldThrow) throw Exception('fetch error');
    return List<Task>.from(tasks);
  }

  @override
  Future<void> updateStatus(String taskId, String newStatus) async {
    lastUpdate = {'taskId': taskId, 'status': newStatus};
  }

  @override
  Future<void> submitTask({
    required String taskId,
    required double hours,
    required String filePath,
  }) async {
    submitCallCount += 1;
  }
}
