import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/admin/presentation/view/admin_dashboard_page.dart';
import '../../features/auth/domain/auth_state.dart';
import '../../features/auth/presentation/provider/auth_provider.dart';
import '../../features/auth/presentation/view/login_page.dart';
import '../../features/buyer/presentation/view/buyer_dashboard.dart';
import '../../features/buyer/presentation/view/create_project_page.dart';
import '../../features/buyer/presentation/view/create_task_page.dart';
import '../../features/buyer/presentation/view/project_task_page.dart';
import '../../features/buyer/presentation/view/task_details.page.dart';
import '../../features/developer/presentation/view/developer_dashboard.dart';
import '../../features/developer/presentation/view/submit_task_page.dart';

GoRouter createRouter(WidgetRef ref) {
  return GoRouter(
    initialLocation: '/login',

    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final loggingIn = state.uri.toString() == '/login';

      if (authState.status == AuthStatus.unauthenticated) {
        // if the user is not logged in, send them to login unless already there
        return loggingIn ? null : '/login';
      }

      // logged in – prevent navigating back to login
      if (loggingIn) {
        // send to role-based home
        if (authState.role == "admin") return '/admin';
        if (authState.role == "buyer") return '/buyer';
        if (authState.role == "developer") return '/developer';
      }

      // no redirect; allow staying on current path
      return null;
    },

    routes: [
      // LOGIN
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),

      // ADMIN
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminDashboard(),
      ),

      // BUYER MAIN DASHBOARD
      GoRoute(
        path: '/buyer',
        builder: (context, state) => const BuyerDashboard(),
      ),

      // CREATE PROJECT
      GoRoute(
        path: '/buyer/create-project',
        builder: (context, state) => const CreateProjectPage(),
      ),

      // PROJECT TASK LIST
      GoRoute(
        path: '/buyer/:projectId/tasks',
        builder: (context, state) {
          final projectId = state.pathParameters['projectId']!;
          return ProjectTasksPage(projectId: projectId);
        },
      ),

      // CREATE TASK
      GoRoute(
        path: '/buyer/:projectId/create-task',
        builder: (context, state) {
          final projectId = state.pathParameters['projectId']!;
          return CreateTaskPage(projectId: projectId);
        },
      ),

      // TASK DETAILS
      GoRoute(
        path: '/buyer/:projectId/task/:taskId',
        builder: (context, state) {
          final projectId = state.pathParameters['projectId']!;
          final taskId = state.pathParameters['taskId']!;
          return TaskDetailsPage(projectId: projectId, taskId: taskId);
        },
      ),

      // DEVELOPER DASHBOARD
      GoRoute(
        path: '/developer',
        builder: (context, state) => const DeveloperDashboard(),
      ),

      // SUBMIT TASK
      GoRoute(
        path: '/developer/task/:taskId/submit',
        builder: (context, state) {
          final taskId = state.pathParameters['taskId']!;
          return SubmitTaskPage(taskId: taskId);
        },
      ),
    ],
  );
}
