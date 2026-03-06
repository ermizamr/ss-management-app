import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../auth/data/auth_providers.dart';
import '../../../core/dates/ethiopian_date_formatter.dart';
import '../../../core/promotions/promotion_criteria_set.dart';

class StudentShell extends StatelessWidget {
  const StudentShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _onTap(BuildContext context, int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => _onTap(context, index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF0284C7), // sky-600
        unselectedItemColor: const Color(0xFF64748B), // slate-500
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_rounded),
            label: 'Attendance',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_stories_rounded),
            label: 'Grades',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.forum_rounded),
            label: 'Communication',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class StudentLoginScreen extends ConsumerStatefulWidget {
  const StudentLoginScreen({super.key});

  @override
  ConsumerState<StudentLoginScreen> createState() => _StudentLoginScreenState();
}

class _StudentLoginScreenState extends ConsumerState<StudentLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      final authRepository = ref.read(authRepositoryProvider);
      await authRepository.signInWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (mounted) {
        context.go('/student/dashboard');
      }
    } on AuthException catch (e) {
      setState(() {
        _error = e.message;
      });
    } catch (e) {
      setState(() {
        _error = 'Login failed. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE0F2FE), // sky-50
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Back button
                    TextButton.icon(
                      onPressed: () => context.go('/'),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF475569), // slate-600
                        padding: EdgeInsets.zero,
                        alignment: Alignment.centerLeft,
                      ),
                      icon: const Icon(Icons.arrow_back_rounded, size: 20),
                      label: const Text(
                        'Back to role selection',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Card
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x14374151),
                            blurRadius: 16,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 28,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Header avatar + title
                          Column(
                            children: [
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE0F2FE),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: const Icon(
                                  Icons.person_rounded,
                                  color: Color(0xFF0284C7),
                                  size: 32,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Student Login',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Enter your credentials to continue',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF64748B),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Form
                          Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const Text(
                                  'Email',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                _IconTextField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  hintText: 'Enter your email',
                                  icon: Icons.person_rounded,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Please enter your email';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Password',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                _IconTextField(
                                  controller: _passwordController,
                                  obscureText: true,
                                  hintText: 'Enter your password',
                                  icon: Icons.lock_rounded,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your password';
                                    }
                                    if (value.length < 6) {
                                      return 'Password must be at least 6 characters';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                if (_error != null) ...[
                                  Text(
                                    _error!,
                                    style: TextStyle(
                                      color: colorScheme.error,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                ],
                                SizedBox(
                                  height: 48,
                                  child: FilledButton.icon(
                                    onPressed: _submitting ? null : _submit,
                                    style: FilledButton.styleFrom(
                                      backgroundColor: const Color(0xFF0EA5E9),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    icon: _submitting
                                        ? const SizedBox(
                                            height: 18,
                                            width: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    Colors.white,
                                                  ),
                                            ),
                                          )
                                        : const SizedBox.shrink(),
                                    label: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Text('Login'),
                                        if (!_submitting) ...[
                                          const SizedBox(width: 8),
                                          const Icon(
                                            Icons.arrow_forward_rounded,
                                            size: 20,
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),
                          Align(
                            alignment: Alignment.center,
                            child: TextButton(
                              onPressed: () {
                                // TODO: hook up password reset flow
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: const Color(0xFF0EA5E9),
                              ),
                              child: const Text(
                                'Forgot your password?',
                                style: TextStyle(fontSize: 13),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),
                    const Align(
                      alignment: Alignment.center,
                      child: Text(
                        'Demo mode: use any valid email & password\nwhile backend is being wired fully.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _IconTextField extends StatelessWidget {
  const _IconTextField({
    required this.controller,
    required this.hintText,
    required this.icon,
    this.keyboardType,
    this.obscureText = false,
    this.validator,
  });

  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 14,
        ),
        prefixIcon: Icon(icon, size: 20, color: const Color(0xFF9CA3AF)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xFFCBD5E1), // slate-300
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xFF0EA5E9), // sky-500
            width: 2,
          ),
        ),
      ),
    );
  }
}

class StudentDashboardScreen extends StatelessWidget {
  const StudentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final displayName =
        (user?.userMetadata?['name'] as String?) ?? user?.email ?? 'Student';

    const attendancePercent = 85;
    const academicAvg = 86;
    const pendingQuestions = 1;
    const openComplaints = 1;
    final pendingTotal = pendingQuestions + openComplaints;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Color(0xFF0284C7), // sky-600
                      Color(0xFF0EA5E9), // sky-500
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Welcome back,',
                      style: TextStyle(
                        fontSize: 22,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      displayName,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Color(0xFFBAE6FD), // sky-200
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Transform.translate(
                offset: const Offset(0, -16),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _DashboardStatCard(
                              iconBackground: const Color(0xFFE0F2FE),
                              iconColor: const Color(0xFF0284C7),
                              icon: Icons.calendar_month_rounded,
                              value: '$attendancePercent%',
                              label: 'Attendance',
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _DashboardStatCard(
                              iconBackground: const Color(0xFFFEF3C7),
                              iconColor: const Color(0xFFD97706),
                              icon: Icons.emoji_events_rounded,
                              value: '$academicAvg%',
                              label: 'Academic Avg',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Communication overview
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x0F000000),
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(color: Color(0xFFF1F5F9)),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.notifications_rounded,
                                    size: 20,
                                    color: Color(0xFF475569),
                                  ),
                                  const SizedBox(width: 8),
                                  const Expanded(
                                    child: Text(
                                      'Communication',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF0F172A),
                                      ),
                                    ),
                                  ),
                                  if (pendingTotal > 0)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF0EA5E9),
                                        borderRadius: BorderRadius.circular(
                                          999,
                                        ),
                                      ),
                                      child: Text(
                                        '$pendingTotal pending',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  _KeyValueRow(
                                    label: 'Pending Questions',
                                    value: '$pendingQuestions',
                                  ),
                                  const SizedBox(height: 10),
                                  _KeyValueRow(
                                    label: 'Open Complaints',
                                    value: '$openComplaints',
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: const BoxDecoration(
                                color: Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(18),
                                  bottomRight: Radius.circular(18),
                                ),
                              ),
                              child: Center(
                                child: TextButton(
                                  onPressed: () =>
                                      context.go('/student/communication'),
                                  style: TextButton.styleFrom(
                                    foregroundColor: const Color(0xFF0EA5E9),
                                  ),
                                  child: const Text('Go to Communication'),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Quick actions
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x0F000000),
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Quick Actions',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _QuickActionTile(
                                    icon: Icons.trending_up_rounded,
                                    label: 'View Grades',
                                    onTap: () => context.go('/student/grades'),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _QuickActionTile(
                                    icon: Icons.calendar_month_rounded,
                                    label: 'Attendance',
                                    onTap: () =>
                                        context.go('/student/attendance'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StudentAttendanceScreen extends StatefulWidget {
  const StudentAttendanceScreen({super.key});

  @override
  State<StudentAttendanceScreen> createState() =>
      _StudentAttendanceScreenState();
}

class _StudentAttendanceScreenState extends State<StudentAttendanceScreen> {
  String _selectedSubjectId = _attendanceSubjects.first.id;

  int _subjectPercentage(String subjectId) {
    final records = _attendanceRecords
        .where((r) => r.subjectId == subjectId)
        .toList();
    if (records.isEmpty) return 0;
    final attended = records
        .where((r) => r.status != _AttendanceStatus.absent)
        .length;
    return ((attended / records.length) * 100).round();
  }

  int _overallPercentage() {
    if (_attendanceRecords.isEmpty) return 0;
    final attended = _attendanceRecords
        .where((r) => r.status != _AttendanceStatus.absent)
        .length;
    return ((attended / _attendanceRecords.length) * 100).round();
  }

  ({int present, int late, int absent, int total}) _statusStats(
    String subjectId,
  ) {
    final records = _attendanceRecords
        .where((r) => r.subjectId == subjectId)
        .toList();
    final present = records
        .where((r) => r.status == _AttendanceStatus.present)
        .length;
    final late = records
        .where((r) => r.status == _AttendanceStatus.late)
        .length;
    final absent = records
        .where((r) => r.status == _AttendanceStatus.absent)
        .length;
    return (
      present: present,
      late: late,
      absent: absent,
      total: records.length,
    );
  }

  String _formatDate(DateTime date) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final wd = weekdays[(date.weekday - 1).clamp(0, 6)];
    return '$wd, ${EthiopianDateFormatter.formatDateTime(date)}';
  }

  ({String text, Color color, IconData icon}) _performance(int percentage) {
    if (percentage >= 95) {
      return (
        text: 'Excellent attendance!',
        color: const Color(0xFF16A34A),
        icon: Icons.trending_up_rounded,
      );
    }
    if (percentage >= 85) {
      return (
        text: 'Great attendance!',
        color: const Color(0xFF16A34A),
        icon: Icons.trending_up_rounded,
      );
    }
    if (percentage >= 75) {
      return (
        text: 'Good attendance',
        color: const Color(0xFFD97706),
        icon: Icons.info_outline_rounded,
      );
    }
    return (
      text: 'Attendance needs improvement',
      color: const Color(0xFFDC2626),
      icon: Icons.info_outline_rounded,
    );
  }

  @override
  Widget build(BuildContext context) {
    final overall = _overallPercentage();
    final subject = _attendanceSubjects.firstWhere(
      (s) => s.id == _selectedSubjectId,
    );
    final subjectPercentage = _subjectPercentage(_selectedSubjectId);
    final stats = _statusStats(_selectedSubjectId);
    final performance = _performance(subjectPercentage);

    final subjectRecords =
        _attendanceRecords
            .where((r) => r.subjectId == _selectedSubjectId)
            .toList()
          ..sort((a, b) => b.date.compareTo(a.date));

    Color percentageColor(int p) {
      if (p >= 90) return const Color(0xFF16A34A);
      if (p >= 75) return const Color(0xFFD97706);
      return const Color(0xFFDC2626);
    }

    ({Color text, Color bg, Color border, IconData icon}) statusStyle(
      _AttendanceStatus s,
    ) {
      switch (s) {
        case _AttendanceStatus.present:
          return (
            text: const Color(0xFF16A34A),
            bg: const Color(0xFFDCFCE7),
            border: const Color(0xFFBBF7D0),
            icon: Icons.check_circle_rounded,
          );
        case _AttendanceStatus.late:
          return (
            text: const Color(0xFFD97706),
            bg: const Color(0xFFFEF3C7),
            border: const Color(0xFFFDE68A),
            icon: Icons.schedule_rounded,
          );
        case _AttendanceStatus.absent:
          return (
            text: const Color(0xFFDC2626),
            bg: const Color(0xFFFEE2E2),
            border: const Color(0xFFFECACA),
            icon: Icons.cancel_rounded,
          );
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 18),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Color(0xFF0EA5E9), Color(0xFF0284C7)],
                ),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Attendance',
                    style: TextStyle(
                      fontSize: 22,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Track your class participation',
                    style: TextStyle(fontSize: 12, color: Color(0xFFBAE6FD)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Overall stats
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x14374151),
                            blurRadius: 16,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  'Overall Attendance',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.calendar_month_rounded,
                                size: 20,
                                color: Colors.grey.shade400,
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '$overall%',
                                style: TextStyle(
                                  fontSize: 34,
                                  fontWeight: FontWeight.w800,
                                  color: percentageColor(overall),
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Padding(
                                padding: EdgeInsets.only(bottom: 4),
                                child: Text(
                                  'across all subjects',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF94A3B8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Subject tabs
                    SizedBox(
                      height: 72,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _attendanceSubjects.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemBuilder: (context, index) {
                          final s = _attendanceSubjects[index];
                          final selected = s.id == _selectedSubjectId;
                          final p = _subjectPercentage(s.id);
                          return InkWell(
                            onTap: () =>
                                setState(() => _selectedSubjectId = s.id),
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: selected
                                    ? const Color(0xFF0EA5E9)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: selected
                                    ? const [
                                        BoxShadow(
                                          color: Color(0x260EA5E9),
                                          blurRadius: 14,
                                          offset: Offset(0, 8),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    s.name,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: selected
                                          ? Colors.white
                                          : const Color(0xFF334155),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '$p% attendance',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: selected
                                          ? const Color(0xFFBAE6FD)
                                          : const Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Subject stats
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x0F000000),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  subject.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                              ),
                              Text(
                                '$subjectPercentage%',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  color: percentageColor(subjectPercentage),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  performance.icon,
                                  size: 18,
                                  color: performance.color,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  performance.text,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: performance.color,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _MiniStat(
                                  bg: const Color(0xFFDCFCE7),
                                  icon: Icons.check_circle_rounded,
                                  iconColor: const Color(0xFF16A34A),
                                  value: '${stats.present}',
                                  label: 'Present',
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _MiniStat(
                                  bg: const Color(0xFFFEF3C7),
                                  icon: Icons.schedule_rounded,
                                  iconColor: const Color(0xFFD97706),
                                  value: '${stats.late}',
                                  label: 'Late',
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _MiniStat(
                                  bg: const Color(0xFFFEE2E2),
                                  icon: Icons.cancel_rounded,
                                  iconColor: const Color(0xFFDC2626),
                                  value: '${stats.absent}',
                                  label: 'Absent',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // History
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x0F000000),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: Color(0xFFE2E8F0)),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Attendance History',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${stats.total} sessions recorded',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (subjectRecords.isEmpty)
                            Padding(
                              padding: const EdgeInsets.all(32),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.calendar_month_rounded,
                                    size: 52,
                                    color: Colors.grey.shade300,
                                  ),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'No attendance records yet',
                                    style: TextStyle(color: Color(0xFF64748B)),
                                  ),
                                ],
                              ),
                            )
                          else
                            Column(
                              children: subjectRecords.map((r) {
                                final s = statusStyle(r.status);
                                final statusText = switch (r.status) {
                                  _AttendanceStatus.present => 'present',
                                  _AttendanceStatus.late => 'late',
                                  _AttendanceStatus.absent => 'absent',
                                };
                                return Container(
                                  decoration: const BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: Color(0xFFE2E8F0),
                                      ),
                                    ),
                                  ),
                                  child: InkWell(
                                    onTap: () {},
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 14,
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 40,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              color: s.bg,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                color: s.border,
                                              ),
                                            ),
                                            child: Icon(
                                              s.icon,
                                              color: s.text,
                                              size: 22,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  _formatDate(r.date),
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w600,
                                                    color: Color(0xFF0F172A),
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  subject.name,
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                    color: Color(0xFF64748B),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: s.bg,
                                              borderRadius:
                                                  BorderRadius.circular(999),
                                              border: Border.all(
                                                color: s.border,
                                              ),
                                            ),
                                            child: Text(
                                              statusText,
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: s.text,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                        ],
                      ),
                    ),
                    if (subjectPercentage < 85) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFFFDE68A)),
                        ),
                        child: const Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              color: Color(0xFFD97706),
                              size: 20,
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Improve Your Attendance',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF92400E),
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Regular attendance is important for your learning and promotion. Try to attend all classes and arrive on time.',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF92400E),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardStatCard extends StatelessWidget {
  const _DashboardStatCard({
    required this.iconBackground,
    required this.iconColor,
    required this.icon,
    required this.value,
    required this.label,
  });

  final Color iconBackground;
  final Color iconColor;
  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE2E8F0)),
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: const Color(0xFF0EA5E9)),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Color(0xFF334155)),
            ),
          ],
        ),
      ),
    );
  }
}

