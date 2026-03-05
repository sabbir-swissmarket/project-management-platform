import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/presentation/provider/auth_provider.dart';
import '../../../buyer/domain/task_model.dart';
import '../provider/developer_provider.dart';

const Map<String, List<String>> _statusUpdateOptions = {
  'todo': ['todo', 'in_progress'],
  'in_progress': ['in_progress'],
  'submitted': ['submitted'],
  'paid': ['paid'],
};

const Map<String, String> _statusLabels = {
  'todo': 'To Do',
  'in_progress': 'In Progress',
  'submitted': 'Submitted',
  'paid': 'Paid',
};

class DeveloperDashboard extends ConsumerWidget {
  const DeveloperDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskState = ref.watch(developerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text("Developer Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: "Refresh",
            onPressed: () => ref.read(developerProvider.notifier).loadTasks(),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) {
                context.go('/login');
              }
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: taskState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => _ErrorView(
            message: e.toString(),
            onRetry: () => ref.read(developerProvider.notifier).loadTasks(),
          ),
          data: (tasks) => RefreshIndicator(
            onRefresh: () => ref.read(developerProvider.notifier).loadTasks(),
            child: tasks.isEmpty
                ? _EmptyState(
                    onRetry: () =>
                        ref.read(developerProvider.notifier).loadTasks(),
                  )
                : ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    itemCount: tasks.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final task = tasks[index];

                      return _TaskCard(
                        task: task,
                        onSubmit: task.status == "in_progress"
                            ? () => context.push(
                                '/developer/task/${task.id}/submit',
                              )
                            : null,
                        onStatusChanged: (status) =>
                            _handleStatusUpdate(context, ref, task, status),
                      );
                    },
                  ),
          ),
        ),
      ),
    );
  }
}

Future<void> _handleStatusUpdate(
  BuildContext context,
  WidgetRef ref,
  Task task,
  String? newStatus,
) async {
  if (newStatus == null || newStatus == task.status) return;

  try {
    await ref
        .read(developerProvider.notifier)
        .updateTaskStatus(taskId: task.id, newStatus: newStatus);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Status updated to ${_formatStatus(newStatus)}'),
        ),
      );
    }
  } catch (error) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update status: ${error.toString()}'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }
}

class _TaskCard extends StatelessWidget {
  final Task task;
  final Future<void> Function(String newStatus) onStatusChanged;
  final VoidCallback? onSubmit;

  const _TaskCard({
    required this.task,
    required this.onStatusChanged,
    this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final statusOptions = _statusUpdateOptions[task.status] ?? [task.status];
    final canChangeStatus = statusOptions.any(
      (status) => status != task.status,
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(blurRadius: 10, color: Colors.black12)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  task.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Chip(
                backgroundColor: _statusChipColor(task.status),
                label: Text(
                  _formatStatus(task.status),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: _statusChipTextColor(task.status),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            task.description.isEmpty
                ? "No description provided."
                : task.description,
            style: const TextStyle(color: Color(0xFF475569)),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _TaskMetric(
                icon: Icons.payments_outlined,
                label: "Hourly Rate",
                value: "\$${task.hourlyRate.toStringAsFixed(2)}/hr",
              ),
              const SizedBox(width: 12),
              _TaskMetric(
                icon: Icons.timelapse,
                label: "Hours Logged",
                value: task.hoursLogged.toStringAsFixed(1),
              ),
            ],
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: task.status,
            items: statusOptions
                .map(
                  (status) => DropdownMenuItem(
                    value: status,
                    child: Text(_formatStatus(status)),
                  ),
                )
                .toList(),
            onChanged: canChangeStatus
                ? (value) async {
                    if (value == null || value == task.status) return;
                    await onStatusChanged(value);
                  }
                : null,
            decoration: InputDecoration(
              labelText: canChangeStatus ? "Update Status" : "Current Status",
              border: const OutlineInputBorder(),
            ),
          ),
          if (!canChangeStatus)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                task.status == "in_progress"
                    ? "Submit your deliverables once completed."
                    : "Status changes are not available at this stage.",
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: onSubmit,
              icon: const Icon(Icons.upload_file),
              label: const Text("Submit Work"),
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskMetric extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _TaskMetric({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: const Color(0xFF2563EB)),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                  Text(
                    value,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onRetry;

  const _EmptyState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.1),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.task_alt_outlined,
                size: 72,
                color: Colors.green.shade300,
              ),
              const SizedBox(height: 12),
              const Text(
                "No assigned tasks yet",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              const Text(
                "Pull to refresh or check back later.",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text("Refresh"),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: onRetry, child: const Text("Try Again")),
        ],
      ),
    );
  }
}

String _formatStatus(String status) {
  return _statusLabels[status] ??
      status
          .split('_')
          .map(
            (word) => word.isEmpty
                ? word
                : '${word[0].toUpperCase()}${word.substring(1)}',
          )
          .join(' ');
}

Color _statusChipColor(String status) {
  switch (status) {
    case 'todo':
      return Colors.orange.shade50;
    case 'in_progress':
      return Colors.indigo.shade50;
    case 'submitted':
      return Colors.blueGrey.shade50;
    case 'paid':
      return Colors.green.shade50;
    default:
      return Colors.grey.shade200;
  }
}

Color _statusChipTextColor(String status) {
  switch (status) {
    case 'todo':
      return Colors.orange.shade800;
    case 'in_progress':
      return Colors.indigo.shade700;
    case 'submitted':
      return Colors.blueGrey.shade700;
    case 'paid':
      return Colors.green.shade700;
    default:
      return Colors.grey.shade700;
  }
}
