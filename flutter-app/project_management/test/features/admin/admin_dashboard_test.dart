import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:project_management/features/admin/data/admin_repository.dart';
import 'package:project_management/features/admin/domain/admin_stats_model.dart';
import 'package:project_management/features/admin/presentation/provider/admin_provider.dart';
import 'package:project_management/features/admin/presentation/view/admin_dashboard_page.dart';

void main() {
  group('AdminDashboard', () {
    testWidgets('renders stat cards when data is loaded', (tester) async {
      final stats = AdminStats(
        totalProjects: 7,
        totalTasks: 12,
        completedTasks: 9,
        totalPayments: 4,
        pendingPayments: 2,
        totalDeveloperHours: 120,
        revenueGenerated: 5432.10,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            adminProvider.overrideWith(
              (ref) => _StubAdminNotifier(AsyncData(stats)),
            ),
          ],
          child: const MaterialApp(home: AdminDashboard()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Total Projects'), findsOneWidget);
      expect(find.text('7'), findsOneWidget);
      expect(find.text('Total Tasks'), findsOneWidget);
      expect(find.text('12'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Revenue Generated'),
        400,
      );
      expect(find.text('Revenue Generated'), findsOneWidget);
      expect(find.text(r'$5432.10'), findsOneWidget);
    });

    testWidgets('renders error view when provider errors', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            adminProvider.overrideWith(
              (ref) =>
                  _StubAdminNotifier(AsyncError('failed', StackTrace.empty)),
            ),
          ],
          child: const MaterialApp(home: AdminDashboard()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Error loading stats'), findsOneWidget);
    });
  });
}

class _StubAdminNotifier extends AdminNotifier {
  _StubAdminNotifier(this._initialState) : super(_NoopAdminRepository());

  final AsyncValue<AdminStats> _initialState;

  @override
  Future<void> loadStats() async {
    state = _initialState;
  }
}

class _NoopAdminRepository extends AdminRepository {
  _NoopAdminRepository() : super(Dio());

  @override
  Future<AdminStats> fetchStats() {
    throw UnimplementedError();
  }
}