class _KeyValueRow extends StatelessWidget {
  const _KeyValueRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 13, color: Color(0xFF334155)),
          ),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
        ),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.bg,
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  final Color bg;
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
        ),
      ],
    );
  }
}

enum _AttendanceStatus { present, late, absent }

class _AttendanceSubject {
  const _AttendanceSubject({required this.id, required this.name});
  final String id;
  final String name;
}

class _AttendanceRecord {
  const _AttendanceRecord({
    required this.subjectId,
    required this.date,
    required this.status,
  });

  final String subjectId;
  final DateTime date;
  final _AttendanceStatus status;
}

const _attendanceSubjects = <_AttendanceSubject>[
  _AttendanceSubject(id: 'bible', name: 'Bible Studies'),
  _AttendanceSubject(id: 'history', name: 'Christian History'),
  _AttendanceSubject(id: 'memory', name: 'Memory Verses'),
  _AttendanceSubject(id: 'activities', name: 'Activities'),
];

final _attendanceRecords = <_AttendanceRecord>[
  _AttendanceRecord(
    subjectId: 'bible',
    date: DateTime(2026, 3, 2),
    status: _AttendanceStatus.present,
  ),
  _AttendanceRecord(
    subjectId: 'bible',
    date: DateTime(2026, 2, 23),
    status: _AttendanceStatus.late,
  ),
  _AttendanceRecord(
    subjectId: 'bible',
    date: DateTime(2026, 2, 16),
    status: _AttendanceStatus.absent,
  ),
  _AttendanceRecord(
    subjectId: 'history',
    date: DateTime(2026, 3, 1),
    status: _AttendanceStatus.present,
  ),
  _AttendanceRecord(
    subjectId: 'history',
    date: DateTime(2026, 2, 22),
    status: _AttendanceStatus.present,
  ),
  _AttendanceRecord(
    subjectId: 'memory',
    date: DateTime(2026, 3, 1),
    status: _AttendanceStatus.present,
  ),
  _AttendanceRecord(
    subjectId: 'memory',
    date: DateTime(2026, 2, 22),
    status: _AttendanceStatus.absent,
  ),
  _AttendanceRecord(
    subjectId: 'activities',
    date: DateTime(2026, 3, 2),
    status: _AttendanceStatus.present,
  ),
  _AttendanceRecord(
    subjectId: 'activities',
    date: DateTime(2026, 2, 23),
    status: _AttendanceStatus.present,
  ),
];

