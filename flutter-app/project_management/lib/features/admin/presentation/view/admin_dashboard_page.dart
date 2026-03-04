import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/provider/auth_provider.dart';
import '../provider/admin_provider.dart';
import '../widgets/stat_card.dart';

class AdminDashboard extends ConsumerWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adminState = ref.watch(adminProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(adminProvider.notifier).refresh(),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authProvider.notifier).logout(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: adminState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => const Center(child: Text("Error loading stats")),
          data: (stats) {
            return GridView.count(
              crossAxisCount: 3,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              children: [
                StatCard(
                  title: "Total Projects",
                  value: stats.totalProjects.toString(),
                  icon: Icons.folder,
                  color: Colors.blue,
                ),
                StatCard(
                  title: "Total Tasks",
                  value: stats.totalTasks.toString(),
                  icon: Icons.task,
                  color: Colors.green,
                ),
                StatCard(
                  title: "Completed Tasks",
                  value: stats.completedTasks.toString(),
                  icon: Icons.check_circle,
                  color: Colors.indigo,
                ),
                StatCard(
                  title: "Total Payments",
                  value: stats.totalPayments.toString(),
                  icon: Icons.payment,
                  color: Colors.orange,
                ),
                StatCard(
                  title: "Pending Payments",
                  value: stats.pendingPayments.toString(),
                  icon: Icons.hourglass_bottom,
                  color: Colors.red,
                ),
                StatCard(
                  title: "Revenue Generated",
                  value: "\$${stats.revenueGenerated.toStringAsFixed(2)}",
                  icon: Icons.attach_money,
                  color: Colors.purple,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
