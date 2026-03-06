import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../auth/data/auth_providers.dart';
import '../../../core/supabase/supabase_client.dart';
import '../../../core/refresh/app_refresh_scope.dart';
import '../../../core/dates/ethiopian_date_formatter.dart';
import '../../../core/promotions/promotion_criteria_set.dart';

class ServantShell extends StatelessWidget {
  const ServantShell({super.key, required this.navigationShell});

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
        selectedItemColor: const Color(0xFFD97706), // amber-600
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

class ServantLoginScreen extends ConsumerStatefulWidget {
  const ServantLoginScreen({super.key});

  @override
  ConsumerState<ServantLoginScreen> createState() => _ServantLoginScreenState();
}

class _ServantLoginScreenState extends ConsumerState<ServantLoginScreen> {
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
        context.go('/servant/dashboard');
      }
    } on AuthException catch (e) {
      setState(() {
        _error = e.message;
      });
    } catch (_) {
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
            colors: [Color(0xFFFEF3C7), Colors.white],
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
                    TextButton.icon(
                      onPressed: () => context.go('/'),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF475569),
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
                          Column(
                            children: [
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEF3C7),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: const Icon(
                                  Icons.groups_rounded,
                                  color: Color(0xFFD97706),
                                  size: 32,
                                ),
                              ),
                              const SizedBox(height: 14),
                              const Text(
                                'Servant Login',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Sign in to manage your class',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const Text(
                                  'Email',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                _IconTextField(
                                  controller: _emailController,
                                  hintText: 'Enter your email',
                                  icon: Icons.mail_rounded,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Please enter your email';
                                    }
                                    if (!value.contains('@')) {
                                      return 'Please enter a valid email';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 14),
                                const Text(
                                  'Password',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
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
                                      backgroundColor: const Color(0xFFF59E0B),
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
                              onPressed: () {},
                              style: TextButton.styleFrom(
                                foregroundColor: const Color(0xFFF59E0B),
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
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
          borderSide: BorderSide(color: Color(0xFFCBD5E1)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
          borderSide: BorderSide(color: Color(0xFFF59E0B), width: 2),
        ),
      ),
    );
  }
}