class StudentGradesScreen extends StatefulWidget {
  const StudentGradesScreen({super.key});

  @override
  State<StudentGradesScreen> createState() => _StudentGradesScreenState();
}

class _StudentGradesScreenState extends State<StudentGradesScreen> {
  String? _expandedSubjectId;
  PromotionCriteriaSet _criteria = PromotionCriteriaSet.defaults;
  bool _loadingCriteria = false;

  final _academicYear = const _GradesAcademicYear(
    name: '2025-2026',
    status: _AcademicYearStatus.active,
  );

  final _currentStudent = const _GradesStudent(
    id: '1',
    name: 'Sarah Johnson',
    promotionStatus: _PromotionStatus.eligible,
  );

  late final List<_GradesSubject> _subjects = const [
    _GradesSubject(id: '1', name: 'Bible Studies'),
    _GradesSubject(id: '2', name: 'Christian History'),
    _GradesSubject(id: '3', name: 'Memory Verses'),
    _GradesSubject(id: '4', name: 'Activities'),
  ];

  late final List<_GradesEntry> _gradeEntries = [
    _GradesEntry(
      id: 'g1',
      subjectId: '1',
      gradeType: 'Quiz 1',
      maxScore: 20,
      weight: 20,
      date: DateTime(2026, 2, 10),
      scores: const {'1': 18, '2': 15, '3': 19, '4': null},
    ),
    _GradesEntry(
      id: 'g2',
      subjectId: '1',
      gradeType: 'Midterm Exam',
      maxScore: 100,
      weight: 40,
      date: DateTime(2026, 3, 1),
      scores: const {'1': 92, '2': 78, '3': 88, '4': 0},
    ),
    _GradesEntry(
      id: 'g3',
      subjectId: '1',
      gradeType: 'Final Project',
      maxScore: 50,
      weight: 40,
      date: DateTime(2026, 3, 4),
      scores: const {'1': 48, '2': 41, '3': 46, '4': 45},
    ),
    _GradesEntry(
      id: 'g4',
      subjectId: '2',
      gradeType: 'Essay',
      maxScore: 50,
      weight: 50,
      date: DateTime(2026, 2, 18),
      scores: const {'1': 40, '2': 35, '3': 45, '4': 44},
    ),
    _GradesEntry(
      id: 'g5',
      subjectId: '2',
      gradeType: 'Final Exam',
      maxScore: 100,
      weight: 50,
      date: DateTime(2026, 3, 3),
      scores: const {'1': 84, '2': 66, '3': 90, '4': 75},
    ),
    _GradesEntry(
      id: 'g6',
      subjectId: '3',
      gradeType: 'Recitation',
      maxScore: 10,
      date: DateTime(2026, 2, 20),
      scores: const {'1': 8, '2': 6, '3': 9, '4': 7},
    ),
    _GradesEntry(
      id: 'g7',
      subjectId: '3',
      gradeType: 'Test',
      maxScore: 100,
      date: DateTime(2026, 3, 2),
      scores: const {'1': 78, '2': 61, '3': 85, '4': 70},
    ),
    _GradesEntry(
      id: 'g8',
      subjectId: '4',
      gradeType: 'Participation',
      maxScore: 10,
      date: DateTime(2026, 2, 22),
      scores: const {'1': 9, '2': 8, '3': 10, '4': 9},
    ),
    _GradesEntry(
      id: 'g9',
      subjectId: '4',
      gradeType: 'Final Activity',
      maxScore: 100,
      date: DateTime(2026, 3, 4),
      scores: const {'1': 88, '2': 72, '3': 95, '4': 80},
    ),
  ];

  bool get _isYearActive => _academicYear.status == _AcademicYearStatus.active;

  @override
  void initState() {
    super.initState();
    _loadPromotionCriteria();
  }

  Future<void> _loadPromotionCriteria() async {
    if (_loadingCriteria) return;

    setState(() {
      _loadingCriteria = true;
    });

    try {
      final client = Supabase.instance.client;
      final repo = PromotionCriteriaRepository(client);
      final criteria = await repo.fetchForCurrentUserActiveYear();
      if (!mounted) return;
      if (criteria != null) {
        setState(() {
          _criteria = criteria;
        });
      }
    } catch (_) {
      // Keep defaults on any error.
    } finally {
      if (!mounted) return;
      setState(() {
        _loadingCriteria = false;
      });
    }
  }

  Color _gradeColor(int grade) {
    final c = _criteria.classify(grade.toDouble());
    switch (c) {
      case GradeClassification.excellent:
        return const Color(0xFF16A34A); // green-600
      case GradeClassification.veryGood:
      case GradeClassification.good:
        return const Color(0xFF0284C7); // sky-600
      case GradeClassification.enough:
        return const Color(0xFFF59E0B); // amber-600
      case GradeClassification.critical:
        return const Color(0xFFDC2626); // red-600
    }
  }

