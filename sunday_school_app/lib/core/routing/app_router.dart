import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/role_selection_screen.dart';
import '../../features/student/presentation/student_screens.dart';
import '../../features/servant/presentation/servant_screens.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'role-selection',
      builder: (context, state) => const RoleSelectionScreen(),
    ),
    GoRoute(
      path: '/student/login',
      name: 'student-login',
      builder: (context, state) => const StudentLoginScreen(),
    ),
    GoRoute(
      path: '/student/dashboard',
      name: 'student-dashboard',
      builder: (context, state) => const StudentDashboardScreen(),
    ),
    GoRoute(
      path: '/student/attendance',
      name: 'student-attendance',
      builder: (context, state) => const StudentAttendanceScreen(),
    ),
    GoRoute(
      path: '/student/grades',
      name: 'student-grades',
      builder: (context, state) => const StudentGradesScreen(),
    ),
    GoRoute(
      path: '/student/communication',
      name: 'student-communication',
      builder: (context, state) => const StudentCommunicationScreen(),
    ),
    GoRoute(
      path: '/student/profile',
      name: 'student-profile',
      builder: (context, state) => const StudentProfileScreen(),
    ),
    GoRoute(
      path: '/servant/login',
      name: 'servant-login',
      builder: (context, state) => const ServantLoginScreen(),
    ),
    GoRoute(
      path: '/servant/dashboard',
      name: 'servant-dashboard',
      builder: (context, state) => const ServantDashboardScreen(),
    ),
    GoRoute(
      path: '/servant/attendance',
      name: 'servant-attendance',
      builder: (context, state) => const ServantAttendanceScreen(),
    ),
    GoRoute(
      path: '/servant/grades',
      name: 'servant-grades',
      builder: (context, state) => const ServantGradesScreen(),
    ),
    GoRoute(
      path: '/servant/communication',
      name: 'servant-communication',
      builder: (context, state) => const ServantCommunicationScreen(),
    ),
    GoRoute(
      path: '/servant/profile',
      name: 'servant-profile',
      builder: (context, state) => const ServantProfileScreen(),
    ),
    GoRoute(
      path: '/servant/analytics',
      name: 'servant-analytics',
      builder: (context, state) => const ServantAnalyticsScreen(),
    ),
  ],
);

