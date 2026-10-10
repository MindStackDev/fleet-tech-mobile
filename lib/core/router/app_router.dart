import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/vehicle/presentation/vehicle_detail_screen.dart';
import '../../features/intervention/presentation/intervention_wizard_screen.dart';
import '../../features/yard/presentation/shift_handover_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/vehicle',
        name: 'vehicle',
        builder: (context, state) => const VehicleDetailScreen(),
      ),
      GoRoute(
        path: '/intervention',
        name: 'intervention',
        builder: (context, state) => const InterventionWizardScreen(),
      ),
      GoRoute(
        path: '/yard/handover',
        name: 'yard_handover',
        builder: (context, state) => const ShiftHandoverScreen(),
      ),
    ],
  );
});