  Color _gradeBgColor(int grade) {
    final c = _criteria.classify(grade.toDouble());
    switch (c) {
      case GradeClassification.excellent:
        return const Color(0xFFDCFCE7); // green-50
      case GradeClassification.veryGood:
      case GradeClassification.good:
        return const Color(0xFFE0F2FE); // sky-50
      case GradeClassification.enough:
        return const Color(0xFFFEF3C7); // amber-50
      case GradeClassification.critical:
        return const Color(0xFFFEE2E2); // red-50
    }
  }

  Color _barColor(int grade) {
    final c = _criteria.classify(grade.toDouble());
    switch (c) {
      case GradeClassification.excellent:
        return const Color(0xFF22C55E); // green-500
      case GradeClassification.veryGood:
      case GradeClassification.good:
        return const Color(0xFF0EA5E9); // sky-500
      case GradeClassification.enough:
        return const Color(0xFFFBBF24); // amber-500
      case GradeClassification.critical:
        return const Color(0xFFEF4444); // red-500
    }
  }

  List<_GradesEntry> _entriesForSubject(String subjectId) {
    final entries = _gradeEntries
        .where((e) => e.subjectId == subjectId)
        .toList();
    entries.sort((a, b) => b.date.compareTo(a.date));
    return entries;
  }

  int? _calculateSubjectAverage(String studentId, String subjectId) {
    final allEntries = _entriesForSubject(subjectId);
    if (allEntries.isEmpty) return 0;

    final hasAllScores = allEntries.every((entry) {
      final score = entry.scores[studentId];
      return score != null;
    });

    if (!hasAllScores) return null;

    final entries = allEntries.where(
      (entry) => entry.scores[studentId] != null,
    );
    if (entries.isEmpty) return 0;

    final totalWeight = entries.fold<int>(0, (sum, e) => sum + (e.weight ?? 0));
    if (totalWeight > 0) {
      var weightedScore = 0.0;
      for (final entry in entries) {
        final percentage = (entry.scores[studentId]! / entry.maxScore) * 100;
        final normalizedWeight = (entry.weight ?? 0) / totalWeight;
        weightedScore += percentage * normalizedWeight;
      }
      return weightedScore.round();
    }

    var totalPercentage = 0.0;
    for (final entry in entries) {
      totalPercentage += (entry.scores[studentId]! / entry.maxScore) * 100;
    }
    return (totalPercentage / entries.length).round();
  }

  int _calculateOverallAverage(String studentId) {
    if (_subjects.isEmpty) return 0;

    var total = 0;
    var count = 0;
    for (final subject in _subjects) {
      final subjectAvg = _calculateSubjectAverage(studentId, subject.id);
      if (subjectAvg != null) {
        total += subjectAvg;
        count++;
      }
    }
    if (count == 0) return 0;
    return (total / count).round();
  }

