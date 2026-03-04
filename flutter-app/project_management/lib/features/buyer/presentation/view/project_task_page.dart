import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../provider/task_provider.dart';

class ProjectTasksPage extends ConsumerStatefulWidget {
  final String projectId;

  const ProjectTasksPage({super.key, required this.projectId});

  @override
  ConsumerState<ProjectTasksPage> createState() => _ProjectTasksPageState();
}

class _ProjectTasksPageState extends ConsumerState<ProjectTasksPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(taskProvider.notifier).loadTasks(widget.projectId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final taskState = ref.watch(taskProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Project Tasks")),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await context.push('/buyer/${widget.projectId}/create-task');

          // Refresh after returning
          ref.read(taskProvider.notifier).refresh(widget.projectId);
        },
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: taskState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => const Center(child: Text("Error loading tasks")),
          data: (tasks) {
            if (tasks.isEmpty) {
              return const Center(child: Text("No tasks created yet"));
            }

            return ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    title: Text(task.title),
                    subtitle: Text(
                      "Status: ${task.status}\nRate: \$${task.hourlyRate}/hr",
                    ),
                    isThreeLine: true,
                    trailing: const Icon(Icons.arrow_forward),
                    onTap: () async {
                      await context.push(
                        '/buyer/${widget.projectId}/task/${task.id}',
                      );

                      // Refresh after returning
                      ref.read(taskProvider.notifier).refresh(widget.projectId);
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
