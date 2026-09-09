import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:durgapuja_manager/features/approval/presentation/screens/approval_dashboard_screen.dart';
import 'package:durgapuja_manager/features/chanda/presentation/screens/chanda_dashboard_screen.dart';
import 'package:durgapuja_manager/features/custody/presentation/screens/custody_dashboard_screen.dart';
import 'package:durgapuja_manager/features/home/presentation/screens/main_navigation_shell.dart';
import 'package:durgapuja_manager/features/puja_event/presentation/screens/puja_event_list_screen.dart';
import 'package:durgapuja_manager/features/reports/presentation/screens/reports_hub_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const MainNavigationShell(),
      ),
      GoRoute(
        path: '/events',
        builder: (context, state) => const PujaEventListScreen(),
      ),
      GoRoute(
        path: '/approvals',
        builder: (context, state) => const ApprovalDashboardScreen(),
      ),
      GoRoute(
        path: '/reports',
        builder: (context, state) => const ReportsHubScreen(),
      ),
      GoRoute(
        path: '/chanda',
        builder: (context, state) => const ChandaDashboardScreen(),
      ),
      GoRoute(
        path: '/custody',
        builder: (context, state) => const CustodyDashboardScreen(),
      ),
    ],
  );
});
