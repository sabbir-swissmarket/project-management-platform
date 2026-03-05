import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_management/core/network/dio_provider.dart';
import 'package:project_management/features/buyer/data/buyer_repository.dart';

import '../../../auth/presentation/provider/auth_provider.dart';
import '../provider/task_provider.dart';

class TaskDetailsPage extends ConsumerWidget {
  final String projectId;
  final String taskId;

  const TaskDetailsPage({
    super.key,
    required this.projectId,
    required this.taskId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repository = BuyerRepository(DioProvider.createDio());

    final asyncTasks = ref.watch(taskProvider);
    final authState = ref.watch(authProvider);
    final userRole = authState.role;

    return asyncTasks.when(
      data: (tasks) {
        final task = tasks.firstWhere(
          (t) => t.id == taskId,
          orElse: () => throw Exception('Task not found'),
        );
        final totalDue = task.hourlyRate * task.hoursLogged;

        return Scaffold(
          appBar: AppBar(title: Text(task.title)),
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Status: ${task.status}"),
                const SizedBox(height: 12),

                if (userRole == "buyer" && task.status == "submitted") ...[
                  Text("Hours Logged: ${task.hoursLogged}"),
                  Text("Hourly Rate: \$${task.hourlyRate}"),
                  Text("Total Due: \$${totalDue.toStringAsFixed(2)}"),
                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: () async {
                      await repository.payForTask(task.id);

                      await ref.read(taskProvider.notifier).refresh(projectId);

                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                    },
                    child: const Text("Pay Now"),
                  ),
                ],

                if (task.status == "paid") ...[
                  ElevatedButton(
                    onPressed: () async {
                      await _handleDownloadSolution(
                        context: context,
                        repository: repository,
                        taskId: task.id,
                      );
                    },
                    child: const Text("Download Solution"),
                  ),
                ],
              ],
            ),
          ),
        );
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, st) =>
          Scaffold(body: Center(child: Text('Error loading task: $e'))),
    );
  }
}

Future<void> _handleDownloadSolution({
  required BuildContext context,
  required BuyerRepository repository,
  required String taskId,
}) async {
  final navigator = Navigator.of(context, rootNavigator: true);

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const Center(child: CircularProgressIndicator()),
  );

  try {
    final savedPath = await repository.downloadSolution(taskId);

    if (navigator.mounted) {
      navigator.pop();
    }

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Solution saved to $savedPath')),
    );
  } catch (error) {
    if (navigator.mounted) {
      navigator.pop();
    }

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Failed to download file: $error'),
        backgroundColor: Colors.redAccent,
      ),
    );
  }
}