  String _formatMonthDay(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}';
  }

  void _toggleSubject(String subjectId) {
    setState(() {
      _expandedSubjectId = _expandedSubjectId == subjectId ? null : subjectId;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isYearActive) {
      return _buildFinalResults(context);
    }
    return _buildActiveYear(context);
  }

  Widget _buildFinalResults(BuildContext context) {
    final avgGrade = _calculateOverallAverage(_currentStudent.id);

    Color promotionGradientStart;
    Color promotionGradientEnd;
    IconData promotionIcon;
    String promotionTitle;
    String promotionMessage;

    switch (_currentStudent.promotionStatus) {
      case _PromotionStatus.eligible:
        promotionGradientStart = const Color(0xFF22C55E); // green-500
        promotionGradientEnd = const Color(0xFF16A34A); // green-600
        promotionIcon = Icons.check_circle_rounded;
        promotionTitle = 'Promoted';
        promotionMessage =
            'Congratulations! You have been promoted to the next grade.';
        break;
      case _PromotionStatus.atRisk:
        promotionGradientStart = const Color(0xFFF59E0B); // amber-500
        promotionGradientEnd = const Color(0xFFEA580C); // amber-600
        promotionIcon = Icons.warning_rounded;
        promotionTitle = 'At Risk';
        promotionMessage =
            'You are at risk of not being promoted. Please consult with your teacher.';
        break;
      case _PromotionStatus.notEligible:
        promotionGradientStart = const Color(0xFFEF4444); // red-500
        promotionGradientEnd = const Color(0xFFDC2626); // red-600
        promotionIcon = Icons.warning_rounded;
        promotionTitle = 'Not Promoted';
        promotionMessage =
            'You have not met the promotion requirements. Please consult with your teacher.';
        break;
    }

    final subjectAverages = _subjects
        .map((s) => _calculateSubjectAverage(_currentStudent.id, s.id) ?? 0)
        .toList();

    final highest = subjectAverages.isEmpty
        ? 0
        : subjectAverages.reduce((a, b) => a > b ? a : b);
    final lowest = subjectAverages.isEmpty
        ? 0
        : subjectAverages.reduce((a, b) => a < b ? a : b);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
              ),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Final Results',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Academic Year ${_academicYear.name}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFFF59E0B), Color(0xFFEA580C)],
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x14000000),
                            blurRadius: 12,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(20),
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.emoji_events_rounded,
                                  color: Colors.white,
                                  size: 26,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Final Grade',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFFFDE68A),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '$avgGrade%',
                                      style: const TextStyle(
                                        fontSize: 30,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Academic Year ${_academicYear.name}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFFFEF3C7), // amber-100
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            promotionGradientStart,
                            promotionGradientEnd,
                          ],
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x14000000),
                            blurRadius: 12,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(20),
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  promotionIcon,
                                  color: Colors.white,
                                  size: 26,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Promotion Status',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Color(0xEFFFFFFF),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      promotionTitle,
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            promotionMessage,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xEFFFFFFF),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x14000000),
                            blurRadius: 12,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: Color(0xFFF1F5F9)),
                              ),
                            ),
                            child: const Text(
                              'Final Subject Grades',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ),
                          ..._subjects.map((subject) {
                            final subjectAverage =
                                _calculateSubjectAverage(
                                  _currentStudent.id,
                                  subject.id,
                                ) ??
                                0;
                            return Container(
                              padding: const EdgeInsets.fromLTRB(
                                16,
                                14,
                                16,
                                14,
                              ),
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(color: Color(0xFFF1F5F9)),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          subject.name,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF0F172A),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _gradeBgColor(subjectAverage),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: Text(
                                          '$subjectAverage%',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: _gradeColor(subjectAverage),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  _PercentBar(
                                    value: subjectAverage,
                                    backgroundColor: const Color(0xFFF1F5F9),
                                    barColor: _barColor(subjectAverage),
                                    height: 8,
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x14000000),
                            blurRadius: 12,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.trending_up_rounded,
                                size: 20,
                                color: Color(0xFF0284C7), // sky-600
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Final Summary',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          _SummaryRow(
                            label: 'Highest Grade',
                            value: '$highest%',
                          ),
                          const SizedBox(height: 8),
                          _SummaryRow(label: 'Lowest Grade', value: '$lowest%'),
                          const SizedBox(height: 12),
                          const Divider(height: 1, color: Color(0xFFF1F5F9)),
                          const SizedBox(height: 12),
                          _SummaryRow(
                            label: 'Overall Average',
                            value: '$avgGrade%',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0F2FE), // sky-50
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFBAE6FD)),
                      ),
                      padding: const EdgeInsets.all(14),
                      child: Text(
                        'The academic year has ended. These are your final grades for ${_academicYear.name}. Enjoy your break and we look forward to seeing you in the next academic year!',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF0C4A6E), // sky-900
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveYear(BuildContext context) {
    final avgGrade = _calculateOverallAverage(_currentStudent.id);

    final highest = _subjects
        .map((s) => _calculateSubjectAverage(_currentStudent.id, s.id) ?? 0)
        .reduce((a, b) => a > b ? a : b);
    final lowest = _subjects
        .map((s) => _calculateSubjectAverage(_currentStudent.id, s.id) ?? 0)
        .reduce((a, b) => a < b ? a : b);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
              ),
              width: double.infinity,
              child: const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Grades',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFFF59E0B), Color(0xFFEA580C)],
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x14000000),
                            blurRadius: 12,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(20),
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.emoji_events_rounded,
                                  color: Colors.white,
                                  size: 26,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Overall Average',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFFFDE68A),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '$avgGrade%',
                                      style: const TextStyle(
                                        fontSize: 30,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Keep up the excellent work!',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFFFEF3C7), // amber-100
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: _subjects.map((subject) {
                        final entries = _entriesForSubject(subject.id);
                        final missingCount = entries
                            .where((e) => e.scores[_currentStudent.id] == null)
                            .length;
                        final subjectAverage =
                            _calculateSubjectAverage(
                              _currentStudent.id,
                              subject.id,
                            ) ??
                            0;
                        final isExpanded = _expandedSubjectId == subject.id;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x14000000),
                                blurRadius: 12,
                                offset: Offset(0, 6),
                              ),
                            ],
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            children: [
                              InkWell(
                                onTap: () => _toggleSubject(subject.id),
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    16,
                                    14,
                                    16,
                                    12,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              subject.name,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFF0F172A),
                                              ),
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 14,
                                                      vertical: 8,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: _gradeBgColor(
                                                    subjectAverage,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: Text(
                                                  '$subjectAverage%',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                    color: _gradeColor(
                                                      subjectAverage,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Icon(
                                                isExpanded
                                                    ? Icons
                                                          .keyboard_arrow_up_rounded
                                                    : Icons
                                                          .keyboard_arrow_down_rounded,
                                                color: const Color(
                                                  0xFF94A3B8,
                                                ), // slate-400
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      _PercentBar(
                                        value: subjectAverage,
                                        backgroundColor: const Color(
                                          0xFFF1F5F9,
                                        ),
                                        barColor: _barColor(subjectAverage),
                                        height: 8,
                                      ),
                                      const SizedBox(height: 10),
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          '${entries.length} ${entries.length == 1 ? 'assessment' : 'assessments'}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Color(
                                              0xFF64748B,
                                            ), // slate-500
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (isExpanded)
                                Container(
                                  decoration: const BoxDecoration(
                                    border: Border(
                                      top: BorderSide(color: Color(0xFFF1F5F9)),
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.fromLTRB(
                                          16,
                                          12,
                                          16,
                                          12,
                                        ),
                                        color: const Color(0xFFF8FAFC),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            const Text(
                                              'Assessment Breakdown',
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                                color: Color(
                                                  0xFF334155,
                                                ), // slate-700
                                              ),
                                            ),
                                            if (missingCount > 0) ...[
                                              const SizedBox(height: 10),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 10,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: const Color(
                                                    0xFFFFFBEB,
                                                  ), // amber-50
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  border: Border.all(
                                                    color: const Color(
                                                      0xFFFDE68A,
                                                    ), // amber-200
                                                  ),
                                                ),
                                                child: Text(
                                                  '⚠️ You are missing $missingCount assessment(s) in this subject. Your grade is calculated based only on completed assessments.',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Color(
                                                      0xFF78350F,
                                                    ), // amber-900
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                      Column(
                                        children: entries.map((entry) {
                                          final score =
                                              entry.scores[_currentStudent.id];
                                          final hasScore = score != null;
                                          final percentage = hasScore
                                              ? ((score / entry.maxScore) * 100)
                                                    .round()
                                              : 0;

                                          return Container(
                                            padding: const EdgeInsets.fromLTRB(
                                              16,
                                              12,
                                              16,
                                              12,
                                            ),
                                            decoration: const BoxDecoration(
                                              border: Border(
                                                top: BorderSide(
                                                  color: Color(0xFFF1F5F9),
                                                ),
                                              ),
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.stretch,
                                              children: [
                                                Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Text(
                                                                entry.gradeType,
                                                                style: const TextStyle(
                                                                  fontSize: 13,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  color: Color(
                                                                    0xFF0F172A,
                                                                  ),
                                                                ),
                                                              ),
                                                              if (entry
                                                                      .weight !=
                                                                  null) ...[
                                                                const SizedBox(
                                                                  width: 8,
                                                                ),
                                                                Container(
                                                                  padding:
                                                                      const EdgeInsets.symmetric(
                                                                        horizontal:
                                                                            10,
                                                                        vertical:
                                                                            4,
                                                                      ),
                                                                  decoration: BoxDecoration(
                                                                    color: const Color(
                                                                      0xFFFEF3C7,
                                                                    ),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                          999,
                                                                        ),
                                                                  ),
                                                                  child: Text(
                                                                    '${entry.weight}%',
                                                                    style: const TextStyle(
                                                                      fontSize:
                                                                          11,
                                                                      color: Color(
                                                                        0xFFB45309,
                                                                      ),
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ],
                                                          ),
                                                          const SizedBox(
                                                            height: 6,
                                                          ),
                                                          Text(
                                                            _formatMonthDay(
                                                              entry.date,
                                                            ),
                                                            style:
                                                                const TextStyle(
                                                                  fontSize: 12,
                                                                  color: Color(
                                                                    0xFF64748B,
                                                                  ),
                                                                ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .end,
                                                      children: [
                                                        Text(
                                                          hasScore
                                                              ? '$percentage%'
                                                              : 'Pending',
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color: hasScore
                                                                ? _gradeColor(
                                                                    percentage,
                                                                  )
                                                                : const Color(
                                                                    0xFF64748B,
                                                                  ),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          height: 2,
                                                        ),
                                                        Text(
                                                          hasScore
                                                              ? '$score/${entry.maxScore} pts'
                                                              : '—',
                                                          style:
                                                              const TextStyle(
                                                                fontSize: 12,
                                                                color: Color(
                                                                  0xFF64748B,
                                                                ),
                                                              ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 10),
                                                _PercentBar(
                                                  value: percentage,
                                                  backgroundColor: const Color(
                                                    0xFFF1F5F9,
                                                  ),
                                                  barColor: hasScore
                                                      ? _barColor(percentage)
                                                      : const Color(0xFFE2E8F0),
                                                  height: 6,
                                                ),
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x14000000),
                            blurRadius: 12,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.trending_up_rounded,
                                size: 20,
                                color: Color(0xFF0284C7),
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Performance Summary',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          _SummaryRow(
                            label: 'Highest Grade',
                            value: '$highest%',
                          ),
                          const SizedBox(height: 8),
                          _SummaryRow(label: 'Lowest Grade', value: '$lowest%'),
                          const SizedBox(height: 12),
                          const Divider(height: 1, color: Color(0xFFF1F5F9)),
                          const SizedBox(height: 12),
                          _SummaryRow(
                            label: 'Total Subjects',
                            value: '${_subjects.length}',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _AcademicYearStatus { active, ended }

class _GradesAcademicYear {
  const _GradesAcademicYear({required this.name, required this.status});

  final String name;
  final _AcademicYearStatus status;
}

enum _PromotionStatus { eligible, atRisk, notEligible }

class _GradesStudent {
  const _GradesStudent({
    required this.id,
    required this.name,
    required this.promotionStatus,
  });

  final String id;
  final String name;
  final _PromotionStatus promotionStatus;
}

class _GradesSubject {
  const _GradesSubject({required this.id, required this.name});

  final String id;
  final String name;
}

class _GradesEntry {
  const _GradesEntry({
    required this.id,
    required this.subjectId,
    required this.gradeType,
    required this.maxScore,
    required this.date,
    required this.scores,
    this.weight,
  });

  final String id;
  final String subjectId;
  final String gradeType;
  final int maxScore;
  final int? weight;
  final DateTime date;
  final Map<String, int?> scores;
}

class _PercentBar extends StatelessWidget {
  const _PercentBar({
    required this.value,
    required this.backgroundColor,
    required this.barColor,
    required this.height,
  });

  final int value;
  final Color backgroundColor;
  final Color barColor;
  final double height;

  @override
  Widget build(BuildContext context) {
    final normalized = (value.clamp(0, 100)) / 100.0;
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Align(
            alignment: Alignment.centerLeft,
            child: Container(
              height: height,
              width: constraints.maxWidth * normalized,
              decoration: BoxDecoration(
                color: barColor,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          );
        },
      ),
    );
  }
}

class StudentCommunicationScreen extends StatefulWidget {
  const StudentCommunicationScreen({super.key});

  @override
  State<StudentCommunicationScreen> createState() =>
      _StudentCommunicationScreenState();
}

enum _CommTab { announcements, questions, complaints, feedback }

class _StudentCommunicationScreenState
    extends State<StudentCommunicationScreen> {
  _CommTab _activeTab = _CommTab.announcements;
  bool _showQuestionForm = false;
  bool _showComplaintForm = false;

  @override
  Widget build(BuildContext context) {
    final unreadAnnouncements = 2;
    final pendingFeedbackForms = 1;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // Sticky header with tabs
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
              ),
              padding: const EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: 0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Communication',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _CommTabButton(
                          label: 'Announcements',
                          icon: Icons.campaign_rounded,
                          selected: _activeTab == _CommTab.announcements,
                          badgeCount: unreadAnnouncements,
                          onTap: () {
                            setState(() {
                              _activeTab = _CommTab.announcements;
                              _showQuestionForm = false;
                              _showComplaintForm = false;
                            });
                          },
                        ),
                        _CommTabButton(
                          label: 'Questions',
                          icon: Icons.question_answer_rounded,
                          selected: _activeTab == _CommTab.questions,
                          onTap: () {
                            setState(() {
                              _activeTab = _CommTab.questions;
                              _showQuestionForm = false;
                              _showComplaintForm = false;
                            });
                          },
                        ),
                        _CommTabButton(
                          label: 'Complaints',
                          icon: Icons.report_problem_rounded,
                          selected: _activeTab == _CommTab.complaints,
                          onTap: () {
                            setState(() {
                              _activeTab = _CommTab.complaints;
                              _showQuestionForm = false;
                              _showComplaintForm = false;
                            });
                          },
                        ),
                        _CommTabButton(
                          label: 'Feedback',
                          icon: Icons.fact_check_rounded,
                          selected: _activeTab == _CommTab.feedback,
                          badgeCount: pendingFeedbackForms,
                          onTap: () {
                            setState(() {
                              _activeTab = _CommTab.feedback;
                              _showQuestionForm = false;
                              _showComplaintForm = false;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                child: Builder(
                  builder: (context) {
                    switch (_activeTab) {
                      case _CommTab.announcements:
                        return const _AnnouncementsSection();
                      case _CommTab.questions:
                        if (_showQuestionForm) {
                          return _QuestionForm(
                            onCancel: () {
                              setState(() => _showQuestionForm = false);
                            },
                          );
                        }
                        return _QuestionsList(
                          onAskQuestion: () {
                            setState(() => _showQuestionForm = true);
                          },
                        );
                      case _CommTab.complaints:
                        if (_showComplaintForm) {
                          return _ComplaintForm(
                            onCancel: () {
                              setState(() => _showComplaintForm = false);
                            },
                          );
                        }
                        return _ComplaintsList(
                          onSubmitComplaint: () {
                            setState(() => _showComplaintForm = true);
                          },
                        );
                      case _CommTab.feedback:
                        return const _FeedbackSection();
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommTabButton extends StatelessWidget {
  const _CommTabButton({
    required this.label,
    required this.icon,
    required this.selected,
    this.badgeCount,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final int? badgeCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? const Color(0xFF0EA5E9)
        : const Color(0xFF64748B); // sky-500 vs slate-500

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: selected ? const Color(0xFF0EA5E9) : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                color: color,
              ),
            ),
            if (badgeCount != null && badgeCount! > 0) ...[
              const SizedBox(width: 6),
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444), // red-500
                  borderRadius: BorderRadius.circular(999),
                ),
                alignment: Alignment.center,
                child: Text(
                  '$badgeCount',
                  style: const TextStyle(fontSize: 10, color: Colors.white),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// --- Communication tab content widgets (static demo data) ---

class _AnnouncementsSection extends StatefulWidget {
  const _AnnouncementsSection();

  @override
  State<_AnnouncementsSection> createState() => _AnnouncementsSectionState();
}

class _AnnouncementsSectionState extends State<_AnnouncementsSection> {
  String? _expandedId;

  bool _isLoading = true;
  String? _error;
  final List<_Announcement> _items = [];

  static String _dateOnly(String value) {
    if (value.length >= 10) return value.substring(0, 10);
    return value;
  }

  static String _todayIso() {
    final now = DateTime.now();
    final mm = now.month.toString().padLeft(2, '0');
    final dd = now.day.toString().padLeft(2, '0');
    return '${now.year}-$mm-$dd';
  }

  @override
  void initState() {
    super.initState();
    _loadAnnouncementsFromBackend();
  }

  Future<void> _loadAnnouncementsFromBackend() async {
    final client = Supabase.instance.client;
    final userId = client.auth.currentUser?.id;
    if (userId == null) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final profile = await client
          .from('profiles')
          .select('grade_id')
          .eq('id', userId)
          .maybeSingle();

      final gradeId = (profile as Map?)?['grade_id']?.toString();

      final activeYear = await client
          .from('academic_years')
          .select('id')
          .eq('status', 'active')
          .maybeSingle();
      final academicYearId = (activeYear as Map?)?['id']?.toString();

      var query = client
          .from('announcements')
          .select(
            'id, title, message, category, priority, created_by, created_at, expires_on, active, grade_id, academic_year_id',
          )
          .eq('active', true);

      if (academicYearId != null && academicYearId.isNotEmpty) {
        query = query.eq('academic_year_id', academicYearId);
      }

      if (gradeId != null && gradeId.isNotEmpty) {
        query = query.or('grade_id.is.null,grade_id.eq.$gradeId');
      }

      final rows = await query.order('created_at', ascending: false);
      final items = rows.map((r) {
        final map = r as Map;
        final createdAt = map['created_at']?.toString() ?? '';
        final createdById = map['created_by']?.toString() ?? '';
        return _Announcement(
          id: map['id'] as String,
          title: (map['title'] as String?) ?? '',
          message: (map['message'] as String?) ?? '',
          createdBy: createdById == userId ? 'You' : 'Servant',
          createdDate: createdAt.isNotEmpty
              ? _dateOnly(createdAt)
              : _todayIso(),
          category: (map['category'] as String?) ?? 'general',
          unread: false,
        );
      }).toList();

      if (!mounted) return;
      setState(() {
        _items
          ..clear()
          ..addAll(items);
        _expandedId = null;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load announcements.';
        _items.clear();
        _expandedId = null;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.only(top: 24),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Column(
        children: [
          const SizedBox(height: 24),
          Icon(
            Icons.error_outline_rounded,
            size: 42,
            color: Colors.red.shade300,
          ),
          const SizedBox(height: 10),
          Text(_error!, style: const TextStyle(color: Color(0xFF64748B))),
        ],
      );
    }

    if (_items.isEmpty) {
      return Column(
        children: [
          const SizedBox(height: 40),
          Icon(Icons.campaign_rounded, size: 48, color: Colors.grey.shade300),
          const SizedBox(height: 8),
          const Text(
            'No announcements',
            style: TextStyle(color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 4),
          const Text(
            'Check back later for updates',
            style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
          ),
        ],
      );
    }

    return Column(
      children: _items.map((item) {
        final expanded = _expandedId == item.id;
        final unread = item.unread;

        Color badgeBg;
        Color badgeText;
        switch (item.category) {
          case 'urgent':
            badgeBg = const Color(0xFFFEE2E2); // red-100
            badgeText = const Color(0xFFB91C1C); // red-700
            break;
          case 'grades':
            badgeBg = const Color(0xFFFEF3C7); // amber-100
            badgeText = const Color(0xFF92400E); // amber-700
            break;
          case 'schedule':
            badgeBg = const Color(0xFFDBEAFE); // blue-100
            badgeText = const Color(0xFF1D4ED8); // blue-700
            break;
          case 'event':
            badgeBg = const Color(0xFFD1FAE5); // green-100
            badgeText = const Color(0xFF047857); // green-700
            break;
          default:
            badgeBg = const Color(0xFFE2E8F0); // slate-200
            badgeText = const Color(0xFF475569);
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: unread
                  ? const Color(0xFFBAE6FD) // sky-200
                  : Colors.transparent,
              width: 2,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0F000000),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: InkWell(
            onTap: () {
              setState(() {
                _expandedId = expanded ? null : item.id;
              });
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 2),
                        child: Text('📢', style: TextStyle(fontSize: 22)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    item.title,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: unread
                                          ? FontWeight.w600
                                          : FontWeight.w500,
                                      color: const Color(0xFF0F172A),
                                    ),
                                  ),
                                ),
                                if (unread)
                                  const Padding(
                                    padding: EdgeInsets.only(left: 6, top: 4),
                                    child: CircleAvatar(
                                      radius: 3,
                                      backgroundColor: Color(0xFF0EA5E9),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: badgeBg,
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(
                                      color: badgeBg.withOpacity(0.8),
                                    ),
                                  ),
                                  child: Text(
                                    item.category,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: badgeText,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  EthiopianDateFormatter.formatFlexible(
                                    item.createdDate,
                                  ),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF94A3B8),
                                  ),
                                ),
                              ],
                            ),
                            if (!expanded) ...[
                              const SizedBox(height: 6),
                              Text(
                                item.message,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (expanded)
                  const Divider(height: 1, color: Color(0xFFE2E8F0)),
                if (expanded)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.message,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Posted by ${item.createdBy}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                            Text(
                              EthiopianDateFormatter.formatFlexible(
                                item.createdDate,
                              ),
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _QuestionsList extends StatelessWidget {
  const _QuestionsList({required this.onAskQuestion});

  final VoidCallback onAskQuestion;

  @override
  Widget build(BuildContext context) {
    final questions = const [
      _Question(
        subject: 'Bible Studies',
        question: 'Will next week’s quiz include last month’s memory verses?',
        status: 'Pending',
        answered: false,
        date: 'Feb 27',
      ),
      _Question(
        subject: 'Christian History',
        question:
            'Can you share additional resources about early church fathers?',
        status: 'Answered',
        answered: true,
        answer:
            'Yes, we will share a reading list and a short video next class.',
        date: 'Feb 20',
      ),
    ];

    final pending = questions.where((q) => !q.answered).toList(growable: false);
    final answered = questions.where((q) => q.answered).toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 44,
          child: ElevatedButton.icon(
            onPressed: onAskQuestion,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0EA5E9),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            icon: const Icon(Icons.add_rounded, size: 20),
            label: const Text('Ask a Question', style: TextStyle(fontSize: 14)),
          ),
        ),
        const SizedBox(height: 16),
        if (pending.isNotEmpty) ...[
          const Text(
            'Pending',
            style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 8),
          ...pending.map((q) => _QuestionCard(question: q)),
          const SizedBox(height: 16),
        ],
        if (answered.isNotEmpty) ...[
          const Text(
            'Answered',
            style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 8),
          ...answered.map((q) => _QuestionCard(question: q)),
        ],
        if (questions.isEmpty) ...[
          const SizedBox(height: 40),
          Icon(
            Icons.chat_bubble_outline_rounded,
            color: Colors.grey.shade300,
            size: 48,
          ),
          const SizedBox(height: 8),
          const Text(
            'No questions yet',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF64748B)),
          ),
        ],
      ],
    );
  }
}

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({required this.question});

  final _Question question;

  @override
  Widget build(BuildContext context) {
    final statusColor = question.answered
        ? const Color(0xFF16A34A)
        : const Color(0xFFFBBF24); // green / amber
    final statusBg = question.answered
        ? const Color(0xFFDCFCE7)
        : const Color(0xFFFEF3C7);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F2FE),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  question.subject,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF0369A1),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  question.status,
                  style: TextStyle(fontSize: 11, color: statusColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            question.question,
            style: const TextStyle(fontSize: 13, color: Color(0xFF111827)),
          ),
          if (question.answer != null) ...[
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFE0F2FE),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Response:',
                    style: TextStyle(fontSize: 11, color: Color(0xFF0369A1)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    question.answer!,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 6),
          Text(
            EthiopianDateFormatter.formatFlexible(question.date),
            style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
          ),
        ],
      ),
    );
  }
}

class _QuestionForm extends StatefulWidget {
  const _QuestionForm({required this.onCancel});

  final VoidCallback onCancel;

  @override
  State<_QuestionForm> createState() => _QuestionFormState();
}

class _QuestionFormState extends State<_QuestionForm> {
  final _formKey = GlobalKey<FormState>();
  String _subject = '';
  String _question = '';
  bool _showSuccess = false;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0F000000),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ask a Question',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Subject',
                  style: TextStyle(fontSize: 13, color: Color(0xFF1F2937)),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  initialValue: _subject.isEmpty ? null : _subject,
                  items: const [
                    DropdownMenuItem(
                      value: 'Bible Studies',
                      child: Text('Bible Studies'),
                    ),
                    DropdownMenuItem(
                      value: 'Christian History',
                      child: Text('Christian History'),
                    ),
                    DropdownMenuItem(value: 'General', child: Text('General')),
                  ],
                  decoration: _dropdownDecoration,
                  onChanged: (value) {
                    setState(() => _subject = value ?? '');
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a subject';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                const Text(
                  'Your Question',
                  style: TextStyle(fontSize: 13, color: Color(0xFF1F2937)),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  maxLines: 4,
                  maxLength: 500,
                  decoration: _textareaDecoration.copyWith(
                    hintText: 'Type your question here...',
                    counterText: '${_question.length}/500',
                    counterStyle: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() => _question = value);
                  },
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your question';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          if (!_formKey.currentState!.validate()) {
                            return;
                          }
                          setState(() {
                            _showSuccess = true;
                          });
                          Future.delayed(
                            const Duration(milliseconds: 1500),
                            () {
                              if (!mounted) return;
                              setState(() {
                                _showSuccess = false;
                              });
                              widget.onCancel();
                            },
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0EA5E9),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        icon: const Icon(Icons.send_rounded, size: 18),
                        label: const Text('Send'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    OutlinedButton(
                      onPressed: widget.onCancel,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (_showSuccess)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF22C55E),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Question submitted!',
                      style: TextStyle(fontSize: 12, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ComplaintsList extends StatelessWidget {
  const _ComplaintsList({required this.onSubmitComplaint});

  final VoidCallback onSubmitComplaint;

  @override
  Widget build(BuildContext context) {
    final complaints = const [
      _Complaint(
        category: 'teacher',
        status: 'pending',
        text: 'The classroom is often too noisy during activities.',
        date: 'Feb 25',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 44,
          child: ElevatedButton.icon(
            onPressed: onSubmitComplaint,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0EA5E9),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            icon: const Icon(Icons.add_rounded, size: 20),
            label: const Text(
              'Submit Complaint',
              style: TextStyle(fontSize: 14),
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (complaints.isEmpty) ...[
          const SizedBox(height: 40),
          Icon(
            Icons.report_problem_outlined,
            color: Colors.grey.shade300,
            size: 48,
          ),
          const SizedBox(height: 8),
          const Text(
            'No complaints submitted',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF64748B)),
          ),
        ] else
          ...complaints.map((c) => _ComplaintCard(complaint: c)),
      ],
    );
  }
}

class _ComplaintCard extends StatelessWidget {
  const _ComplaintCard({required this.complaint});

  final _Complaint complaint;

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    Color statusBg;
    switch (complaint.status) {
      case 'pending':
        statusBg = const Color(0xFFFEF3C7);
        statusColor = const Color(0xFF92400E);
        break;
      case 'resolved':
        statusBg = const Color(0xFFDCFCE7);
        statusColor = const Color(0xFF166534);
        break;
      default:
        statusBg = const Color(0xFFDBEAFE);
        statusColor = const Color(0xFF1D4ED8);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  complaint.category,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF475569),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  complaint.status,
                  style: TextStyle(fontSize: 11, color: statusColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            complaint.text,
            style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 6),
          Text(
            EthiopianDateFormatter.formatFlexible(complaint.date),
            style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
          ),
        ],
      ),
    );
  }
}

class _ComplaintForm extends StatefulWidget {
  const _ComplaintForm({required this.onCancel});

  final VoidCallback onCancel;

  @override
  State<_ComplaintForm> createState() => _ComplaintFormState();
}

class _ComplaintFormState extends State<_ComplaintForm> {
  final _formKey = GlobalKey<FormState>();
  String _category = '';
  String _title = '';
  String _description = '';
  bool _anonymous = false;
  bool _showSuccess = false;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0F000000),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Submit Complaint',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Category',
                  style: TextStyle(fontSize: 13, color: Color(0xFF1F2937)),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  initialValue: _category.isEmpty ? null : _category,
                  items: const [
                    DropdownMenuItem(value: 'teacher', child: Text('Teacher')),
                    DropdownMenuItem(
                      value: 'facility',
                      child: Text('Facility'),
                    ),
                    DropdownMenuItem(value: 'course', child: Text('Course')),
                    DropdownMenuItem(
                      value: 'administrative',
                      child: Text('Administrative'),
                    ),
                    DropdownMenuItem(value: 'other', child: Text('Other')),
                  ],
                  decoration: _dropdownDecoration,
                  onChanged: (value) {
                    setState(() => _category = value ?? '');
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a category';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                const Text(
                  'Title',
                  style: TextStyle(fontSize: 13, color: Color(0xFF1F2937)),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  maxLength: 100,
                  decoration: _inputDecoration.copyWith(
                    hintText: 'Brief title for your complaint',
                    counterText: '${_title.length}/100',
                    counterStyle: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() => _title = value);
                  },
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                const Text(
                  'Description',
                  style: TextStyle(fontSize: 13, color: Color(0xFF1F2937)),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  maxLines: 4,
                  maxLength: 500,
                  decoration: _textareaDecoration.copyWith(
                    hintText: 'Describe your complaint in detail...',
                    counterText: '${_description.length}/500',
                    counterStyle: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() => _description = value);
                  },
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Checkbox(
                      value: _anonymous,
                      onChanged: (value) {
                        setState(() => _anonymous = value ?? false);
                      },
                    ),
                    const SizedBox(width: 4),
                    const Expanded(
                      child: Text(
                        'Submit anonymously',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF334155),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          if (!_formKey.currentState!.validate()) return;
                          setState(() => _showSuccess = true);
                          Future.delayed(
                            const Duration(milliseconds: 1500),
                            () {
                              if (!mounted) return;
                              setState(() => _showSuccess = false);
                              widget.onCancel();
                            },
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0EA5E9),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        icon: const Icon(Icons.send_rounded, size: 18),
                        label: const Text('Submit'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    OutlinedButton(
                      onPressed: widget.onCancel,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (_showSuccess)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF22C55E),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Complaint submitted!',
                      style: TextStyle(fontSize: 12, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _FeedbackSection extends StatelessWidget {
  const _FeedbackSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0F000000),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.fact_check_rounded,
                    size: 20,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'No active feedback forms',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Your servant may share feedback forms in the future. Check back later.',
                style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// --- Shared helpers and data classes ---

const _inputDecoration = InputDecoration(
  isDense: true,
  contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(12)),
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(12)),
    borderSide: BorderSide(color: Color(0xFFCBD5E1)),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(12)),
    borderSide: BorderSide(color: Color(0xFF0EA5E9), width: 2),
  ),
);

final _textareaDecoration = _inputDecoration.copyWith(alignLabelWithHint: true);

const _dropdownDecoration = _inputDecoration;

class _SubjectGrade {
  const _SubjectGrade({required this.name, required this.average});

  final String name;
  final int average;
}

class _SubjectGradeTile extends StatelessWidget {
  const _SubjectGradeTile({
    required this.subject,
    required this.gradeColor,
    required this.gradeBg,
    required this.barColor,
  });

  final _SubjectGrade subject;
  final Color Function(int) gradeColor;
  final Color Function(int) gradeBg;
  final Color Function(int) barColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                subject.name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F172A),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: gradeBg(subject.average),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${subject.average}%',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: gradeColor(subject.average),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 6,
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                height: 6,
                width: subject.average.toDouble().clamp(0, 100),
                decoration: BoxDecoration(
                  color: barColor(subject.average),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
        ),
      ],
    );
  }
}

class _Announcement {
  const _Announcement({
    required this.id,
    required this.title,
    required this.message,
    required this.createdBy,
    required this.createdDate,
    required this.category,
    required this.unread,
  });

  final String id;
  final String title;
  final String message;
  final String createdBy;
  final String createdDate;
  final String category;
  final bool unread;
}

class _Question {
  const _Question({
    required this.subject,
    required this.question,
    required this.status,
    required this.answered,
    required this.date,
    this.answer,
  });

  final String subject;
  final String question;
  final String status;
  final bool answered;
  final String date;
  final String? answer;
}

class _Complaint {
  const _Complaint({
    required this.category,
    required this.status,
    required this.text,
    required this.date,
  });

  final String category;
  final String status;
  final String text;
  final String date;
}

class StudentProfileScreen extends StatelessWidget {
  const StudentProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Student Profile')));
  }
}