class ServantDashboardScreen extends StatelessWidget {
  const ServantDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Static demo data approximating the React mock data
    const classSize = 24;
    const avgAttendance = 85;
    const pendingQuestions = 3;
    const pendingComplaints = 2;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // slate-50
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Color(0xFFF59E0B), // amber-500
                    Color(0xFFD97706), // amber-600
                  ],
                ),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Servant Dashboard',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Class Management',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFFFDE68A), // amber-200
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Class summary card
                    Transform.translate(
                      offset: const Offset(0, -20),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x14374151),
                              blurRadius: 14,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFEF3C7),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const Icon(
                                    Icons.group,
                                    color: Color(0xFFD97706),
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Total Students',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF64748B),
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      '$classSize',
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF0F172A),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF8FAFC),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Avg Attendance',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Color(0xFF6B7280),
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          '$avgAttendance%',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF0F172A),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF8FAFC),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Pending Items',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Color(0xFF6B7280),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${pendingQuestions + pendingComplaints}',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF0F172A),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 4),

                    // Quick actions
                    const Text(
                      'Quick Actions',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Column(
                      children: [
                        _ServantQuickActionButton(
                          background: const Color(0xFF0EA5E9),
                          foreground: Colors.white,
                          iconBackground: Colors.white24,
                          icon: Icons.fact_check_rounded,
                          title: 'Mark Attendance',
                          subtitle: 'Record today\'s attendance',
                          onTap: () =>
                              GoRouter.of(context).go('/servant/attendance'),
                        ),
                        const SizedBox(height: 10),
                        _ServantQuickActionButton(
                          background: Colors.white,
                          foreground: const Color(0xFF0F172A),
                          iconBackground: const Color(0xFFFEF3C7),
                          icon: Icons.menu_book_rounded,
                          title: 'Add Grades',
                          subtitle: 'Enter or update student grades',
                          borderColor: const Color(0xFFE2E8F0),
                          onTap: () =>
                              GoRouter.of(context).go('/servant/grades'),
                        ),
                        const SizedBox(height: 10),
                        _ServantQuickActionButton(
                          background: const Color(0xFF0EA5E9),
                          foreground: Colors.white,
                          iconBackground: Colors.white24,
                          icon: Icons.insights_rounded,
                          title: 'Grade Analytics',
                          subtitle: 'Performance insights & trends',
                          gradient: const LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [Color(0xFF0EA5E9), Color(0xFF0369A1)],
                          ),
                          onTap: () =>
                              GoRouter.of(context).go('/servant/analytics'),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Today schedule
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.fromLTRB(16, 12, 16, 10),
                            child: Text(
                              'Today\'s Schedule',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ),
                          const Divider(height: 1, color: Color(0xFFE2E8F0)),
                          _ScheduleRow(
                            iconBg: const Color(0xFFE0F2FE),
                            iconColor: const Color(0xFF0284C7),
                            title: 'Sunday School Class',
                            time: '9:00 AM - 10:30 AM',
                          ),
                          const Divider(height: 1, color: Color(0xFFE2E8F0)),
                          _ScheduleRow(
                            iconBg: const Color(0xFFFEF3C7),
                            iconColor: const Color(0xFFD97706),
                            title: 'Bible Study Review',
                            time: '10:30 AM - 11:00 AM',
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Pending communication alert
                    if (pendingQuestions > 0 || pendingComplaints > 0)
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFBEB), // amber-50
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFFFDE68A), // amber-200
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.chat_bubble_rounded,
                              color: Color(0xFFD97706),
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'You have $pendingQuestions question${pendingQuestions == 1 ? '' : 's'} '
                                    'and $pendingComplaints complaint${pendingComplaints == 1 ? '' : 's'} pending',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF92400E),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            TextButton(
                              onPressed: () => GoRouter.of(
                                context,
                              ).go('/servant/communication'),
                              style: TextButton.styleFrom(
                                foregroundColor: const Color(0xFF92400E),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                              ),
                              child: const Text(
                                'View',
                                style: TextStyle(fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}

class _ServantQuickActionButton extends StatelessWidget {
  const _ServantQuickActionButton({
    required this.background,
    required this.foreground,
    required this.iconBackground,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.borderColor,
    this.gradient,
  });

  final Color background;
  final Color foreground;
  final Color iconBackground;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? borderColor;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          color: gradient == null ? background : null,
          gradient: gradient,
          borderRadius: BorderRadius.circular(18),
          border: borderColor != null
              ? Border.all(color: borderColor!, width: 1.5)
              : null,
          boxShadow: const [
            BoxShadow(
              color: Color(0x14374151),
              blurRadius: 12,
              offset: Offset(0, 5),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: iconBackground,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: foreground, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: foreground,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: foreground.withOpacity(0.85),
                    ),
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

class _ScheduleRow extends StatelessWidget {
  const _ScheduleRow({
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.time,
  });

  final Color iconBg;
  final Color iconColor;
  final String title;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.calendar_today_rounded,
              color: iconColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                time,
                style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ServantAttendanceScreen extends StatelessWidget {
  const ServantAttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Servant Attendance')));
  }
}

class ServantGradesScreen extends StatefulWidget {
  const ServantGradesScreen({super.key});

  @override
  State<ServantGradesScreen> createState() => _ServantGradesScreenState();
}

enum _ServantGradesView { list, add, edit, addSubject, missing }

class _ServantGradesSubject {
  const _ServantGradesSubject({required this.id, required this.name});
  final String id;
  final String name;
}

class _ServantGradesStudent {
  const _ServantGradesStudent({required this.id, required this.name});
  final String id;
  final String name;
}

class _ServantGradeEntry {
  const _ServantGradeEntry({
    required this.id,
    required this.subjectId,
    required this.gradeType,
    required this.maxScore,
    required this.date,
    this.weight,
    required this.scores,
  });

  final String id;
  final String subjectId;
  final String gradeType;
  final int maxScore;
  final int? weight;
  final DateTime date;
  final Map<String, double?> scores;
}

class _ServantGradesScreenState extends State<ServantGradesScreen> {
  _ServantGradesView _view = _ServantGradesView.list;
  _ServantGradeEntry? _selectedEntry;

  String? _academicYearId;
  String? _academicYearName;
  String? _academicYearStatus;

  bool _loadingLockState = true;
  bool _isLocked = false;
  String? _lockMessage;

  PromotionCriteriaSet _criteria = PromotionCriteriaSet.defaults;
  bool _loadingCriteria = false;

  // List view state
  bool _showWeightedGrades = false;
  String _weightedSearch = '';
  String? _viewingScoresEntryId;
  final Map<String, String> _entryScoreSearch = {};

  // Form state
  final _assessmentNameController = TextEditingController();
  final _maxScoreController = TextEditingController();
  final _weightController = TextEditingController();
  DateTime? _assessmentDate;
  final Map<String, TextEditingController> _studentScoreControllers = {};
  String _studentScoresSearch = '';
  int _studentScoresPage = 0;

  final _subjectNameController = TextEditingController();

  late final List<_ServantGradesStudent> _students = const [
    _ServantGradesStudent(id: '1', name: 'Sarah Johnson'),
    _ServantGradesStudent(id: '2', name: 'Michael Chen'),
    _ServantGradesStudent(id: '3', name: 'Daniel Okoro'),
    _ServantGradesStudent(id: '4', name: 'Ava Martinez'),
    _ServantGradesStudent(id: '5', name: 'Samuel Lee'),
    _ServantGradesStudent(id: '6', name: 'Grace Nwosu'),
    _ServantGradesStudent(id: '7', name: 'Noah Smith'),
    _ServantGradesStudent(id: '8', name: 'Mia Patel'),
  ];

  late final List<_ServantGradesSubject> _subjects = [
    const _ServantGradesSubject(id: '1', name: 'Bible Studies'),
    const _ServantGradesSubject(id: '2', name: 'Christian History'),
    const _ServantGradesSubject(id: '3', name: 'Memory Verses'),
    const _ServantGradesSubject(id: '4', name: 'Activities'),
  ];

  late _ServantGradesSubject _selectedSubject = _subjects.first;

  late final List<_ServantGradeEntry> _gradeEntries = [
    _ServantGradeEntry(
      id: 'g1',
      subjectId: '1',
      gradeType: 'Quiz 1',
      maxScore: 20,
      weight: 20,
      date: DateTime(2026, 2, 10),
      scores: const {
        '1': 18,
        '2': 15,
        '3': 19,
        '4': null,
        '5': 16,
        '6': 17,
        '7': 20,
        '8': 14,
      },
    ),
    _ServantGradeEntry(
      id: 'g2',
      subjectId: '1',
      gradeType: 'Midterm Exam',
      maxScore: 100,
      weight: 40,
      date: DateTime(2026, 3, 1),
      scores: const {
        '1': 92,
        '2': 78,
        '3': 88,
        '4': 0,
        '5': 81,
        '6': 90,
        '7': 96,
        '8': null,
      },
    ),
    _ServantGradeEntry(
      id: 'g3',
      subjectId: '1',
      gradeType: 'Final Project',
      maxScore: 50,
      weight: 40,
      date: DateTime(2026, 3, 4),
      scores: const {
        '1': 48,
        '2': 41,
        '3': 46,
        '4': 45,
        '5': 44,
        '6': 47,
        '7': 49,
        '8': 40,
      },
    ),
    _ServantGradeEntry(
      id: 'g4',
      subjectId: '2',
      gradeType: 'Essay',
      maxScore: 50,
      weight: 50,
      date: DateTime(2026, 2, 18),
      scores: const {
        '1': 40,
        '2': 35,
        '3': 45,
        '4': 44,
        '5': 39,
        '6': 47,
        '7': 49,
        '8': null,
      },
    ),
    _ServantGradeEntry(
      id: 'g5',
      subjectId: '2',
      gradeType: 'Final Exam',
      maxScore: 100,
      weight: 50,
      date: DateTime(2026, 3, 3),
      scores: const {
        '1': 84,
        '2': 66,
        '3': 90,
        '4': 75,
        '5': 72,
        '6': 95,
        '7': 98,
        '8': 64,
      },
    ),
  ];

  static const int _scoresPageSize = 30;

  @override
  void initState() {
    super.initState();
    _loadLockState();
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

  @override
  void dispose() {
    _assessmentNameController.dispose();
    _maxScoreController.dispose();
    _weightController.dispose();
    _subjectNameController.dispose();
    for (final c in _studentScoreControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _loadLockState() async {
    setState(() {
      _loadingLockState = true;
      _lockMessage = null;
    });

    final supabase = SupabaseClientManager.instance.client;

    try {
      // Academic year (prefer active; fallback to any latest row if active not found).
      final activeYear = await supabase
          .from('academic_years')
          .select('id,name,status')
          .eq('status', 'active')
          .maybeSingle();

      Map<String, dynamic>? year = activeYear;
      year ??= await supabase
          .from('academic_years')
          .select('id,name,status')
          .order('start_date', ascending: false)
          .limit(1)
          .maybeSingle();

      _academicYearId = year?['id'] as String?;
      _academicYearName = year?['name'] as String?;
      _academicYearStatus = year?['status'] as String?;

      final isYearActive = _academicYearStatus == 'active';

      // Global feature flag (optional table; default enabled).
      var globalEnabled = true;
      try {
        final flag = await supabase
            .from('app_feature_flags')
            .select('enabled')
            .eq('key', 'grades.editing.enabled')
            .maybeSingle();
        if (flag != null && flag['enabled'] != null) {
          globalEnabled = flag['enabled'] as bool;
        }
      } catch (_) {
        // Ignore if the feature flag table is not yet deployed.
      }

      // Per-year override (auto/locked/unlocked). Optional table; default auto.
      var yearMode = 'auto';
      try {
        final yearId = _academicYearId;
        if (yearId != null) {
          final policy = await supabase
              .from('academic_year_policies')
              .select('grades_edit_mode')
              .eq('academic_year_id', yearId)
              .maybeSingle();
          if (policy != null && policy['grades_edit_mode'] != null) {
            yearMode = policy['grades_edit_mode'] as String;
          }
        }
      } catch (_) {
        // Ignore if the policies table is not yet deployed.
      }

      bool editable;
      if (!globalEnabled) {
        editable = false;
        _lockMessage = 'Grade management is locked by admin settings.';
      } else if (yearMode == 'locked') {
        editable = false;
      } else if (yearMode == 'unlocked') {
        editable = true;
      } else {
        editable = isYearActive;
      }

      if (!editable && _lockMessage == null) {
        final yearName = _academicYearName ?? 'this academic year';
        if (!isYearActive) {
          _lockMessage =
              'Academic year $yearName has ended. Grade management is locked.';
        } else {
          _lockMessage = 'Grade management is locked.';
        }
      }

      setState(() {
        _isLocked = !editable;
      });
    } catch (_) {
      // If anything goes wrong (missing columns/tables), do not block grading UI.
      setState(() {
        _isLocked = false;
        _lockMessage = null;
      });
    } finally {
      if (mounted) {
        setState(() {
          _loadingLockState = false;
        });
      }
    }
  }

  List<_ServantGradeEntry> _entriesForSelectedSubject() {
    final entries = _gradeEntries
        .where((e) => e.subjectId == _selectedSubject.id)
        .toList();
    entries.sort((a, b) => b.date.compareTo(a.date));
    return entries;
  }

  int _totalWeightForSubject(String subjectId) {
    return _gradeEntries
        .where((e) => e.subjectId == subjectId)
        .fold<int>(0, (sum, e) => sum + (e.weight ?? 0));
  }

  int? _calculateSubjectAverage(String studentId, String subjectId) {
    final entries = _gradeEntries.where((e) => e.subjectId == subjectId);
    if (entries.isEmpty) return 0;

    final allHaveScores = entries.every((e) {
      final score = e.scores[studentId];
      return score != null;
    });
    if (!allHaveScores) return null;

    final totalWeight = entries.fold<int>(0, (sum, e) => sum + (e.weight ?? 0));
    if (totalWeight > 0) {
      var weighted = 0.0;
      for (final entry in entries) {
        final score = entry.scores[studentId];
        if (score == null) continue;
        final pct = (score / entry.maxScore) * 100;
        weighted += pct * ((entry.weight ?? 0) / totalWeight);
      }
      return weighted.round();
    }

    var totalPct = 0.0;
    var count = 0;
    for (final entry in entries) {
      final score = entry.scores[studentId];
      if (score == null) continue;
      totalPct += (score / entry.maxScore) * 100;
      count++;
    }
    if (count == 0) return 0;
    return (totalPct / count).round();
  }

  int _classAverageForEntry(_ServantGradeEntry entry) {
    final scored = entry.scores.values.whereType<double>().toList();
    if (scored.isEmpty) return 0;
    final avgPct =
        scored.map((s) => (s / entry.maxScore) * 100).reduce((a, b) => a + b) /
        scored.length;
    return avgPct.round();
  }

  Color _gradeTextColor(int grade) {
    final c = _criteria.classify(grade.toDouble());
    switch (c) {
      case GradeClassification.excellent:
        return const Color(0xFF16A34A); // green-600
      case GradeClassification.veryGood:
      case GradeClassification.good:
        return const Color(0xFF0284C7); // sky-600
      case GradeClassification.enough:
        return const Color(0xFFD97706); // amber-600
      case GradeClassification.critical:
        return const Color(0xFFDC2626); // red-600
    }
  }

  Color _gradeBarColor(int grade) {
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

  Future<void> _confirmDeleteEntry(_ServantGradeEntry entry) async {
    if (_isLocked) return;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Assessment?'),
          content: Text(
            'Delete “${entry.gradeType}”? This cannot be undone.',
            style: const TextStyle(fontSize: 13),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (result != true) return;
    setState(() {
      _gradeEntries.removeWhere((e) => e.id == entry.id);
      if (_viewingScoresEntryId == entry.id) {
        _viewingScoresEntryId = null;
      }
    });
  }

  void _selectSubject(_ServantGradesSubject subject) {
    setState(() {
      _selectedSubject = subject;
      _view = _ServantGradesView.list;
      _selectedEntry = null;
      _showWeightedGrades = false;
      _weightedSearch = '';
      _viewingScoresEntryId = null;
    });
  }

  void _goToAdd() {
    if (_isLocked) return;
    _resetAssessmentForm();
    setState(() {
      _view = _ServantGradesView.add;
      _selectedEntry = null;
    });
  }

  void _goToEdit(_ServantGradeEntry entry) {
    if (_isLocked) return;
    _resetAssessmentForm(fromEntry: entry);
    setState(() {
      _selectedEntry = entry;
      _view = _ServantGradesView.edit;
    });
  }

  void _goToAddSubject() {
    if (_isLocked) return;
    _subjectNameController.text = '';
    setState(() {
      _view = _ServantGradesView.addSubject;
    });
  }

  void _goToMissing() {
    setState(() {
      _view = _ServantGradesView.missing;
      _showWeightedGrades = false;
    });
  }

  void _goToList() {
    setState(() {
      _view = _ServantGradesView.list;
      _selectedEntry = null;
      _studentScoresSearch = '';
      _studentScoresPage = 0;
    });
  }

  void _resetAssessmentForm({_ServantGradeEntry? fromEntry}) {
    _assessmentNameController.text = fromEntry?.gradeType ?? '';
    _maxScoreController.text = fromEntry == null
        ? ''
        : fromEntry.maxScore.toString();
    _weightController.text = fromEntry?.weight == null
        ? ''
        : fromEntry!.weight.toString();
    _assessmentDate = fromEntry?.date;
    _studentScoresSearch = '';
    _studentScoresPage = 0;

    for (final c in _studentScoreControllers.values) {
      c.dispose();
    }
    _studentScoreControllers.clear();

    for (final s in _students) {
      final value = fromEntry?.scores[s.id];
      _studentScoreControllers[s.id] = TextEditingController(
        text: value == null ? '' : value.toStringAsFixed(0),
      );
    }
  }

  Future<void> _pickAssessmentDate() async {
    if (_isLocked) return;
    final initial = _assessmentDate ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDate: initial,
    );
    if (picked == null) return;
    setState(() {
      _assessmentDate = picked;
    });
  }

  void _saveAssessment({required bool editing}) {
    if (_isLocked) return;

    final name = _assessmentNameController.text.trim();
    final maxScore = int.tryParse(_maxScoreController.text.trim());
    final weightText = _weightController.text.trim();
    final weight = weightText.isEmpty ? null : int.tryParse(weightText);
    final date = _assessmentDate;

    if (name.isEmpty || maxScore == null || maxScore <= 0 || date == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields.')),
      );
      return;
    }
    if (weight != null && (weight < 0 || weight > 100)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Weight must be between 0 and 100.')),
      );
      return;
    }

    final scores = <String, double?>{};
    for (final student in _students) {
      final raw = _studentScoreControllers[student.id]?.text.trim() ?? '';
      if (raw.isEmpty) {
        scores[student.id] = null;
        continue;
      }
      final v = double.tryParse(raw);
      if (v == null || v < 0 || v > maxScore) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Invalid score for ${student.name}. Must be 0-$maxScore.',
            ),
          ),
        );
        return;
      }
      scores[student.id] = v;
    }

    setState(() {
      if (editing) {
        final existingId = _selectedEntry?.id;
        if (existingId == null) return;
        final index = _gradeEntries.indexWhere((e) => e.id == existingId);
        if (index == -1) return;
        _gradeEntries[index] = _ServantGradeEntry(
          id: existingId,
          subjectId: _selectedSubject.id,
          gradeType: name,
          maxScore: maxScore,
          weight: weight,
          date: date,
          scores: scores,
        );
      } else {
        final newId = 'g${DateTime.now().microsecondsSinceEpoch}';
        _gradeEntries.add(
          _ServantGradeEntry(
            id: newId,
            subjectId: _selectedSubject.id,
            gradeType: name,
            maxScore: maxScore,
            weight: weight,
            date: date,
            scores: scores,
          ),
        );
      }
      _view = _ServantGradesView.list;
      _selectedEntry = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(editing ? 'Assessment updated.' : 'Assessment added.'),
      ),
    );
  }

  void _saveSubject() {
    if (_isLocked) return;
    final name = _subjectNameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Subject name is required.')),
      );
      return;
    }
    final id = 's${DateTime.now().microsecondsSinceEpoch}';
    final subject = _ServantGradesSubject(id: id, name: name);
    setState(() {
      _subjects.add(subject);
      _selectedSubject = subject;
      _view = _ServantGradesView.list;
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Subject added.')));
  }

  Widget _pill({
    required String text,
    Color bg = const Color(0xFFFEF3C7),
    Color fg = const Color(0xFFB45309),
    IconData? icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: fg),
            const SizedBox(width: 6),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({required String hint, IconData? icon}) {
    return InputDecoration(
      hintText: hint,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      prefixIcon: icon == null
          ? null
          : Icon(icon, size: 20, color: const Color(0xFF9CA3AF)),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      enabledBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
        borderSide: BorderSide(color: Color(0xFFCBD5E1)),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
        borderSide: BorderSide(color: Color(0xFF0EA5E9), width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final entries = _entriesForSelectedSubject();
    final totalWeight = _totalWeightForSubject(_selectedSubject.id);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // slate-50
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (context, _) {
            return [
              SliverAppBar(
                pinned: true,
                backgroundColor: Colors.white,
                surfaceTintColor: Colors.white,
                elevation: 0,
                scrolledUnderElevation: 0,
                automaticallyImplyLeading: false,
                toolbarHeight: 64,
                titleSpacing: 24,
                title: const Text(
                  'Manage Grades',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(92),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (!_loadingLockState &&
                          _isLocked &&
                          _lockMessage != null)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF3C7), // amber-100
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFFDE68A), // amber-200
                              ),
                            ),
                            child: Text(
                              _lockMessage!,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF78350F),
                              ),
                            ),
                          ),
                        ),

                      SizedBox(
                        height: 46,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          children: [
                            for (final s in _subjects) ...[
                              Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: _SubjectChip(
                                  selected: s.id == _selectedSubject.id,
                                  label: s.name,
                                  onTap: () => _selectSubject(s),
                                ),
                              ),
                            ],
                            _SubjectChip(
                              selected: false,
                              label: 'New Subject',
                              tone: _ChipTone.amber,
                              icon: Icons.add_rounded,
                              onTap: _goToAddSubject,
                              disabled: _isLocked,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        height: 1,
                        color: const Color(0xFFE2E8F0), // slate-200
                      ),
                    ],
                  ),
                ),
              ),
            ];
          },
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 28),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: switch (_view) {
                _ServantGradesView.list => _buildList(
                  entries: entries,
                  totalWeight: totalWeight,
                ),
                _ServantGradesView.add => _buildAssessmentForm(editing: false),
                _ServantGradesView.edit => _buildAssessmentForm(editing: true),
                _ServantGradesView.addSubject => _buildAddSubjectForm(),
                _ServantGradesView.missing => _buildMissingView(
                  entries: entries,
                ),
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildList({
    required List<_ServantGradeEntry> entries,
    required int totalWeight,
  }) {
    return Column(
      key: const ValueKey('servant-grades-list'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (entries.isNotEmpty) _buildWeightSummary(totalWeight),
        const SizedBox(height: 12),

        SizedBox(
          height: 52,
          child: FilledButton.icon(
            onPressed: _isLocked ? null : _goToAdd,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFF59E0B), // amber-500
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add New Assessment'),
          ),
        ),

        if (entries.isNotEmpty) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: FilledButton.icon(
                    onPressed: () {
                      setState(() {
                        _showWeightedGrades = !_showWeightedGrades;
                      });
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF0EA5E9), // sky-500
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: const Icon(Icons.trending_up_rounded),
                    label: Text(
                      _showWeightedGrades ? 'Hide Grades' : 'All Grades',
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: FilledButton.icon(
                    onPressed: _goToMissing,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFEF4444), // red-500
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: const Icon(Icons.error_outline_rounded),
                    label: const Text('Missing'),
                  ),
                ),
              ),
            ],
          ),
        ],

        if (_showWeightedGrades && entries.isNotEmpty) ...[
          const SizedBox(height: 14),
          _buildWeightedGradesCard(entries: entries, totalWeight: totalWeight),
        ],

        const SizedBox(height: 14),
        if (entries.isEmpty)
          _buildEmptyState()
        else
          ...entries.map(_buildEntryCard),
      ],
    );
  }

  Widget _buildWeightSummary(int totalWeight) {
    final Color bg;
    final Color border;
    final Color fg;
    final String helper;
    if (totalWeight == 100) {
      bg = const Color(0xFFDCFCE7); // green-100
      border = const Color(0xFFBBF7D0); // green-200
      fg = const Color(0xFF16A34A); // green-600
      helper = '';
    } else if (totalWeight > 100) {
      bg = const Color(0xFFFEE2E2); // red-100
      border = const Color(0xFFFECACA); // red-200
      fg = const Color(0xFFDC2626); // red-600
      helper = 'Total weight exceeds 100%';
    } else {
      bg = const Color(0xFFFEF3C7); // amber-100
      border = const Color(0xFFFDE68A); // amber-200
      fg = const Color(0xFFB45309); // amber-700
      helper = '${100 - totalWeight}% remaining to reach 100%';
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.percent_rounded, color: fg, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Total Weight:',
                    style: TextStyle(fontSize: 13, color: Color(0xFF334155)),
                  ),
                ],
              ),
              Text(
                '$totalWeight%',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: fg,
                ),
              ),
            ],
          ),
          if (helper.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('⚠️ $helper', style: TextStyle(fontSize: 12, color: fg)),
          ],
        ],
      ),
    );
  }

  Widget _buildWeightedGradesCard({
    required List<_ServantGradeEntry> entries,
    required int totalWeight,
  }) {
    final subjectName = _selectedSubject.name;

    final validScores = _students
        .map((s) => _calculateSubjectAverage(s.id, _selectedSubject.id))
        .whereType<int>()
        .toList();

    final classAvg = validScores.isEmpty
        ? null
        : (validScores.reduce((a, b) => a + b) / validScores.length).round();
    final highest = validScores.isEmpty
        ? null
        : validScores.reduce((a, b) => a > b ? a : b);
    final lowest = validScores.isEmpty
        ? null
        : validScores.reduce((a, b) => a < b ? a : b);

    final filteredStudents = _students
        .where(
          (s) => s.name.toLowerCase().contains(_weightedSearch.toLowerCase()),
        )
        .toList();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14374151),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
            decoration: const BoxDecoration(
              color: Color(0xFFE0F2FE), // sky-100
              borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.trending_up_rounded,
                      color: Color(0xFF0284C7),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Student Weighted Grades - $subjectName',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Based on ${entries.length} assessment${entries.length == 1 ? '' : 's'} with $totalWeight% total weight',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF475569),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  onChanged: (v) => setState(() => _weightedSearch = v),
                  decoration: _inputDecoration(
                    hint: 'Search by student name...',
                    icon: Icons.search_rounded,
                  ),
                ),
              ],
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              final viewportWidth = constraints.maxWidth;
              final tableWidth = viewportWidth < 640 ? 640.0 : viewportWidth;

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: tableWidth,
                    maxWidth: tableWidth,
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        color: const Color(0xFFF8FAFC),
                        child: const Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Text(
                                'Student Name',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF334155),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  'Weighted Score',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF334155),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Padding(
                                padding: EdgeInsets.only(left: 14),
                                child: Text(
                                  'Grade',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF334155),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      for (final student in filteredStudents)
                        _buildWeightedRow(student: student, entries: entries),
                    ],
                  ),
                ),
              );
            },
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(18)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _stat(
                    label: 'Class Average',
                    value: classAvg == null ? 'N/A' : '$classAvg%',
                    valueColor: const Color(0xFF0F172A),
                  ),
                ),
                Expanded(
                  child: _stat(
                    label: 'Highest',
                    value: highest == null ? 'N/A' : '$highest%',
                    valueColor: const Color(0xFF16A34A),
                  ),
                ),
                Expanded(
                  child: _stat(
                    label: 'Lowest',
                    value: lowest == null ? 'N/A' : '$lowest%',
                    valueColor: const Color(0xFFDC2626),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat({
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Widget _buildWeightedRow({
    required _ServantGradesStudent student,
    required List<_ServantGradeEntry> entries,
  }) {
    final avg = _calculateSubjectAverage(student.id, _selectedSubject.id);
    final missing = entries.where((e) => e.scores[student.id] == null).toList();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                ),
                if (avg == null && missing.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  const Text(
                    'Missing:',
                    style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 4),
                  for (final m in missing)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 3),
                      child: Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF87171),
                              borderRadius: BorderRadius.circular(99),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              m.gradeType,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFFDC2626),
                              ),
                            ),
                          ),
                          if (m.weight != null)
                            Text(
                              '(${m.weight}%)',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFFB45309),
                              ),
                            ),
                        ],
                      ),
                    ),
                ],
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerRight,
              child: avg == null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'Incomplete',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFB45309),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${missing.length} missing',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFFDC2626),
                          ),
                        ),
                      ],
                    )
                  : Text(
                      '$avg%',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: _gradeTextColor(avg),
                      ),
                    ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.only(left: 14),
              child: avg == null
                  ? const Center(
                      child: Text(
                        'N/A',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    )
                  : Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: (avg.clamp(0, 100)) / 100,
                        child: Container(
                          decoration: BoxDecoration(
                            color: _gradeBarColor(avg),
                            borderRadius: BorderRadius.circular(99),
                          ),
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEntryCard(_ServantGradeEntry entry) {
    final avg = _classAverageForEntry(entry);
    final dateLabel = EthiopianDateFormatter.formatDateTime(entry.date);
    final isOpen = _viewingScoresEntryId == entry.id;
    final search = _entryScoreSearch[entry.id] ?? '';
    final filtered = _students
        .where((s) => s.name.toLowerCase().contains(search.toLowerCase()))
        .toList();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14374151),
              blurRadius: 14,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                entry.gradeType,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                            ),
                            if (entry.weight != null)
                              _pill(
                                text: '${entry.weight}%',
                                icon: Icons.percent_rounded,
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 10,
                          runSpacing: 6,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.calendar_today_rounded,
                                  size: 14,
                                  color: Color(0xFF64748B),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  dateLabel,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.description_outlined,
                                  size: 14,
                                  color: Color(0xFF64748B),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Max: ${entry.maxScore} points',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    onPressed: _isLocked ? null : () => _goToEdit(entry),
                    icon: const Icon(Icons.edit_outlined),
                    color: const Color(0xFF0EA5E9),
                    tooltip: 'Edit grades',
                  ),
                  IconButton(
                    onPressed: _isLocked
                        ? null
                        : () => _confirmDeleteEntry(entry),
                    icon: const Icon(Icons.delete_outline_rounded),
                    color: const Color(0xFFEF4444),
                    tooltip: 'Delete assessment',
                  ),
                ],
              ),

              const SizedBox(height: 10),
              Row(
                children: [
                  const Text(
                    'Class average',
                    style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                  ),
                  const Spacer(),
                  Text(
                    '$avg%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _gradeTextColor(avg),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                height: 10,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: (avg.clamp(0, 100)) / 100,
                  child: Container(
                    decoration: BoxDecoration(
                      color: _gradeBarColor(avg),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _viewingScoresEntryId = isOpen ? null : entry.id;
                  });
                },
                icon: Icon(
                  isOpen
                      ? Icons.expand_less_rounded
                      : Icons.expand_more_rounded,
                  color: const Color(0xFF0EA5E9),
                ),
                label: Text(
                  isOpen ? 'Hide Student Scores' : 'View Student Scores',
                  style: const TextStyle(color: Color(0xFF0EA5E9)),
                ),
              ),

              if (isOpen) ...[
                TextField(
                  onChanged: (v) => setState(() {
                    _entryScoreSearch[entry.id] = v;
                  }),
                  decoration: _inputDecoration(
                    hint: 'Search students...',
                    icon: Icons.search_rounded,
                  ),
                ),
                const SizedBox(height: 10),
                for (final student in filtered)
                  _scoreRow(
                    name: student.name,
                    score: entry.scores[student.id],
                    maxScore: entry.maxScore,
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _scoreRow({
    required String name,
    required double? score,
    required int maxScore,
  }) {
    final missing = score == null;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                name,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F172A),
                ),
              ),
            ),
            if (missing)
              const Text(
                'Missing',
                style: TextStyle(fontSize: 12, color: Color(0xFFDC2626)),
              )
            else
              Text(
                '${score.toStringAsFixed(0)} / $maxScore',
                style: const TextStyle(fontSize: 12, color: Color(0xFF334155)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14374151),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'No assessments yet',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Add an assessment to start tracking student scores for this subject.',
            style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }

  Widget _buildAssessmentForm({required bool editing}) {
    final title = editing ? 'Edit Assessment' : 'Add Assessment';
    final entry = editing ? _selectedEntry : null;
    final classAvg = entry == null ? null : _classAverageForEntry(entry);

    final filteredStudents = _students
        .where(
          (s) =>
              s.name.toLowerCase().contains(_studentScoresSearch.toLowerCase()),
        )
        .toList();
    final totalPages = (filteredStudents.length / _scoresPageSize).ceil();
    final currentPage = _studentScoresPage.clamp(
      0,
      (totalPages - 1).clamp(0, 999),
    );
    final start = currentPage * _scoresPageSize;
    final end = (start + _scoresPageSize).clamp(0, filteredStudents.length);
    final pageStudents = filteredStudents.sublist(start, end);

    return Column(
      key: ValueKey(editing ? 'servant-grades-edit' : 'servant-grades-add'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            IconButton(
              onPressed: _goToList,
              icon: const Icon(Icons.arrow_back_rounded),
              tooltip: 'Back',
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
            const Spacer(),
            if (editing && classAvg != null)
              _pill(
                text: 'Class Avg: $classAvg%',
                bg: const Color(0xFFE0F2FE),
                fg: const Color(0xFF0369A1),
                icon: Icons.trending_up_rounded,
              ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14374151),
                blurRadius: 14,
                offset: Offset(0, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _assessmentNameController,
                enabled: !_isLocked,
                decoration: _inputDecoration(
                  hint: 'Assessment name (e.g., Quiz 1)',
                  icon: Icons.description_outlined,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _maxScoreController,
                      enabled: !_isLocked,
                      keyboardType: TextInputType.number,
                      decoration: _inputDecoration(
                        hint: 'Max score',
                        icon: Icons.numbers_rounded,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _weightController,
                      enabled: !_isLocked,
                      keyboardType: TextInputType.number,
                      decoration: _inputDecoration(
                        hint: 'Weight % (optional)',
                        icon: Icons.percent_rounded,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: _isLocked ? null : _pickAssessmentDate,
                borderRadius: BorderRadius.circular(14),
                child: IgnorePointer(
                  child: TextField(
                    enabled: !_isLocked,
                    decoration: _inputDecoration(
                      hint: _assessmentDate == null
                          ? 'Date'
                          : EthiopianDateFormatter.formatDateTime(
                              _assessmentDate!,
                            ),
                      icon: Icons.calendar_today_rounded,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Student Scores (Optional)',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                enabled: !_isLocked,
                onChanged: (v) {
                  setState(() {
                    _studentScoresSearch = v;
                    _studentScoresPage = 0;
                  });
                },
                decoration: _inputDecoration(
                  hint: 'Search students...',
                  icon: Icons.search_rounded,
                ),
              ),
              const SizedBox(height: 10),
              if (totalPages > 1)
                Row(
                  children: [
                    Text(
                      'Page ${currentPage + 1} / $totalPages',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: !_isLocked && currentPage > 0
                          ? () => setState(
                              () => _studentScoresPage = currentPage - 1,
                            )
                          : null,
                      child: const Text('Prev'),
                    ),
                    TextButton(
                      onPressed: !_isLocked && currentPage < totalPages - 1
                          ? () => setState(
                              () => _studentScoresPage = currentPage + 1,
                            )
                          : null,
                      child: const Text('Next'),
                    ),
                  ],
                ),
              const SizedBox(height: 8),
              for (final s in pageStudents)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            s.name,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 110,
                          child: TextField(
                            enabled: !_isLocked,
                            controller: _studentScoreControllers[s.id],
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.end,
                            decoration: _inputDecoration(hint: 'Score'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _goToList,
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                        foregroundColor: const Color(0xFF334155),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _isLocked
                          ? null
                          : () => _saveAssessment(editing: editing),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF0EA5E9),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: const Icon(Icons.save_rounded),
                      label: const Text('Save'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAddSubjectForm() {
    return Column(
      key: const ValueKey('servant-grades-add-subject'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            IconButton(
              onPressed: _goToList,
              icon: const Icon(Icons.arrow_back_rounded),
              tooltip: 'Back',
            ),
            const SizedBox(width: 6),
            const Text(
              'Add Subject',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14374151),
                blurRadius: 14,
                offset: Offset(0, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                enabled: !_isLocked,
                controller: _subjectNameController,
                decoration: _inputDecoration(
                  hint: 'Subject name (e.g., Theology)',
                  icon: Icons.book_outlined,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _goToList,
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                        foregroundColor: const Color(0xFF334155),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _isLocked ? null : _saveSubject,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF0EA5E9),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: const Icon(Icons.save_rounded),
                      label: const Text('Save'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMissingView({required List<_ServantGradeEntry> entries}) {
    final studentsWithMissing =
        <_ServantGradesStudent, List<_ServantGradeEntry>>{};
    for (final student in _students) {
      final missing = entries
          .where((e) => e.scores[student.id] == null)
          .toList();
      if (missing.isNotEmpty) {
        studentsWithMissing[student] = missing;
      }
    }

    return Column(
      key: const ValueKey('servant-grades-missing'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            IconButton(
              onPressed: _goToList,
              icon: const Icon(Icons.arrow_back_rounded),
              tooltip: 'Back',
            ),
            const SizedBox(width: 6),
            Text(
              'Missing Assessments - ${_selectedSubject.name}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFFEE2E2),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFFECACA)),
          ),
          child: Text(
            '${studentsWithMissing.length} student${studentsWithMissing.length == 1 ? '' : 's'} with incomplete assessments',
            style: const TextStyle(fontSize: 12, color: Color(0xFF7F1D1D)),
          ),
        ),
        const SizedBox(height: 12),
        if (studentsWithMissing.isEmpty)
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x14374151),
                  blurRadius: 14,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: const Text(
              'No missing assessments found.',
              style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
            ),
          )
        else
          for (final e in studentsWithMissing.entries)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x14374151),
                      blurRadius: 14,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      e.key.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    for (final missing in e.value)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.error_outline_rounded,
                              size: 16,
                              color: Color(0xFFDC2626),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                missing.gradeType,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFFDC2626),
                                ),
                              ),
                            ),
                            if (missing.weight != null)
                              Text(
                                '${missing.weight}%',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFFB45309),
                                ),
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
      ],
    );
  }
}

enum _ChipTone { sky, amber }

class _SubjectChip extends StatelessWidget {
  const _SubjectChip({
    required this.selected,
    required this.label,
    required this.onTap,
    this.tone = _ChipTone.sky,
    this.icon,
    this.disabled = false,
  });

  final bool selected;
  final String label;
  final VoidCallback onTap;
  final _ChipTone tone;
  final IconData? icon;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    final isSky = tone == _ChipTone.sky;
    final selectedBg = isSky
        ? const Color(0xFF0EA5E9)
        : const Color(0xFFFDE68A);
    final selectedFg = isSky ? Colors.white : const Color(0xFF92400E);

    final bg = selected
        ? selectedBg
        : (isSky ? const Color(0xFFF1F5F9) : const Color(0xFFFEF3C7));
    final fg = selected
        ? selectedFg
        : (isSky ? const Color(0xFF334155) : const Color(0xFFB45309));

    return InkWell(
      onTap: disabled ? null : onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 120),
        opacity: disabled ? 0.6 : 1,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: fg),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: fg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ServantCommunicationScreen extends StatelessWidget {
  const ServantCommunicationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ServantCommunicationBody();
  }
}

class _ServantCommunicationBody extends StatefulWidget {
  const _ServantCommunicationBody();

  @override
  State<_ServantCommunicationBody> createState() =>
      _ServantCommunicationBodyState();
}

enum _ServantCommTab { announcements, questions, complaints, feedback }

class _ServantCommunicationBodyState extends State<_ServantCommunicationBody> {
  _ServantCommTab _activeTab = _ServantCommTab.announcements;

  bool _showAnnouncementForm = false;

  bool _showCreateFeedback = false;
  String? _viewingFeedbackFormId;
  bool _showFeedbackSuccessToast = false;

  String? _activeAcademicYearId;
  String? _myGradeId;
  final Map<String, int> _feedbackSubmissionCounts = {};

  final _announcementTitleController = TextEditingController();
  final _announcementMessageController = TextEditingController();
  String _announcementCategory = 'general';
  final String _announcementTargetAudience = 'students';
  final String _announcementPriority = 'medium';
  String? _announcementExpiresOn;

  final List<_ServantAnnouncement> _announcements = [
    const _ServantAnnouncement(
      id: 'a1',
      title: 'Exam Schedule Update',
      message:
          'Mid-term exams will start next Sunday at 9:00 AM. Please arrive 15 minutes early and bring your materials.',
      category: 'schedule',
      createdBy: 'Program Coordinator',
      createdDate: '2026-03-02',
      priority: 'high',
      targetAudience: 'students',
    ),
    const _ServantAnnouncement(
      id: 'a2',
      title: 'Bible Memory Challenge',
      message:
          'This month we are focusing on Psalm 23. Try to memorize the whole chapter by the end of the month!',
      category: 'event',
      createdBy: 'Class Servant',
      createdDate: '2026-03-01',
      priority: 'medium',
      targetAudience: 'students',
    ),
  ];
  String? _expandedAnnouncementId;

  final List<_ServantQuestion> _questions = [
    const _ServantQuestion(
      id: 'q1',
      studentId: '1',
      studentName: 'Sarah Johnson',
      subjectId: '101',
      subjectName: 'Bible Study',
      question: 'Can you explain the meaning of the parable of the sower?',
      date: '2026-02-25',
      answered: false,
    ),
    const _ServantQuestion(
      id: 'q2',
      studentId: '2',
      studentName: 'Michael Chen',
      subjectId: '102',
      subjectName: 'Theology',
      question:
          'What is the difference between justification and sanctification?',
      date: '2026-02-22',
      answered: true,
      answer:
          'Justification is being declared righteous before God through faith in Christ. Sanctification is the ongoing process of being made holy in daily life.',
      answeredBy: 'Servant Mary',
      answeredDate: '2026-02-23',
    ),
    const _ServantQuestion(
      id: 'q3',
      studentId: '3',
      studentName: 'Daniel Okoro',
      subjectId: '101',
      subjectName: 'Bible Study',
      question:
          'How should we apply James 1:22 in our daily routines as students?',
      date: '2026-02-26',
      answered: false,
    ),
  ];

  String _questionStatusFilter = 'all'; // all | pending | answered
  String _questionSubjectFilter = 'all';
  String? _respondingQuestionId;
  final Map<String, TextEditingController> _questionReplyControllers = {};

  final List<_ServantComplaint> _complaints = [
    const _ServantComplaint(
      id: 'c1',
      studentId: '4',
      studentName: 'Ava Martinez',
      complaint: 'The classroom is often too noisy during lessons.',
      category: 'facility',
      date: '2026-02-20',
      status: 'pending',
    ),
    const _ServantComplaint(
      id: 'c2',
      studentId: '5',
      studentName: 'Samuel Lee',
      complaint: 'Sometimes the lesson starts late and we miss content.',
      category: 'administration',
      date: '2026-02-18',
      status: 'in-review',
      response:
          'Thanks for reporting. We are adjusting the schedule and reminders.',
      respondedBy: 'Servant John',
      respondedDate: '2026-02-19',
    ),
    const _ServantComplaint(
      id: 'c3',
      studentId: '6',
      studentName: 'Grace Nwosu',
      complaint: 'I need clarification on grading fairness across groups.',
      category: 'teaching',
      date: '2026-02-16',
      status: 'resolved',
      response:
          'We reviewed the grading rubric and aligned it across groups. Thanks for raising this.',
      respondedBy: 'Servant Mary',
      respondedDate: '2026-02-17',
    ),
  ];

  String _complaintStatusFilter = 'all'; // all | pending | in-review | resolved
  String _complaintCategoryFilter = 'all';
  String? _respondingComplaintId;
  final Map<String, TextEditingController> _complaintReplyControllers = {};
  final Map<String, String> _complaintNextStatus = {};

  static const int _mockTotalStudents = 30;

  final _feedbackTitleController = TextEditingController();
  final _feedbackDescriptionController = TextEditingController();
  String _feedbackType = '';
  String _feedbackStartDate = '';
  String _feedbackEndDate = '';

  final List<_DraftFeedbackQuestion> _draftFeedbackQuestions = [];
  bool _showAddFeedbackQuestion = false;
  final _draftQuestionTextController = TextEditingController();
  String _draftQuestionType = 'rating';
  bool _draftQuestionRequired = true;
  final List<TextEditingController> _draftOptionControllers = [
    TextEditingController(),
  ];

  final List<_ServantFeedbackForm> _feedbackForms = [
    _ServantFeedbackForm(
      id: 'f1',
      title: 'Teacher Evaluation - February',
      description:
          'Help us improve teaching by sharing your thoughts about lessons and engagement.',
      type: 'teacher_evaluation',
      createdBy: 'Admin',
      createdDate: '2026-02-10',
      startDate: '2026-02-10',
      endDate: '2026-02-28',
      status: 'active',
      targetStudents: ['all'],
      questions: [
        _ServantFeedbackQuestion(
          id: 'q1',
          question: 'How clear were the explanations during lessons?',
          type: 'rating',
          required: true,
        ),
        _ServantFeedbackQuestion(
          id: 'q2',
          question: 'What should we improve in teaching style?',
          type: 'text',
          required: false,
        ),
        _ServantFeedbackQuestion(
          id: 'q3',
          question: 'Overall engagement level?',
          type: 'multiple_choice',
          required: true,
          options: ['Excellent', 'Good', 'Average', 'Needs improvement'],
        ),
      ],
    ),
    _ServantFeedbackForm(
      id: 'f2',
      title: 'Facility Feedback - March',
      description:
          'Tell us how we can improve the classroom environment and facilities.',
      type: 'general',
      createdBy: 'Admin',
      createdDate: '2026-03-01',
      startDate: '2026-03-01',
      endDate: '2026-03-20',
      status: 'active',
      targetStudents: ['all'],
      questions: [
        _ServantFeedbackQuestion(
          id: 'q1',
          question: 'Rate the classroom comfort (lighting, seating, noise).',
          type: 'rating',
          required: true,
        ),
        _ServantFeedbackQuestion(
          id: 'q2',
          question: 'What facility issue should we fix first?',
          type: 'multiple_choice',
          required: true,
          options: ['Seating', 'Air flow', 'Projector', 'Sound system'],
        ),
        _ServantFeedbackQuestion(
          id: 'q3',
          question: 'Any additional comments?',
          type: 'text',
          required: false,
        ),
      ],
    ),
  ];

  final List<_ServantFeedbackResponse> _feedbackResponses = [
    _ServantFeedbackResponse(
      id: 'fr1',
      formId: 'f1',
      studentId: '1',
      studentName: 'Sarah Johnson',
      submittedDate: '2026-02-20',
      answers: {
        'q1': 5,
        'q2': 'Very clear overall. More examples would help.',
        'q3': 'Excellent',
      },
    ),
    _ServantFeedbackResponse(
      id: 'fr2',
      formId: 'f1',
      studentId: '2',
      studentName: 'Michael Chen',
      submittedDate: '2026-02-21',
      answers: {
        'q1': 4,
        'q2': 'Sometimes a bit fast; pacing could be slower.',
        'q3': 'Good',
      },
    ),
    _ServantFeedbackResponse(
      id: 'fr3',
      formId: 'f2',
      studentId: '3',
      studentName: 'Daniel Okoro',
      submittedDate: '2026-03-03',
      answers: {
        'q1': 3,
        'q2': 'Sound system',
        'q3': 'Projector brightness is low in the afternoon.',
      },
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadFeedbackFromBackend();
    _loadAnnouncementsFromBackend();
    _loadQuestionsFromBackend();
    _loadComplaintsFromBackend();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      AppRefreshScope.of(context).setOnRefresh(_handlePullToRefresh);
    });
  }

  Future<void> _handlePullToRefresh() async {
    await Future.wait([
      _loadFeedbackFromBackend(),
      _loadAnnouncementsFromBackend(),
      _loadQuestionsFromBackend(),
      _loadComplaintsFromBackend(),
    ]);
  }

  @override
  void dispose() {
    try {
      AppRefreshScope.of(context).setOnRefresh(null);
    } catch (_) {}
    _announcementTitleController.dispose();
    _announcementMessageController.dispose();
    _feedbackTitleController.dispose();
    _feedbackDescriptionController.dispose();
    _draftQuestionTextController.dispose();
    for (final c in _draftOptionControllers) {
      c.dispose();
    }
    for (final c in _questionReplyControllers.values) {
      c.dispose();
    }
    for (final c in _complaintReplyControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<({String? userId, String? academicYearId, String? gradeId})>
  _ensureContextLoaded() async {
    final client = SupabaseClientManager.instance.client;
    final userId = client.auth.currentUser?.id;
    if (userId == null) {
      return (userId: null, academicYearId: null, gradeId: null);
    }

    if (_activeAcademicYearId != null && _myGradeId != null) {
      return (
        userId: userId,
        academicYearId: _activeAcademicYearId,
        gradeId: _myGradeId,
      );
    }

    String? activeAcademicYearId = _activeAcademicYearId;
    String? myGradeId = _myGradeId;

    try {
      final academicYear = await client
          .from('academic_years')
          .select('id')
          .eq('status', 'active')
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();
      activeAcademicYearId ??= academicYear?['id'] as String?;
    } catch (_) {}

    try {
      final profile = await client
          .from('profiles')
          .select('grade_id')
          .eq('id', userId)
          .maybeSingle();
      myGradeId ??= profile?['grade_id'] as String?;
    } catch (_) {}

    if (mounted) {
      setState(() {
        _activeAcademicYearId = activeAcademicYearId;
        _myGradeId = myGradeId;
      });
    } else {
      _activeAcademicYearId = activeAcademicYearId;
      _myGradeId = myGradeId;
    }

    return (
      userId: userId,
      academicYearId: activeAcademicYearId,
      gradeId: myGradeId,
    );
  }

  static String _dateOnly(String value) {
    if (value.length >= 10) return value.substring(0, 10);
    return value;
  }

  static String _complaintStatusFromDb(String status) {
    if (status == 'in_review') return 'in-review';
    return status;
  }

  static String _complaintStatusToDb(String status) {
    if (status == 'in-review') return 'in_review';
    return status;
  }

  Future<void> _loadAnnouncementsFromBackend() async {
    final client = SupabaseClientManager.instance.client;

    final ctx = await _ensureContextLoaded();
    final userId = ctx.userId;
    final gradeId = ctx.gradeId;
    final academicYearId = ctx.academicYearId;
    if (userId == null || gradeId == null) return;

    try {
      var query = client
          .from('announcements')
          .select(
            'id, title, message, category, priority, created_by, created_at, expires_on, active, grade_id, academic_year_id',
          )
          .eq('active', true);

      if (academicYearId != null) {
        query = query.eq('academic_year_id', academicYearId);
      }

      query = query.or('grade_id.is.null,grade_id.eq.$gradeId');

      final rows = await query.order('created_at', ascending: false);
      final items = rows.map((r) {
        final map = r as Map;
        final createdAt = map['created_at']?.toString() ?? '';
        final createdById = map['created_by']?.toString() ?? '';
        return _ServantAnnouncement(
          id: map['id'] as String,
          title: (map['title'] as String?) ?? '',
          message: (map['message'] as String?) ?? '',
          category: (map['category'] as String?) ?? 'general',
          createdBy: createdById == userId ? 'You' : 'Servant',
          createdDate: createdAt.isNotEmpty
              ? _dateOnly(createdAt)
              : _todayIso(),
          priority: (map['priority'] as String?) ?? 'medium',
          targetAudience: 'students',
          expiresOn: (map['expires_on'] as String?),
        );
      }).toList();

      if (!mounted) return;
      setState(() {
        _announcements
          ..clear()
          ..addAll(items);
        _expandedAnnouncementId = null;
      });
    } catch (_) {
      // Keep mock data on any error.
    }
  }

  Future<_ServantAnnouncement?> _createAnnouncementInBackend({
    required String title,
    required String message,
    required String category,
    required String priority,
    required String targetAudience,
    String? expiresOnIso,
  }) async {
    final client = SupabaseClientManager.instance.client;
    final ctx = await _ensureContextLoaded();
    final userId = ctx.userId;
    final gradeId = ctx.gradeId;
    final academicYearId = ctx.academicYearId;
    if (userId == null || gradeId == null) return null;

    final expires = (expiresOnIso ?? '').trim();
    final validExpires = DateTime.tryParse(expires) != null ? expires : null;

    final inserted = await client
        .from('announcements')
        .insert({
          'academic_year_id': academicYearId,
          'grade_id': gradeId,
          'title': title,
          'message': message,
          'category': category,
          'priority': priority,
          'created_by': userId,
          'expires_on': validExpires,
          'active': true,
        })
        .select(
          'id, title, message, category, priority, created_by, created_at, expires_on',
        )
        .single();

    final createdAt = inserted['created_at']?.toString() ?? '';
    return _ServantAnnouncement(
      id: inserted['id'] as String,
      title: inserted['title'] as String,
      message: inserted['message'] as String,
      category: (inserted['category'] as String?) ?? 'general',
      createdBy: 'You',
      createdDate: createdAt.isNotEmpty ? _dateOnly(createdAt) : _todayIso(),
      priority: (inserted['priority'] as String?) ?? 'medium',
      targetAudience: targetAudience,
      expiresOn: inserted['expires_on'] as String?,
    );
  }

  Future<bool> _deleteAnnouncementInBackend(String id) async {
    final client = SupabaseClientManager.instance.client;
    try {
      await client.from('announcements').delete().eq('id', id);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _loadQuestionsFromBackend() async {
    final client = SupabaseClientManager.instance.client;

    final ctx = await _ensureContextLoaded();
    final userId = ctx.userId;
    final gradeId = ctx.gradeId;
    final academicYearId = ctx.academicYearId;
    if (userId == null || gradeId == null || academicYearId == null) return;

    try {
      final rows = await client
          .from('questions')
          .select(
            'id, student_id, subject_id, question, created_at, answered, answer, answered_by, answered_at',
          )
          .eq('grade_id', gradeId)
          .eq('academic_year_id', academicYearId)
          .order('created_at', ascending: false);

      final studentIds = <String>{};
      final subjectIds = <String>{};
      for (final r in rows) {
        final map = r as Map;
        final sid = map['student_id']?.toString();
        final subId = map['subject_id']?.toString();
        if (sid != null && sid.isNotEmpty) studentIds.add(sid);
        if (subId != null && subId.isNotEmpty) subjectIds.add(subId);
      }

      final studentNames = <String, String>{};
      if (studentIds.isNotEmpty) {
        try {
          final profiles = await client
              .from('profiles')
              .select('id, name')
              .inFilter('id', studentIds.toList());
          for (final p in profiles) {
            final m = p as Map;
            final id = m['id']?.toString();
            if (id == null) continue;
            studentNames[id] = (m['name'] as String?) ?? 'Student';
          }
        } catch (_) {}
      }

      final subjectNames = <String, String>{};
      if (subjectIds.isNotEmpty) {
        try {
          final subjects = await client
              .from('subjects')
              .select('id, name')
              .inFilter('id', subjectIds.toList());
          for (final s in subjects) {
            final m = s as Map;
            final id = m['id']?.toString();
            if (id == null) continue;
            subjectNames[id] = (m['name'] as String?) ?? 'General';
          }
        } catch (_) {}
      }

      final items = rows.map((r) {
        final map = r as Map;
        final createdAt = map['created_at']?.toString() ?? '';
        final answeredAt = map['answered_at']?.toString();
        final studentId = map['student_id']?.toString() ?? '';
        final subjectId = map['subject_id']?.toString();
        final answeredById = map['answered_by']?.toString();

        return _ServantQuestion(
          id: map['id'] as String,
          studentId: studentId,
          studentName: studentNames[studentId] ?? 'Student',
          subjectId: subjectId ?? '',
          subjectName: (subjectId == null || subjectId.isEmpty)
              ? 'General'
              : (subjectNames[subjectId] ?? 'General'),
          question: (map['question'] as String?) ?? '',
          date: createdAt.isNotEmpty ? _dateOnly(createdAt) : _todayIso(),
          answered: (map['answered'] as bool?) ?? false,
          answer: map['answer'] as String?,
          answeredBy: answeredById == null
              ? null
              : (answeredById == userId ? 'You' : 'Servant'),
          answeredDate: answeredAt == null ? null : _dateOnly(answeredAt),
        );
      }).toList();

      if (!mounted) return;
      setState(() {
        _questions
          ..clear()
          ..addAll(items);
        _respondingQuestionId = null;
      });
    } catch (_) {
      // Keep mock data on any error.
    }
  }

  Future<bool> _answerQuestionInBackend({
    required String questionId,
    required String reply,
  }) async {
    final client = SupabaseClientManager.instance.client;
    final userId = client.auth.currentUser?.id;
    if (userId == null) return false;

    try {
      await client
          .from('questions')
          .update({
            'answered': true,
            'answer': reply,
            'answered_by': userId,
            'answered_at': DateTime.now().toIso8601String(),
          })
          .eq('id', questionId);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> _deleteQuestionInBackend(String id) async {
    final client = SupabaseClientManager.instance.client;
    try {
      await client.from('questions').delete().eq('id', id);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _loadComplaintsFromBackend() async {
    final client = SupabaseClientManager.instance.client;

    final ctx = await _ensureContextLoaded();
    final userId = ctx.userId;
    final gradeId = ctx.gradeId;
    final academicYearId = ctx.academicYearId;
    if (userId == null || gradeId == null || academicYearId == null) return;

    try {
      final rows = await client
          .from('complaints')
          .select(
            'id, student_id, category, complaint, created_at, status, response, responded_by, responded_at',
          )
          .eq('grade_id', gradeId)
          .eq('academic_year_id', academicYearId)
          .order('created_at', ascending: false);

      final studentIds = <String>{};
      for (final r in rows) {
        final map = r as Map;
        final sid = map['student_id']?.toString();
        if (sid != null && sid.isNotEmpty) studentIds.add(sid);
      }

      final studentNames = <String, String>{};
      if (studentIds.isNotEmpty) {
        try {
          final profiles = await client
              .from('profiles')
              .select('id, name')
              .inFilter('id', studentIds.toList());
          for (final p in profiles) {
            final m = p as Map;
            final id = m['id']?.toString();
            if (id == null) continue;
            studentNames[id] = (m['name'] as String?) ?? 'Student';
          }
        } catch (_) {}
      }

      final items = rows.map((r) {
        final map = r as Map;
        final createdAt = map['created_at']?.toString() ?? '';
        final respondedAt = map['responded_at']?.toString();
        final studentId = map['student_id']?.toString() ?? '';
        final respondedById = map['responded_by']?.toString();
        final statusDb = (map['status'] as String?) ?? 'pending';

        return _ServantComplaint(
          id: map['id'] as String,
          studentId: studentId,
          studentName: studentNames[studentId] ?? 'Student',
          category: (map['category'] as String?) ?? 'other',
          complaint: (map['complaint'] as String?) ?? '',
          date: createdAt.isNotEmpty ? _dateOnly(createdAt) : _todayIso(),
          status: _complaintStatusFromDb(statusDb),
          response: map['response'] as String?,
          respondedBy: respondedById == null
              ? null
              : (respondedById == userId ? 'You' : 'Servant'),
          respondedDate: respondedAt == null ? null : _dateOnly(respondedAt),
        );
      }).toList();

      if (!mounted) return;
      setState(() {
        _complaints
          ..clear()
          ..addAll(items);
        _respondingComplaintId = null;
        _complaintNextStatus.clear();
      });
    } catch (_) {
      // Keep mock data on any error.
    }
  }

  Future<bool> _updateComplaintInBackend({
    required String complaintId,
    required String reply,
    required String newStatusUi,
  }) async {
    final client = SupabaseClientManager.instance.client;
    final userId = client.auth.currentUser?.id;
    if (userId == null) return false;

    try {
      await client
          .from('complaints')
          .update({
            'response': reply,
            'status': _complaintStatusToDb(newStatusUi),
            'responded_by': userId,
            'responded_at': DateTime.now().toIso8601String(),
          })
          .eq('id', complaintId);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> _deleteComplaintInBackend(String id) async {
    final client = SupabaseClientManager.instance.client;
    try {
      await client.from('complaints').delete().eq('id', id);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _loadFeedbackFromBackend() async {
    final client = SupabaseClientManager.instance.client;
    final userId = client.auth.currentUser?.id;
    if (userId == null) return;

    try {
      final academicYear = await client
          .from('academic_years')
          .select('id')
          .eq('status', 'active')
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      final profile = await client
          .from('profiles')
          .select('grade_id')
          .eq('id', userId)
          .maybeSingle();

      final activeAcademicYearId = academicYear?['id'] as String?;
      final myGradeId = profile?['grade_id'] as String?;

      var query = client
          .from('feedback_forms')
          .select(
            'id, title, description, type_label, start_date, end_date, created_at, created_by, academic_year_id, grade_id, feedback_questions(id, position, type, question, required, options)',
          );

      if (activeAcademicYearId != null) {
        query = query.eq('academic_year_id', activeAcademicYearId);
      }
      if (myGradeId != null) {
        query = query.eq('grade_id', myGradeId);
      }

      final formsRaw = await query.order('created_at', ascending: false);
      final forms = <_ServantFeedbackForm>[];
      final counts = <String, int>{};

      for (final row in formsRaw) {
        final formId = row['id'] as String;
        final questionsRaw =
            (row['feedback_questions'] as List<dynamic>? ?? const []);

        questionsRaw.sort((a, b) {
          final pa = (a as Map)['position'] as int? ?? 0;
          final pb = (b as Map)['position'] as int? ?? 0;
          return pa.compareTo(pb);
        });

        final questions = questionsRaw.map((q) {
          final map = q as Map;
          final optionsRaw = map['options'];
          final options = optionsRaw is List
              ? optionsRaw.whereType<String>().toList()
              : const <String>[];

          return _ServantFeedbackQuestion(
            id: map['id'] as String,
            question: (map['question'] as String?) ?? '',
            type: (map['type'] as String?) ?? 'text',
            required: (map['required'] as bool?) ?? true,
            options: options,
          );
        }).toList();

        final createdAt = row['created_at']?.toString() ?? '';
        final createdDate = createdAt.isNotEmpty
            ? createdAt.substring(0, 10)
            : _todayIso();

        final createdById = row['created_by']?.toString() ?? '';
        final createdBy = createdById == userId ? 'You' : 'Admin';

        forms.add(
          _ServantFeedbackForm(
            id: formId,
            title: (row['title'] as String?) ?? '',
            description: (row['description'] as String?) ?? '',
            type: (row['type_label'] as String?) ?? 'general',
            createdBy: createdBy,
            createdDate: createdDate,
            startDate: (row['start_date'] as String?) ?? _todayIso(),
            endDate: (row['end_date'] as String?) ?? _todayIso(),
            status: 'active',
            targetStudents: const ['all'],
            questions: questions,
          ),
        );

        try {
          final submissions = await client
              .from('feedback_submissions')
              .select('id')
              .eq('form_id', formId);
          counts[formId] = submissions.length;
        } catch (_) {
          // Keep existing (mock) counts if RLS blocks count.
        }
      }

      if (!mounted) return;
      setState(() {
        _activeAcademicYearId = activeAcademicYearId;
        _myGradeId = myGradeId;
        if (forms.isNotEmpty) {
          _feedbackForms
            ..clear()
            ..addAll(forms);
        }
        _feedbackSubmissionCounts
          ..clear()
          ..addAll(counts);
      });
    } catch (_) {
      // Keep mock data on any error.
    }
  }

  Future<void> _loadFeedbackResponsesForForm(String formId) async {
    final client = SupabaseClientManager.instance.client;
    try {
      final rows = await client
          .from('feedback_submissions')
          .select('id, student_id, submitted_at, answers')
          .eq('form_id', formId)
          .order('submitted_at', ascending: false);

      final responses = rows.map((r) {
        final map = r as Map;
        final answersDynamic = map['answers'];
        final answers = answersDynamic is Map<String, dynamic>
            ? answersDynamic
            : <String, Object?>{};

        final submittedAt = map['submitted_at']?.toString() ?? '';
        final submittedDate = submittedAt.isNotEmpty
            ? submittedAt.substring(0, 10)
            : _todayIso();

        return _ServantFeedbackResponse(
          id: map['id'] as String,
          formId: formId,
          studentId: map['student_id']?.toString() ?? '',
          studentName: 'Student',
          submittedDate: submittedDate,
          answers: answers,
        );
      }).toList();

      if (!mounted) return;
      setState(() {
        _feedbackResponses.removeWhere((r) => r.formId == formId);
        _feedbackResponses.addAll(responses);
        _feedbackSubmissionCounts[formId] = responses.length;
      });
    } catch (_) {
      // Leave existing mock responses.
    }
  }

  Future<_ServantFeedbackForm?> _createFeedbackFormInBackend({
    required String title,
    required String description,
    required String typeLabel,
    required String startDateIso,
    required String endDateIso,
    required List<_ServantFeedbackQuestion> questions,
  }) async {
    final client = SupabaseClientManager.instance.client;
    final userId = client.auth.currentUser?.id;
    if (userId == null) return null;

    final academicYearId = _activeAcademicYearId;
    final gradeId = _myGradeId;
    if (academicYearId == null || gradeId == null) {
      return null;
    }

    final inserted = await client
        .from('feedback_forms')
        .insert({
          'academic_year_id': academicYearId,
          'grade_id': gradeId,
          'created_by': userId,
          'type_label': typeLabel,
          'title': title,
          'description': description,
          'start_date': startDateIso,
          'end_date': endDateIso,
        })
        .select(
          'id, title, description, type_label, start_date, end_date, created_at, created_by',
        )
        .single();

    final formId = inserted['id'] as String;

    if (questions.isNotEmpty) {
      await client
          .from('feedback_questions')
          .insert(
            questions.asMap().entries.map((e) {
              final q = e.value;
              return {
                'form_id': formId,
                'position': e.key + 1,
                'type': q.type,
                'question': q.question,
                'required': q.required,
                'options': q.options.isEmpty ? null : q.options,
              };
            }).toList(),
          );
    }

    final createdAt = inserted['created_at']?.toString() ?? '';
    final createdDate = createdAt.isNotEmpty
        ? createdAt.substring(0, 10)
        : _todayIso();

    return _ServantFeedbackForm(
      id: formId,
      title: inserted['title'] as String,
      description: inserted['description'] as String,
      type: inserted['type_label'] as String,
      createdBy: 'You',
      createdDate: createdDate,
      startDate: inserted['start_date'] as String,
      endDate: inserted['end_date'] as String,
      status: 'active',
      targetStudents: const ['all'],
      questions: questions,
    );
  }

  int get _pendingQuestionsCount => _questions.where((q) => !q.answered).length;

  int get _pendingComplaintsCount =>
      _complaints.where((c) => c.status == 'pending').length;

  TextEditingController _questionControllerFor(String questionId) {
    return _questionReplyControllers.putIfAbsent(
      questionId,
      () => TextEditingController(),
    );
  }

  TextEditingController _complaintControllerFor(String complaintId) {
    return _complaintReplyControllers.putIfAbsent(
      complaintId,
      () => TextEditingController(),
    );
  }

  Future<bool> _confirmDelete({
    required BuildContext context,
    required String title,
    required String message,
    required String confirmLabel,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text(confirmLabel),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  void _resetInlineEditors() {
    _respondingQuestionId = null;
    _respondingComplaintId = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(color: Color(0xFFE2E8F0)),
                    ),
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
                      const SizedBox(height: 6),
                      const Text(
                        'Announcements, questions, complaints, and feedback.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _ServantCommTabButton(
                              label: 'Announcements',
                              icon: Icons.campaign_rounded,
                              selected:
                                  _activeTab == _ServantCommTab.announcements,
                              onTap: () {
                                setState(() {
                                  _activeTab = _ServantCommTab.announcements;
                                  _resetInlineEditors();
                                  _showAnnouncementForm = false;
                                  _showCreateFeedback = false;
                                  _viewingFeedbackFormId = null;
                                });
                              },
                            ),
                            _ServantCommTabButton(
                              label: 'Questions',
                              icon: Icons.question_answer_rounded,
                              selected: _activeTab == _ServantCommTab.questions,
                              badgeCount: _pendingQuestionsCount,
                              badgeStyle: _ServantBadgeStyle.amber,
                              onTap: () {
                                setState(() {
                                  _activeTab = _ServantCommTab.questions;
                                  _resetInlineEditors();
                                  _showAnnouncementForm = false;
                                  _showCreateFeedback = false;
                                  _viewingFeedbackFormId = null;
                                });
                              },
                            ),
                            _ServantCommTabButton(
                              label: 'Complaints',
                              icon: Icons.report_problem_rounded,
                              selected:
                                  _activeTab == _ServantCommTab.complaints,
                              badgeCount: _pendingComplaintsCount,
                              badgeStyle: _ServantBadgeStyle.red,
                              onTap: () {
                                setState(() {
                                  _activeTab = _ServantCommTab.complaints;
                                  _resetInlineEditors();
                                  _showAnnouncementForm = false;
                                  _showCreateFeedback = false;
                                  _viewingFeedbackFormId = null;
                                });
                              },
                            ),
                            _ServantCommTabButton(
                              label: 'Feedback',
                              icon: Icons.fact_check_rounded,
                              selected: _activeTab == _ServantCommTab.feedback,
                              onTap: () {
                                setState(() {
                                  _activeTab = _ServantCommTab.feedback;
                                  _resetInlineEditors();
                                  _showAnnouncementForm = false;
                                  _showCreateFeedback = false;
                                  _viewingFeedbackFormId = null;
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
                          case _ServantCommTab.announcements:
                            return _buildAnnouncements();
                          case _ServantCommTab.questions:
                            return _buildQuestions();
                          case _ServantCommTab.complaints:
                            return _buildComplaints();
                          case _ServantCommTab.feedback:
                            return _buildFeedback();
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
            if (_showFeedbackSuccessToast)
              Positioned(
                top: 12,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF22C55E),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x22374151),
                          blurRadius: 14,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Feedback form created successfully!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14374151),
            blurRadius: 12,
            offset: Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: child,
    );
  }

  Widget _buildAnnouncements() {
    const maxTitleChars = 100;
    const maxMessageChars = 500;

    String categoryEmoji(String category) {
      switch (category) {
        case 'urgent':
          return '🚨';
        case 'grades':
          return '📊';
        case 'schedule':
          return '📅';
        case 'event':
          return '🎉';
        case 'general':
        default:
          return '📢';
      }
    }

    String categoryLabel(String category) {
      switch (category) {
        case 'urgent':
          return 'Urgent';
        case 'grades':
          return 'Grades';
        case 'schedule':
          return 'Schedule';
        case 'event':
          return 'Event';
        case 'general':
        default:
          return 'General';
      }
    }

    ({Color bg, Color fg}) categoryColors(String category) {
      switch (category) {
        case 'urgent':
          return (bg: const Color(0xFFFEE2E2), fg: const Color(0xFFB91C1C));
        case 'grades':
          return (bg: const Color(0xFFFEF3C7), fg: const Color(0xFF92400E));
        case 'schedule':
          return (bg: const Color(0xFFDBEAFE), fg: const Color(0xFF1D4ED8));
        case 'event':
          return (bg: const Color(0xFFD1FAE5), fg: const Color(0xFF047857));
        case 'general':
        default:
          return (bg: const Color(0xFFF1F5F9), fg: const Color(0xFF475569));
      }
    }

    Widget categoryChip(String category) {
      final colors = categoryColors(category);
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: colors.bg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: colors.fg.withValues(alpha: 0.25)),
        ),
        child: Text(
          categoryLabel(category),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: colors.fg,
          ),
        ),
      );
    }

    Future<void> postAnnouncement() async {
      final title = _announcementTitleController.text.trim();
      final message = _announcementMessageController.text.trim();
      if (title.isEmpty || message.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a title and message.')),
        );
        return;
      }

      _ServantAnnouncement? created;
      try {
        created = await _createAnnouncementInBackend(
          title: title,
          message: message,
          category: _announcementCategory,
          priority: _announcementPriority,
          targetAudience: _announcementTargetAudience,
          expiresOnIso: null,
        );
      } catch (_) {}

      if (!mounted) return;

      setState(() {
        _announcements.insert(
          0,
          created ??
              _ServantAnnouncement(
                id: 'a${DateTime.now().millisecondsSinceEpoch}',
                title: title,
                message: message,
                category: _announcementCategory,
                createdBy: 'You',
                createdDate: _todayIso(),
                priority: _announcementPriority,
                targetAudience: _announcementTargetAudience,
                expiresOn: null,
              ),
        );
        _announcementTitleController.clear();
        _announcementMessageController.clear();
        _announcementExpiresOn = null;
        _showAnnouncementForm = false;
      });

      if (created == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Announcement saved locally (sync failed).'),
          ),
        );
      }
    }

    void cancelAnnouncement() {
      setState(() {
        _announcementTitleController.clear();
        _announcementMessageController.clear();
        _announcementExpiresOn = null;
        _showAnnouncementForm = false;
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!_showAnnouncementForm)
          SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _showAnnouncementForm = true;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF59E0B),
                foregroundColor: Colors.white,
                elevation: 1,
                shadowColor: const Color(0x14374151),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.add_rounded, size: 20),
              label: const Text(
                'Create Announcement',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        if (_showAnnouncementForm) ...[
          _buildSectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Create Announcement',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: cancelAnnouncement,
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                _ServantLabeledField(
                  label: 'Category',
                  child: DropdownButtonFormField<String>(
                    initialValue: _announcementCategory,
                    decoration: _inputDecoration('Select category'),
                    items:
                        const [
                          'general',
                          'grades',
                          'schedule',
                          'event',
                          'urgent',
                        ].map((c) {
                          return DropdownMenuItem<String>(
                            value: c,
                            child: Text(
                              '${categoryEmoji(c)} ${categoryLabel(c)}',
                            ),
                          );
                        }).toList(),
                    onChanged: (v) {
                      if (v == null) return;
                      setState(() => _announcementCategory = v);
                    },
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Title',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF334155),
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _announcementTitleController,
                  maxLength: maxTitleChars,
                  buildCounter:
                      (
                        context, {
                        required currentLength,
                        required isFocused,
                        maxLength,
                      }) => null,
                  decoration: _inputDecoration(
                    'Brief title for the announcement',
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '${_announcementTitleController.text.characters.length}/$maxTitleChars',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Message',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF334155),
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _announcementMessageController,
                  minLines: 5,
                  maxLines: 8,
                  maxLength: maxMessageChars,
                  buildCounter:
                      (
                        context, {
                        required currentLength,
                        required isFocused,
                        maxLength,
                      }) => null,
                  decoration: _inputDecoration(
                    'Write your announcement message here...',
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '${_announcementMessageController.text.characters.length}/$maxMessageChars',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: postAnnouncement,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF59E0B),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.send_rounded, size: 18),
                        label: const Text(
                          'Post Announcement',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton(
                      onPressed: cancelAnnouncement,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF334155),
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 18,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
        if (!_showAnnouncementForm) ...[
          const SizedBox(height: 14),
          if (_announcements.isEmpty)
            _ServantEmptyState(
              icon: Icons.campaign_rounded,
              title: 'No announcements yet',
              subtitle: 'Create one to notify students.',
            )
          else
            Column(
              children: _announcements.map((a) {
                final expanded = _expandedAnnouncementId == a.id;
                final dateLabel = EthiopianDateFormatter.formatFlexible(
                  a.createdDate,
                );

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x14374151),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          setState(() {
                            _expandedAnnouncementId = expanded ? null : a.id;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Stack(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 34),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      categoryEmoji(a.category),
                                      style: const TextStyle(fontSize: 22),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            a.title,
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFF0F172A),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Wrap(
                                            spacing: 8,
                                            runSpacing: 8,
                                            crossAxisAlignment:
                                                WrapCrossAlignment.center,
                                            children: [
                                              categoryChip(a.category),
                                              Text(
                                                dateLabel,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Color(0xFF64748B),
                                                ),
                                              ),
                                              const Text(
                                                '0/0 read',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Color(0xFF0284C7),
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                          if (!expanded) ...[
                                            const SizedBox(height: 10),
                                            Text(
                                              a.message,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 13,
                                                color: Color(0xFF475569),
                                                height: 1.35,
                                              ),
                                            ),
                                          ],
                                          if (expanded) ...[
                                            const SizedBox(height: 12),
                                            const Divider(
                                              height: 1,
                                              color: Color(0xFFE2E8F0),
                                            ),
                                            const SizedBox(height: 12),
                                            Text(
                                              a.message,
                                              style: const TextStyle(
                                                fontSize: 13,
                                                color: Color(0xFF334155),
                                                height: 1.35,
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            Row(
                                              children: [
                                                Text(
                                                  'Target: ${a.targetAudience}',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Color(0xFF64748B),
                                                  ),
                                                ),
                                                const Spacer(),
                                                const Text(
                                                  '0 students have read this',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Color(0xFF64748B),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Positioned(
                                top: -6,
                                right: -6,
                                child: IconButton(
                                  onPressed: () async {
                                    final ok = await _confirmDelete(
                                      context: context,
                                      title: 'Delete announcement?',
                                      message:
                                          'This will permanently remove this announcement.',
                                      confirmLabel: 'Delete',
                                    );
                                    if (!ok) return;

                                    final deleted =
                                        await _deleteAnnouncementInBackend(
                                          a.id,
                                        );
                                    if (!mounted) return;

                                    if (!deleted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Could not delete from server.',
                                          ),
                                        ),
                                      );
                                      return;
                                    }

                                    setState(() {
                                      _announcements.removeWhere(
                                        (x) => x.id == a.id,
                                      );
                                      if (_expandedAnnouncementId == a.id) {
                                        _expandedAnnouncementId = null;
                                      }
                                    });
                                  },
                                  icon: const Icon(
                                    Icons.delete_outline_rounded,
                                    color: Color(0xFFEF4444),
                                    size: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ],
    );
  }

  Widget _buildQuestions() {
    final subjects = <String>{..._questions.map((q) => q.subjectName)}.toList()
      ..sort();

    Widget statusChip({required String label, required String value}) {
      final selected = _questionStatusFilter == value;
      return Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () {
            setState(() {
              _questionStatusFilter = value;
              _respondingQuestionId = null;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: selected
                  ? const Color(0xFFF59E0B)
                  : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : const Color(0xFF334155),
              ),
            ),
          ),
        ),
      );
    }

    Iterable<_ServantQuestion> items = _questions;
    if (_questionStatusFilter == 'pending') {
      items = items.where((q) => !q.answered);
    } else if (_questionStatusFilter == 'answered') {
      items = items.where((q) => q.answered);
    }
    if (_questionSubjectFilter != 'all') {
      items = items.where((q) => q.subjectName == _questionSubjectFilter);
    }

    final list = items.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Questions',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  statusChip(label: 'All', value: 'all'),
                  statusChip(label: 'Pending', value: 'pending'),
                  statusChip(label: 'Answered', value: 'answered'),
                ],
              ),
              const SizedBox(height: 12),
              _ServantLabeledField(
                label: 'Subject',
                child: _ServantDropdown(
                  value: _questionSubjectFilter,
                  items: ['all', ...subjects],
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() {
                      _questionSubjectFilter = v;
                      _respondingQuestionId = null;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        if (list.isEmpty)
          _ServantEmptyState(
            icon: Icons.question_answer_rounded,
            title: 'No questions',
            subtitle: 'Try changing the filters.',
          )
        else
          Column(
            children: list.map((q) {
              final isExpanded = _respondingQuestionId == q.id;
              final isPending = !q.answered;
              final statusPill = q.answered
                  ? _tinyPill(
                      label: 'Answered',
                      bg: const Color(0xFFD1FAE5),
                      fg: const Color(0xFF047857),
                    )
                  : _tinyPill(
                      label: 'Pending',
                      bg: const Color(0xFFFEF3C7),
                      fg: const Color(0xFF92400E),
                    );
              final dateLabel = EthiopianDateFormatter.formatFlexible(q.date);

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isPending
                          ? const Color(0xFFFDE68A)
                          : Colors.transparent,
                      width: 2,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x14374151),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 34),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  _tinyPill(
                                    label: q.subjectName,
                                    bg: const Color(0xFFE0F2FE),
                                    fg: const Color(0xFF0369A1),
                                  ),
                                  const Spacer(),
                                  statusPill,
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                q.studentName,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF64748B),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                q.question,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              if (q.answered && q.answer != null && !isExpanded)
                                Padding(
                                  padding: const EdgeInsets.only(top: 12),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFFD1FAE5,
                                      ).withValues(alpha: 0.35),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: const Color(0xFFD1FAE5),
                                      ),
                                    ),
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Your Response:',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Color(0xFF047857),
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          q.answer!,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Color(0xFF334155),
                                            height: 1.35,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              if (isPending && !isExpanded)
                                Padding(
                                  padding: const EdgeInsets.only(top: 12),
                                  child: SizedBox(
                                    height: 40,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          _respondingQuestionId = q.id;
                                        });
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFFF59E0B,
                                        ),
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                      ),
                                      child: const Text(
                                        'Respond',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              if (isPending && isExpanded) ...[
                                const SizedBox(height: 12),
                                TextField(
                                  controller: _questionControllerFor(q.id),
                                  minLines: 3,
                                  maxLines: 6,
                                  decoration: _inputDecoration(
                                    'Type your response...',
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () async {
                                          final reply = _questionControllerFor(
                                            q.id,
                                          ).text.trim();
                                          if (reply.isEmpty) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Please enter a response.',
                                                ),
                                              ),
                                            );
                                            return;
                                          }

                                          final saved =
                                              await _answerQuestionInBackend(
                                                questionId: q.id,
                                                reply: reply,
                                              );
                                          if (!mounted) return;

                                          setState(() {
                                            final index = _questions.indexWhere(
                                              (x) => x.id == q.id,
                                            );
                                            if (index != -1) {
                                              _questions[index] =
                                                  _questions[index].copyWith(
                                                    answered: true,
                                                    answer: reply,
                                                    answeredBy: 'You',
                                                    answeredDate: _todayIso(),
                                                  );
                                            }
                                            _questionControllerFor(
                                              q.id,
                                            ).clear();
                                            _respondingQuestionId = null;
                                          });

                                          if (!saved) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Response saved locally (sync failed).',
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xFFF59E0B,
                                          ),
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 10,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                        ),
                                        icon: const Icon(
                                          Icons.send_rounded,
                                          size: 16,
                                        ),
                                        label: const Text(
                                          'Send Response',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    OutlinedButton(
                                      onPressed: () {
                                        setState(() {
                                          _respondingQuestionId = null;
                                        });
                                      },
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: const Color(
                                          0xFF334155,
                                        ),
                                        side: const BorderSide(
                                          color: Color(0xFFE2E8F0),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 10,
                                          horizontal: 14,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                      ),
                                      child: const Text(
                                        'Cancel',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              const SizedBox(height: 10),
                              Text(
                                dateLabel,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF94A3B8),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          top: -6,
                          right: -6,
                          child: IconButton(
                            onPressed: () async {
                              final ok = await _confirmDelete(
                                context: context,
                                title: 'Delete question?',
                                message:
                                    'This will permanently remove this question.',
                                confirmLabel: 'Delete',
                              );
                              if (!ok) return;

                              final deleted = await _deleteQuestionInBackend(
                                q.id,
                              );
                              if (!mounted) return;

                              if (!deleted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'You may not have permission to delete questions.',
                                    ),
                                  ),
                                );
                                return;
                              }

                              setState(() {
                                _questions.removeWhere((x) => x.id == q.id);
                                if (_respondingQuestionId == q.id) {
                                  _respondingQuestionId = null;
                                }
                              });
                            },
                            icon: const Icon(
                              Icons.delete_outline_rounded,
                              color: Color(0xFFEF4444),
                              size: 18,
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
    );
  }

  Widget _buildComplaints() {
    Widget statusChip({required String label, required String value}) {
      final selected = _complaintStatusFilter == value;
      return Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () {
            setState(() {
              _complaintStatusFilter = value;
              _respondingComplaintId = null;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: selected
                  ? const Color(0xFFF59E0B)
                  : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : const Color(0xFF334155),
              ),
            ),
          ),
        ),
      );
    }

    Iterable<_ServantComplaint> items = _complaints;
    if (_complaintStatusFilter != 'all') {
      items = items.where((c) => c.status == _complaintStatusFilter);
    }
    if (_complaintCategoryFilter != 'all') {
      items = items.where((c) => c.category == _complaintCategoryFilter);
    }

    final list = items.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Complaints',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    statusChip(label: 'All', value: 'all'),
                    const SizedBox(width: 8),
                    statusChip(label: 'Pending', value: 'pending'),
                    const SizedBox(width: 8),
                    statusChip(label: 'In Review', value: 'in-review'),
                    const SizedBox(width: 8),
                    statusChip(label: 'Resolved', value: 'resolved'),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _ServantLabeledField(
                label: 'Category',
                child: _ServantDropdown(
                  value: _complaintCategoryFilter,
                  items: const [
                    'all',
                    'teaching',
                    'facility',
                    'administration',
                    'other',
                  ],
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() {
                      _complaintCategoryFilter = v;
                      _respondingComplaintId = null;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        if (list.isEmpty)
          _ServantEmptyState(
            icon: Icons.report_problem_rounded,
            title: 'No complaints',
            subtitle: 'Try changing the filters.',
          )
        else
          Column(
            children: list.map((c) {
              final isExpanded = _respondingComplaintId == c.id;
              final canRespond = c.status != 'resolved';
              final nextStatus =
                  _complaintNextStatus[c.id] ??
                  (c.status == 'pending' ? 'in-review' : c.status);

              final statusPill = _statusBadge(c.status);
              final categoryPill = _categoryBadge(c.category);
              final dateLabel = EthiopianDateFormatter.formatFlexible(c.date);
              final highlight = c.status != 'resolved';

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: highlight
                          ? const Color(0xFFFECACA)
                          : Colors.transparent,
                      width: 2,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x14374151),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 34),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  categoryPill,
                                  const Spacer(),
                                  statusPill,
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                c.studentName,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF64748B),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                c.complaint,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF0F172A),
                                  height: 1.35,
                                ),
                              ),
                              if (c.response != null && !isExpanded)
                                Padding(
                                  padding: const EdgeInsets.only(top: 12),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFFD1FAE5,
                                      ).withValues(alpha: 0.35),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: const Color(0xFFD1FAE5),
                                      ),
                                    ),
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Response:',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Color(0xFF047857),
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          c.response!,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Color(0xFF334155),
                                            height: 1.35,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              if (!isExpanded && canRespond)
                                Padding(
                                  padding: const EdgeInsets.only(top: 12),
                                  child: SizedBox(
                                    height: 40,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          _respondingComplaintId = c.id;
                                          _complaintNextStatus.putIfAbsent(
                                            c.id,
                                            () => c.status == 'pending'
                                                ? 'in-review'
                                                : c.status,
                                          );
                                        });
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFFF59E0B,
                                        ),
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                      ),
                                      child: const Text(
                                        'Respond',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              if (isExpanded && canRespond) ...[
                                const SizedBox(height: 12),
                                _ServantLabeledField(
                                  label: 'Status',
                                  child: _ServantDropdown(
                                    value: nextStatus,
                                    items: const [
                                      'pending',
                                      'in-review',
                                      'resolved',
                                    ],
                                    onChanged: (v) {
                                      if (v == null) return;
                                      setState(() {
                                        _complaintNextStatus[c.id] = v;
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(height: 12),
                                TextField(
                                  controller: _complaintControllerFor(c.id),
                                  minLines: 3,
                                  maxLines: 6,
                                  decoration: _inputDecoration(
                                    'Type your response...',
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () async {
                                          final reply = _complaintControllerFor(
                                            c.id,
                                          ).text.trim();
                                          if (reply.isEmpty) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Please enter a response.',
                                                ),
                                              ),
                                            );
                                            return;
                                          }

                                          final newStatus =
                                              _complaintNextStatus[c.id] ??
                                              c.status;

                                          final saved =
                                              await _updateComplaintInBackend(
                                                complaintId: c.id,
                                                reply: reply,
                                                newStatusUi: newStatus,
                                              );
                                          if (!mounted) return;

                                          setState(() {
                                            final index = _complaints
                                                .indexWhere(
                                                  (x) => x.id == c.id,
                                                );
                                            if (index != -1) {
                                              _complaints[index] =
                                                  _complaints[index].copyWith(
                                                    response: reply,
                                                    respondedBy: 'You',
                                                    respondedDate: _todayIso(),
                                                    status: newStatus,
                                                  );
                                            }
                                            _complaintControllerFor(
                                              c.id,
                                            ).clear();
                                            _respondingComplaintId = null;
                                          });

                                          if (!saved) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Update saved locally (sync failed).',
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xFFF59E0B,
                                          ),
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 10,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                        ),
                                        icon: const Icon(
                                          Icons.send_rounded,
                                          size: 16,
                                        ),
                                        label: const Text(
                                          'Update',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    OutlinedButton(
                                      onPressed: () {
                                        setState(() {
                                          _respondingComplaintId = null;
                                        });
                                      },
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: const Color(
                                          0xFF334155,
                                        ),
                                        side: const BorderSide(
                                          color: Color(0xFFE2E8F0),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 10,
                                          horizontal: 14,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                      ),
                                      child: const Text(
                                        'Cancel',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              const SizedBox(height: 10),
                              Text(
                                dateLabel,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF94A3B8),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          top: -6,
                          right: -6,
                          child: IconButton(
                            onPressed: () async {
                              final ok = await _confirmDelete(
                                context: context,
                                title: 'Delete complaint?',
                                message:
                                    'This will permanently remove this complaint.',
                                confirmLabel: 'Delete',
                              );
                              if (!ok) return;

                              final deleted = await _deleteComplaintInBackend(
                                c.id,
                              );
                              if (!mounted) return;

                              if (!deleted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Could not delete from server.',
                                    ),
                                  ),
                                );
                                return;
                              }

                              setState(() {
                                _complaints.removeWhere((x) => x.id == c.id);
                                _complaintReplyControllers
                                    .remove(c.id)
                                    ?.dispose();
                                _complaintNextStatus.remove(c.id);
                                if (_respondingComplaintId == c.id) {
                                  _respondingComplaintId = null;
                                }
                              });
                            },
                            icon: const Icon(
                              Icons.delete_outline_rounded,
                              color: Color(0xFFEF4444),
                              size: 18,
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
    );
  }

  Widget _buildFeedback() {
    if (_showCreateFeedback) {
      return _buildCreateFeedbackForm();
    }
    if (_viewingFeedbackFormId != null) {
      return _buildFeedbackAnalytics(_viewingFeedbackFormId!);
    }
    return _buildFeedbackTab();
  }

  _SubmissionRate _submissionRateFor(_ServantFeedbackForm form) {
    final total =
        form.targetStudents.isNotEmpty && form.targetStudents.first == 'all'
        ? _mockTotalStudents
        : form.targetStudents.length;
    final submitted =
        _feedbackSubmissionCounts[form.id] ??
        _feedbackResponses.where((r) => r.formId == form.id).length;
    final percentage = total == 0 ? 0 : ((submitted / total) * 100).round();
    return _SubmissionRate(
      submitted: submitted,
      total: total,
      percentage: percentage,
    );
  }

  bool _isExpired(String endDateIso) {
    final end = DateTime.tryParse(endDateIso);
    if (end == null) return false;
    final now = DateTime.now();
    return end.isBefore(DateTime(now.year, now.month, now.day));
  }

  void _resetCreateFeedbackDraft() {
    _feedbackTitleController.clear();
    _feedbackDescriptionController.clear();
    _feedbackType = '';
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 14));
    _feedbackStartDate = _isoFromDate(start);
    _feedbackEndDate = _isoFromDate(end);
    _draftFeedbackQuestions.clear();
    _showAddFeedbackQuestion = false;
    _draftQuestionTextController.clear();
    _draftQuestionType = 'rating';
    _draftQuestionRequired = true;
    for (final c in _draftOptionControllers) {
      c.dispose();
    }
    _draftOptionControllers
      ..clear()
      ..add(TextEditingController());
  }

  static String _feedbackTypeLabel(String type) {
    switch (type) {
      case 'teacher_evaluation':
        return 'Teacher Evaluation';
      case 'course_evaluation':
        return 'Course Evaluation';
      case 'semester_evaluation':
        return 'Semester Evaluation';
      case 'general':
        return 'General';
      default:
        return type.replaceAll('_', ' ');
    }
  }

  static String _isoFromDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  Future<void> _pickFeedbackType() async {
    final types = const [
      'teacher_evaluation',
      'course_evaluation',
      'semester_evaluation',
      'general',
    ];

    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                child: const Text(
                  'Select type',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF334155),
                  ),
                ),
              ),
              ...types.map((t) {
                return ListTile(
                  title: Text(
                    _feedbackTypeLabel(t),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  onTap: () => Navigator.of(context).pop(t),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 18),
                );
              }),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );

    if (selected == null) return;
    setState(() {
      _feedbackType = selected;
    });
  }

  Future<void> _pickFeedbackDate({required bool isStart}) async {
    final currentIso = isStart ? _feedbackStartDate : _feedbackEndDate;
    final parsed = DateTime.tryParse(currentIso);
    final now = DateTime.now();
    final initial = parsed ?? DateTime(now.year, now.month, now.day);

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020, 1, 1),
      lastDate: DateTime(2035, 12, 31),
    );

    if (picked == null) return;
    setState(() {
      final iso = _isoFromDate(picked);
      if (isStart) {
        _feedbackStartDate = iso;
      } else {
        _feedbackEndDate = iso;
      }
    });
  }

  Widget _buildFeedbackTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          onPressed: () {
            setState(() {
              _showCreateFeedback = true;
              _viewingFeedbackFormId = null;
              _resetCreateFeedbackDraft();
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF59E0B),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 2,
          ),
          icon: const Icon(Icons.add_rounded, size: 20),
          label: const Text(
            'Create Feedback Form',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 14),
        if (_feedbackForms.isEmpty)
          const _ServantEmptyState(
            icon: Icons.fact_check_rounded,
            title: 'No feedback forms yet',
            subtitle: 'Create a form to collect student feedback',
          )
        else ...[
          const Text(
            'Active Forms',
            style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 10),
          Column(
            children: _feedbackForms.map((form) {
              final expired = _isExpired(form.endDate);
              final rate = _submissionRateFor(form);

              final statusPill = expired
                  ? _tinyPill(
                      label: 'Expired',
                      bg: const Color(0xFFFEE2E2),
                      fg: const Color(0xFFB91C1C),
                    )
                  : _tinyPill(
                      label: 'Active',
                      bg: const Color(0xFFD1FAE5),
                      fg: const Color(0xFF047857),
                    );

              return Opacity(
                opacity: expired ? 0.75 : 1,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildSectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Row(
                                children: [statusPill, const Spacer()],
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  '${form.questions.length} questions',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                IconButton(
                                  onPressed: () async {
                                    final ok = await _confirmDelete(
                                      context: context,
                                      title: 'Delete Feedback Form?',
                                      message:
                                          'This will permanently delete the form and all ${rate.submitted} student responses. This action cannot be undone.',
                                      confirmLabel: 'Delete',
                                    );
                                    if (!ok) return;
                                    setState(() {
                                      _feedbackForms.removeWhere(
                                        (f) => f.id == form.id,
                                      );
                                      _feedbackResponses.removeWhere(
                                        (r) => r.formId == form.id,
                                      );
                                    });
                                  },
                                  icon: const Icon(
                                    Icons.delete_outline_rounded,
                                    size: 18,
                                    color: Color(0xFFEF4444),
                                  ),
                                  tooltip: 'Delete form',
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(
                                    minWidth: 40,
                                    minHeight: 40,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          form.title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          form.description,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF475569),
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Due: ${EthiopianDateFormatter.formatFlexible(form.endDate)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: expired
                                      ? const Color(0xFFDC2626)
                                      : const Color(0xFF64748B),
                                ),
                              ),
                            ),
                            Text(
                              '${rate.submitted}/${rate.total} responses',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF0284C7),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              _viewingFeedbackFormId = form.id;
                              _showCreateFeedback = false;
                            });
                            _loadFeedbackResponsesForForm(form.id);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0EA5E9),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(
                            Icons.remove_red_eye_rounded,
                            size: 18,
                          ),
                          label: const Text(
                            'View Analytics',
                            style: TextStyle(fontWeight: FontWeight.w600),
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
      ],
    );
  }

  Widget _buildFeedbackListOnly() {
    return _buildFeedbackTab();
  }

  Widget _buildCreateFeedbackForm() {
    InputDecoration feedbackInputDecoration(String hint) {
      return InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF334155)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF334155)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF0EA5E9), width: 2),
        ),
      );
    }

    Widget datePill({
      required String label,
      required String value,
      required VoidCallback onTap,
    }) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFCBD5E1)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              const Icon(
                Icons.calendar_month_rounded,
                size: 18,
                color: Color(0xFF0EA5E9),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0EA5E9),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0369A1),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return _buildSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Create Feedback Form',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 14),
          _ServantLabeledField(
            label: 'Title',
            child: ValueListenableBuilder<TextEditingValue>(
              valueListenable: _feedbackTitleController,
              builder: (context, value, _) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: _feedbackTitleController,
                      maxLength: 100,
                      decoration: feedbackInputDecoration(
                        'e.g., Mid-Semester Teacher Evaluation',
                      ).copyWith(counterText: ''),
                    ),
                    Text(
                      '${value.text.length}/100',
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          _ServantLabeledField(
            label: 'Description',
            child: ValueListenableBuilder<TextEditingValue>(
              valueListenable: _feedbackDescriptionController,
              builder: (context, value, _) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: _feedbackDescriptionController,
                      maxLength: 300,
                      minLines: 3,
                      maxLines: 6,
                      decoration: feedbackInputDecoration(
                        'Brief description of the feedback form',
                      ).copyWith(counterText: ''),
                    ),
                    Text(
                      '${value.text.length}/300',
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          _ServantLabeledField(
            label: 'Type',
            child: InkWell(
              onTap: _pickFeedbackType,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF0EA5E9), width: 2),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _feedbackType.isEmpty
                            ? 'Select type'
                            : _feedbackTypeLabel(_feedbackType),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _feedbackType.isEmpty
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Color(0xFF64748B),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: datePill(
                  label: 'Start:',
                  value: EthiopianDateFormatter.formatFlexible(
                    _feedbackStartDate,
                  ),
                  onTap: () => _pickFeedbackDate(isStart: true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: datePill(
                  label: 'End:',
                  value: EthiopianDateFormatter.formatFlexible(
                    _feedbackEndDate,
                  ),
                  onTap: () => _pickFeedbackDate(isStart: false),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.only(top: 14),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Questions',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${_draftFeedbackQuestions.length} ${_draftFeedbackQuestions.length == 1 ? 'question' : 'questions'} added',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() => _showAddFeedbackQuestion = true);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0EA5E9),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.add_rounded, size: 16),
                      label: const Text(
                        'Add Question',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
                if (_draftFeedbackQuestions.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Column(
                    children: _draftFeedbackQuestions.asMap().entries.map((e) {
                      final index = e.key;
                      final q = e.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: [
                                        _tinyPill(
                                          label: 'Q${index + 1}',
                                          bg: const Color(0xFFFEF3C7),
                                          fg: const Color(0xFF92400E),
                                        ),
                                        _tinyPill(
                                          label: q.type.replaceAll('_', ' '),
                                          bg: const Color(0xFFE2E8F0),
                                          fg: const Color(0xFF475569),
                                        ),
                                        if (q.required)
                                          _tinyPill(
                                            label: 'Required',
                                            bg: const Color(0xFFFEE2E2),
                                            fg: const Color(0xFFB91C1C),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      q.question,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF0F172A),
                                      ),
                                    ),
                                    if (q.type == 'multiple_choice' &&
                                        q.options.isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      ...q.options.map(
                                        (o) => Padding(
                                          padding: const EdgeInsets.only(
                                            left: 10,
                                            bottom: 2,
                                          ),
                                          child: Text(
                                            '• $o',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFF64748B),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    _draftFeedbackQuestions.removeAt(index);
                                  });
                                },
                                icon: const Icon(
                                  Icons.delete_outline_rounded,
                                  size: 18,
                                  color: Color(0xFFEF4444),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
                if (_showAddFeedbackQuestion) ...[
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0F2FE),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFBAE6FD),
                        width: 2,
                      ),
                    ),
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'New Question',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF0C4A6E),
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  _showAddFeedbackQuestion = false;
                                  _draftQuestionTextController.clear();
                                  _draftQuestionType = 'rating';
                                  _draftQuestionRequired = true;
                                  for (final c in _draftOptionControllers) {
                                    c.dispose();
                                  }
                                  _draftOptionControllers
                                    ..clear()
                                    ..add(TextEditingController());
                                });
                              },
                              icon: const Icon(
                                Icons.close_rounded,
                                size: 18,
                                color: Color(0xFF0369A1),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _ServantLabeledField(
                          label: 'Question Text',
                          child: ValueListenableBuilder<TextEditingValue>(
                            valueListenable: _draftQuestionTextController,
                            builder: (context, value, _) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  TextField(
                                    controller: _draftQuestionTextController,
                                    maxLength: 200,
                                    minLines: 2,
                                    maxLines: 4,
                                    decoration: _inputDecoration(
                                      'Enter your question...',
                                    ).copyWith(counterText: ''),
                                  ),
                                  Text(
                                    '${value.text.length}/200',
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF94A3B8),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _ServantLabeledField(
                                label: 'Question Type',
                                child: _ServantDropdown(
                                  value: _draftQuestionType,
                                  items: const [
                                    'rating',
                                    'text',
                                    'multiple_choice',
                                  ],
                                  onChanged: (v) {
                                    if (v == null) return;
                                    setState(() {
                                      _draftQuestionType = v;
                                      if (v != 'multiple_choice') {
                                        for (final c
                                            in _draftOptionControllers) {
                                          c.dispose();
                                        }
                                        _draftOptionControllers
                                          ..clear()
                                          ..add(TextEditingController());
                                      }
                                    });
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _ServantLabeledField(
                                label: 'Required?',
                                child: _ServantDropdown(
                                  value: _draftQuestionRequired ? 'yes' : 'no',
                                  items: const ['yes', 'no'],
                                  onChanged: (v) {
                                    if (v == null) return;
                                    setState(() {
                                      _draftQuestionRequired = v == 'yes';
                                    });
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (_draftQuestionType == 'multiple_choice') ...[
                          const SizedBox(height: 12),
                          const Text(
                            'Options',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF334155),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Column(
                            children: _draftOptionControllers
                                .asMap()
                                .entries
                                .map((e) {
                                  final index = e.key;
                                  final controller = e.value;
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: TextField(
                                            controller: controller,
                                            decoration: _inputDecoration(
                                              'Option ${index + 1}',
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        if (_draftOptionControllers.length > 1)
                                          IconButton(
                                            onPressed: () {
                                              setState(() {
                                                final removed =
                                                    _draftOptionControllers
                                                        .removeAt(index);
                                                removed.dispose();
                                              });
                                            },
                                            icon: const Icon(
                                              Icons.close_rounded,
                                              size: 18,
                                              color: Color(0xFFEF4444),
                                            ),
                                          ),
                                      ],
                                    ),
                                  );
                                })
                                .toList(),
                          ),
                          TextButton.icon(
                            onPressed: () {
                              setState(() {
                                _draftOptionControllers.add(
                                  TextEditingController(),
                                );
                              });
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFF0284C7),
                              padding: EdgeInsets.zero,
                            ),
                            icon: const Icon(Icons.add_rounded, size: 16),
                            label: const Text(
                              'Add Option',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  final text = _draftQuestionTextController.text
                                      .trim();
                                  if (text.isEmpty) return;

                                  final options =
                                      _draftQuestionType == 'multiple_choice'
                                      ? _draftOptionControllers
                                            .map((c) => c.text.trim())
                                            .where((o) => o.isNotEmpty)
                                            .toList()
                                      : <String>[];

                                  if (_draftQuestionType == 'multiple_choice' &&
                                      options.length < 2) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Multiple choice questions need at least 2 options.',
                                        ),
                                      ),
                                    );
                                    return;
                                  }

                                  setState(() {
                                    _draftFeedbackQuestions.add(
                                      _DraftFeedbackQuestion(
                                        id: DateTime.now()
                                            .millisecondsSinceEpoch
                                            .toString(),
                                        question: text,
                                        type: _draftQuestionType,
                                        required: _draftQuestionRequired,
                                        options: options,
                                      ),
                                    );
                                    _draftQuestionTextController.clear();
                                    _draftQuestionType = 'rating';
                                    _draftQuestionRequired = true;
                                    for (final c in _draftOptionControllers) {
                                      c.dispose();
                                    }
                                    _draftOptionControllers
                                      ..clear()
                                      ..add(TextEditingController());
                                    _showAddFeedbackQuestion = false;
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0EA5E9),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'Add Question',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            OutlinedButton(
                              onPressed: () {
                                setState(() {
                                  _showAddFeedbackQuestion = false;
                                  _draftQuestionTextController.clear();
                                  _draftQuestionType = 'rating';
                                  _draftQuestionRequired = true;
                                  for (final c in _draftOptionControllers) {
                                    c.clear();
                                  }
                                });
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF334155),
                                side: const BorderSide(
                                  color: Color(0xFFE2E8F0),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Cancel',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    final title = _feedbackTitleController.text.trim();
                    final desc = _feedbackDescriptionController.text.trim();
                    if (title.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter a title.')),
                      );
                      return;
                    }
                    if (desc.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter a description.'),
                        ),
                      );
                      return;
                    }
                    if (_draftFeedbackQuestions.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Please add at least one question to the feedback form.',
                          ),
                        ),
                      );
                      return;
                    }

                    final start = DateTime.tryParse(_feedbackStartDate);
                    final end = DateTime.tryParse(_feedbackEndDate);
                    if (start == null || end == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Please enter valid start and end dates (YYYY-MM-DD).',
                          ),
                        ),
                      );
                      return;
                    }
                    if (!end.isAfter(start)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('End date must be after start date.'),
                        ),
                      );
                      return;
                    }
                    if (_feedbackType.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please select a type.')),
                      );
                      return;
                    }

                    final questions = _draftFeedbackQuestions
                        .asMap()
                        .entries
                        .map(
                          (e) => _ServantFeedbackQuestion(
                            id: 'q${e.key + 1}',
                            question: e.value.question,
                            type: e.value.type,
                            required: e.value.required,
                            options: e.value.options,
                          ),
                        )
                        .toList();

                    _ServantFeedbackForm? created;
                    try {
                      created = await _createFeedbackFormInBackend(
                        title: title,
                        description: desc,
                        typeLabel: _feedbackType,
                        startDateIso: _feedbackStartDate,
                        endDateIso: _feedbackEndDate,
                        questions: questions,
                      );
                    } catch (_) {
                      created = null;
                    }

                    if (!mounted) return;
                    setState(() {
                      _feedbackForms.insert(
                        0,
                        created ??
                            _ServantFeedbackForm(
                              id: 'f${DateTime.now().millisecondsSinceEpoch}',
                              title: title,
                              description: desc,
                              type: _feedbackType,
                              createdBy: 'You',
                              createdDate: _todayIso(),
                              startDate: _feedbackStartDate,
                              endDate: _feedbackEndDate,
                              status: 'active',
                              targetStudents: const ['all'],
                              questions: questions,
                            ),
                      );
                      _showFeedbackSuccessToast = true;
                    });

                    Future.delayed(const Duration(milliseconds: 1500), () {
                      if (!mounted) return;
                      setState(() {
                        _showFeedbackSuccessToast = false;
                        _showCreateFeedback = false;
                      });
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF59E0B),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Create Form',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: () {
                  setState(() {
                    _showCreateFeedback = false;
                  });
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF334155),
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackAnalytics(String formId) {
    final formIndex = _feedbackForms.indexWhere((f) => f.id == formId);
    if (formIndex == -1) {
      return const _ServantEmptyState(
        icon: Icons.error_outline_rounded,
        title: 'Form not found',
        subtitle: 'Please go back and try again.',
      );
    }

    final form = _feedbackForms[formIndex];

    final responses = _feedbackResponses
        .where((r) => r.formId == formId)
        .toList();
    final rate = _submissionRateFor(form);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Feedback Analytics',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F172A),
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                setState(() => _viewingFeedbackFormId = null);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF64748B),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.close_rounded, size: 16),
              label: const Text('Back', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          form.title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          form.description,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF475569),
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _tinyPill(
                    label: _isExpired(form.endDate) ? 'Expired' : 'Active',
                    bg: _isExpired(form.endDate)
                        ? const Color(0xFFFEE2E2)
                        : const Color(0xFFD1FAE5),
                    fg: _isExpired(form.endDate)
                        ? const Color(0xFFB91C1C)
                        : const Color(0xFF047857),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                '${form.questions.length} questions • Due: ${EthiopianDateFormatter.formatFlexible(form.endDate)}',
                style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _buildSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.bar_chart_rounded,
                    color: Color(0xFFF59E0B),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Submission Statistics',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _AnalyticsStat(
                      value: '${rate.submitted}',
                      valueColor: const Color(0xFF16A34A),
                      label: 'Submitted',
                    ),
                  ),
                  Expanded(
                    child: _AnalyticsStat(
                      value: '${rate.total - rate.submitted}',
                      valueColor: const Color(0xFFD97706),
                      label: 'Pending',
                    ),
                  ),
                  Expanded(
                    child: _AnalyticsStat(
                      value: '${rate.percentage}%',
                      valueColor: const Color(0xFF0284C7),
                      label: 'Rate',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (responses.isEmpty)
          _buildSectionCard(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 28),
              child: const _ServantEmptyState(
                icon: Icons.fact_check_rounded,
                title: 'No responses yet',
                subtitle:
                    'Analytics will appear here as students submit feedback',
              ),
            ),
          )
        else
          Column(
            children: form.questions.asMap().entries.map((e) {
              final index = e.key;
              final question = e.value;
              final responseCount = responses.where((r) {
                final answer = r.answers[question.id];
                if (answer == null) return false;
                if (answer is String) return answer.trim().isNotEmpty;
                if (answer is List) return answer.isNotEmpty;
                return true;
              }).length;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildSectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _tinyPill(
                            label: 'Q${index + 1}',
                            bg: const Color(0xFFE0F2FE),
                            fg: const Color(0xFF0369A1),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  question.question,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '$responseCount response${responseCount == 1 ? '' : 's'}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (question.type == 'rating')
                        _buildRatingAnalytics(question, responses)
                      else if (question.type == 'multiple_choice')
                        _buildMultipleChoiceAnalytics(question, responses)
                      else
                        _buildTextAnalytics(question, responses),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildRatingAnalytics(
    _ServantFeedbackQuestion question,
    List<_ServantFeedbackResponse> responses,
  ) {
    final ratings = responses
        .map((r) => r.answers[question.id])
        .whereType<num>()
        .map((n) => n.toInt())
        .where((n) => n >= 1 && n <= 5)
        .toList();

    final avg = ratings.isEmpty
        ? 0
        : (ratings.reduce((a, b) => a + b) / ratings.length);
    final rounded = avg.round().clamp(0, 5);

    final distribution = List.generate(5, (i) {
      final rating = i + 1;
      final count = ratings.where((r) => r == rating).length;
      final percent = ratings.isEmpty
          ? 0
          : ((count / ratings.length) * 100).round();
      return (rating: rating, count: count, percent: percent);
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBEB),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Average Rating',
                style: TextStyle(fontSize: 11, color: Color(0xFF92400E)),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Text(
                    avg.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFD97706),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Row(
                    children: List.generate(5, (i) {
                      final filled = i + 1 <= rounded;
                      return Icon(
                        Icons.star_rounded,
                        size: 18,
                        color: filled
                            ? const Color(0xFFF59E0B)
                            : const Color(0xFFE2E8F0),
                      );
                    }),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Distribution:',
          style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
        ),
        const SizedBox(height: 8),
        Column(
          children: distribution.map((d) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  SizedBox(
                    width: 52,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 14,
                          color: Color(0xFFF59E0B),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${d.rating}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF334155),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        height: 22,
                        color: const Color(0xFFE2E8F0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: FractionallySizedBox(
                            widthFactor: d.percent / 100,
                            child: Container(color: const Color(0xFFF59E0B)),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 66,
                    child: Text(
                      '${d.count} (${d.percent}%)',
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildMultipleChoiceAnalytics(
    _ServantFeedbackQuestion question,
    List<_ServantFeedbackResponse> responses,
  ) {
    final answers = responses
        .map((r) => r.answers[question.id])
        .whereType<String>()
        .where((s) => s.trim().isNotEmpty)
        .toList();

    final total = answers.length;
    final optionCounts = question.options.map((o) {
      final count = answers.where((a) => a == o).length;
      final percent = total == 0 ? 0 : ((count / total) * 100).round();
      return (option: o, count: count, percent: percent);
    }).toList();

    return Column(
      children: optionCounts.map((o) {
        final showInside = o.percent > 15;
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      o.option,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF334155),
                      ),
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        height: 22,
                        color: const Color(0xFFE2E8F0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: FractionallySizedBox(
                            widthFactor: o.percent / 100,
                            child: Container(
                              color: const Color(0xFF0EA5E9),
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 8),
                              child: showInside
                                  ? Text(
                                      '${o.count} (${o.percent}%)',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    )
                                  : null,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (!showInside) ...[
                const SizedBox(width: 10),
                SizedBox(
                  width: 66,
                  child: Text(
                    '${o.count} (${o.percent}%)',
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTextAnalytics(
    _ServantFeedbackQuestion question,
    List<_ServantFeedbackResponse> responses,
  ) {
    final texts = responses
        .map((r) => r.answers[question.id])
        .whereType<String>()
        .where((s) => s.trim().isNotEmpty)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '${texts.length} text responses received',
          style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
        ),
        const SizedBox(height: 10),
        Container(
          constraints: const BoxConstraints(maxHeight: 240),
          child: SingleChildScrollView(
            child: Column(
              children: texts.map((t) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      '"$t"',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF334155),
                        fontStyle: FontStyle.italic,
                        height: 1.35,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFF59E0B)),
      ),
    );
  }

  static String _todayIso() {
    final now = DateTime.now();
    final y = now.year.toString().padLeft(4, '0');
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  static String _truncate(String text, int max) {
    if (text.length <= max) return text;
    return '${text.substring(0, max).trimRight()}…';
  }

  static Widget _tinyPill({
    required String label,
    required Color bg,
    required Color fg,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: fg),
      ),
    );
  }

  static Widget _categoryBadge(String category) {
    switch (category) {
      case 'urgent':
        return _tinyPill(
          label: 'Urgent',
          bg: const Color(0xFFFEE2E2),
          fg: const Color(0xFFB91C1C),
        );
      case 'grades':
        return _tinyPill(
          label: 'Grades',
          bg: const Color(0xFFFEF3C7),
          fg: const Color(0xFF92400E),
        );
      case 'schedule':
        return _tinyPill(
          label: 'Schedule',
          bg: const Color(0xFFDBEAFE),
          fg: const Color(0xFF1D4ED8),
        );
      case 'event':
        return _tinyPill(
          label: 'Event',
          bg: const Color(0xFFD1FAE5),
          fg: const Color(0xFF047857),
        );
      case 'teaching':
        return _tinyPill(
          label: 'Teaching',
          bg: const Color(0xFFE0F2FE),
          fg: const Color(0xFF0369A1),
        );
      case 'facility':
        return _tinyPill(
          label: 'Facility',
          bg: const Color(0xFFFEF3C7),
          fg: const Color(0xFF92400E),
        );
      case 'administration':
        return _tinyPill(
          label: 'Administration',
          bg: const Color(0xFFE2E8F0),
          fg: const Color(0xFF475569),
        );
      case 'other':
        return _tinyPill(
          label: 'Other',
          bg: const Color(0xFFF1F5F9),
          fg: const Color(0xFF475569),
        );
      default:
        return _tinyPill(
          label: category,
          bg: const Color(0xFFF1F5F9),
          fg: const Color(0xFF475569),
        );
    }
  }

  static Widget _priorityBadge(String priority) {
    switch (priority) {
      case 'high':
        return _tinyPill(
          label: 'High',
          bg: const Color(0xFFFEE2E2),
          fg: const Color(0xFFB91C1C),
        );
      case 'medium':
        return _tinyPill(
          label: 'Medium',
          bg: const Color(0xFFFEF3C7),
          fg: const Color(0xFF92400E),
        );
      case 'low':
      default:
        return _tinyPill(
          label: 'Low',
          bg: const Color(0xFFF1F5F9),
          fg: const Color(0xFF475569),
        );
    }
  }

  static Widget _statusBadge(String status) {
    switch (status) {
      case 'pending':
        return _tinyPill(
          label: 'Pending',
          bg: const Color(0xFFFEE2E2),
          fg: const Color(0xFFB91C1C),
        );
      case 'in-review':
        return _tinyPill(
          label: 'In review',
          bg: const Color(0xFFFEF3C7),
          fg: const Color(0xFF92400E),
        );
      case 'resolved':
        return _tinyPill(
          label: 'Resolved',
          bg: const Color(0xFFD1FAE5),
          fg: const Color(0xFF047857),
        );
      default:
        return _tinyPill(
          label: status,
          bg: const Color(0xFFF1F5F9),
          fg: const Color(0xFF475569),
        );
    }
  }
}

enum _ServantBadgeStyle { amber, red }

class _ServantCommTabButton extends StatelessWidget {
  const _ServantCommTabButton({
    required this.label,
    required this.icon,
    required this.selected,
    this.badgeCount,
    this.badgeStyle,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final int? badgeCount;
  final _ServantBadgeStyle? badgeStyle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? const Color(0xFFD97706)
        : const Color(0xFF64748B); // amber-600 vs slate-500

    final showBadge = (badgeCount ?? 0) > 0;

    Color badgeBg = const Color(0xFFFEF3C7);
    Color badgeFg = const Color(0xFF92400E);
    if (badgeStyle == _ServantBadgeStyle.red) {
      badgeBg = const Color(0xFFFEE2E2);
      badgeFg = const Color(0xFFB91C1C);
    }

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: selected ? const Color(0xFFD97706) : Colors.transparent,
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
            if (showBadge) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${badgeCount!}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: badgeFg,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ServantLabeledField extends StatelessWidget {
  const _ServantLabeledField({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF334155),
          ),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}

class _ServantDropdown extends StatelessWidget {
  const _ServantDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String value;
  final List<String> items;
  final ValueChanged<String?>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.expand_more_rounded),
          items: items
              .map(
                (i) => DropdownMenuItem<String>(
                  value: i,
                  child: Text(i, style: const TextStyle(fontSize: 13)),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _ServantEmptyState extends StatelessWidget {
  const _ServantEmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 28),
      child: Column(
        children: [
          Icon(icon, size: 44, color: const Color(0xFFE2E8F0)),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF334155),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
          ),
        ],
      ),
    );
  }
}

class _ServantAnnouncement {
  const _ServantAnnouncement({
    required this.id,
    required this.title,
    required this.message,
    required this.category,
    required this.createdBy,
    required this.createdDate,
    required this.priority,
    required this.targetAudience,
    this.expiresOn,
  });

  final String id;
  final String title;
  final String message;
  final String category;
  final String createdBy;
  final String createdDate;
  final String priority;
  final String targetAudience;
  final String? expiresOn;
}

class _ServantQuestion {
  const _ServantQuestion({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.subjectId,
    required this.subjectName,
    required this.question,
    required this.date,
    required this.answered,
    this.answer,
    this.answeredBy,
    this.answeredDate,
  });

  final String id;
  final String studentId;
  final String studentName;
  final String subjectId;
  final String subjectName;
  final String question;
  final String date;
  final bool answered;
  final String? answer;
  final String? answeredBy;
  final String? answeredDate;

  _ServantQuestion copyWith({
    bool? answered,
    String? answer,
    String? answeredBy,
    String? answeredDate,
  }) {
    return _ServantQuestion(
      id: id,
      studentId: studentId,
      studentName: studentName,
      subjectId: subjectId,
      subjectName: subjectName,
      question: question,
      date: date,
      answered: answered ?? this.answered,
      answer: answer ?? this.answer,
      answeredBy: answeredBy ?? this.answeredBy,
      answeredDate: answeredDate ?? this.answeredDate,
    );
  }
}

class _ServantComplaint {
  const _ServantComplaint({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.complaint,
    required this.category,
    required this.date,
    required this.status,
    this.response,
    this.respondedBy,
    this.respondedDate,
  });

  final String id;
  final String studentId;
  final String studentName;
  final String complaint;
  final String category;
  final String date;
  final String status;
  final String? response;
  final String? respondedBy;
  final String? respondedDate;

  _ServantComplaint copyWith({
    String? status,
    String? response,
    String? respondedBy,
    String? respondedDate,
  }) {
    return _ServantComplaint(
      id: id,
      studentId: studentId,
      studentName: studentName,
      complaint: complaint,
      category: category,
      date: date,
      status: status ?? this.status,
      response: response ?? this.response,
      respondedBy: respondedBy ?? this.respondedBy,
      respondedDate: respondedDate ?? this.respondedDate,
    );
  }
}

class _DraftFeedbackQuestion {
  const _DraftFeedbackQuestion({
    required this.id,
    required this.question,
    required this.type,
    required this.required,
    this.options = const [],
  });

  final String id;
  final String question;
  final String type; // rating | text | multiple_choice
  final bool required;
  final List<String> options;
}

class _ServantFeedbackQuestion {
  const _ServantFeedbackQuestion({
    required this.id,
    required this.question,
    required this.type,
    required this.required,
    this.options = const [],
  });

  final String id;
  final String question;
  final String type; // rating | text | multiple_choice
  final bool required;
  final List<String> options;
}

class _SubmissionRate {
  const _SubmissionRate({
    required this.submitted,
    required this.total,
    required this.percentage,
  });

  final int submitted;
  final int total;
  final int percentage;
}

class _AnalyticsStat extends StatelessWidget {
  const _AnalyticsStat({
    required this.value,
    required this.valueColor,
    required this.label,
  });

  final String value;
  final Color valueColor;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: valueColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
        ),
      ],
    );
  }
}

class _ServantFeedbackForm {
  const _ServantFeedbackForm({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.createdBy,
    required this.createdDate,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.targetStudents,
    required this.questions,
  });

  final String id;
  final String title;
  final String description;
  final String type;
  final String createdBy;
  final String createdDate;
  final String startDate;
  final String endDate;
  final String status;
  final List<String> targetStudents;
  final List<_ServantFeedbackQuestion> questions;
}

class _ServantFeedbackResponse {
  const _ServantFeedbackResponse({
    required this.id,
    required this.formId,
    required this.studentId,
    required this.studentName,
    required this.submittedDate,
    required this.answers,
  });

  final String id;
  final String formId;
  final String studentId;
  final String studentName;
  final String submittedDate;
  final Map<String, Object?> answers;
}

class ServantProfileScreen extends StatelessWidget {
  const ServantProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Servant Profile')));
  }
}
