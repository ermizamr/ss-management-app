import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../auth/data/auth_providers.dart';

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
                                              valueColor: AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                            ),
                                          )
                                        : const SizedBox.shrink(),
                                    label: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Text('Login'),
                                        if (!_submitting) ...[
                                          const SizedBox(width: 8),
                                          const Icon(Icons.arrow_forward_rounded, size: 20),
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
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        prefixIcon: Icon(icon, size: 20, color: const Color(0xFF9CA3AF)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
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
    return const Scaffold(
      body: Center(
        child: Text('Student Dashboard (to match Figma)'),
      ),
    );
  }
}

class StudentAttendanceScreen extends StatelessWidget {
  const StudentAttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Student Attendance'),
      ),
    );
  }
}

class StudentGradesScreen extends StatelessWidget {
  const StudentGradesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Static demo data approximating the React mock data
    final subjects = [
      const _SubjectGrade(name: 'Bible Studies', average: 92),
      const _SubjectGrade(name: 'Christian History', average: 84),
      const _SubjectGrade(name: 'Memory Verses', average: 78),
      const _SubjectGrade(name: 'Activities', average: 88),
    ];

    final overallAverage = 86;

    Color _gradeColor(int grade) {
      if (grade >= 90) return const Color(0xFF16A34A); // green-600
      if (grade >= 80) return const Color(0xFF0284C7); // sky-600
      if (grade >= 70) return const Color(0xFFF59E0B); // amber-600
      return const Color(0xFFDC2626); // red-600
    }

    Color _gradeBg(int grade) {
      if (grade >= 90) return const Color(0xFFDCFCE7); // green-50
      if (grade >= 80) return const Color(0xFFE0F2FE); // sky-50
      if (grade >= 70) return const Color(0xFFFEF3C7); // amber-50
      return const Color(0xFFFEE2E2); // red-50
    }

    Color _barColor(int grade) {
      if (grade >= 90) return const Color(0xFF22C55E); // green-500
      if (grade >= 80) return const Color(0xFF0EA5E9); // sky-500
      if (grade >= 70) return const Color(0xFFFBBF24); // amber-500
      return const Color(0xFFEF4444); // red-500
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // slate-50
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(color: Color(0xFFE2E8F0)), // slate-200
                ),
              ),
              width: double.infinity,
              child: const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Grades',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A), // slate-900
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
                    // Overall card
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFFF59E0B), // amber-500
                            Color(0xFFEA580C), // amber-600
                          ],
                        ),
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
                                  color: Colors.white.withOpacity(0.18),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(
                                  Icons.emoji_events_rounded,
                                  color: Colors.white,
                                  size: 26,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Overall Average',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFFFDE68A), // amber-200
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'Academic performance',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFFFDE68A),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '$overallAverage%',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Keep up the excellent work!',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFFFDE68A),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Subject list
                    Column(
                      children: subjects.map((subject) {
                        return _SubjectGradeTile(
                          subject: subject,
                          gradeColor: _gradeColor,
                          gradeBg: _gradeBg,
                          barColor: _barColor,
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 16),
                    // Simple summary
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
                          Row(
                            children: [
                              Icon(
                                Icons.trending_up_rounded,
                                color: Theme.of(context).colorScheme.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Performance Summary',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _SummaryRow(
                            label: 'Total subjects',
                            value: '${subjects.length}',
                          ),
                          const SizedBox(height: 6),
                          _SummaryRow(
                            label: 'Highest subject grade',
                            value:
                                '${subjects.map((s) => s.average).reduce((a, b) => a > b ? a : b)}%',
                          ),
                          const SizedBox(height: 6),
                          _SummaryRow(
                            label: 'Lowest subject grade',
                            value:
                                '${subjects.map((s) => s.average).reduce((a, b) => a < b ? a : b)}%',
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
                border: Border(
                  bottom: BorderSide(
                    color: Color(0xFFE2E8F0),
                  ),
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
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.white,
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

// --- Communication tab content widgets (static demo data) ---

class _AnnouncementsSection extends StatefulWidget {
  const _AnnouncementsSection();

  @override
  State<_AnnouncementsSection> createState() => _AnnouncementsSectionState();
}

class _AnnouncementsSectionState extends State<_AnnouncementsSection> {
  String? _expandedId;

  final List<_Announcement> _items = const [
    _Announcement(
      id: '1',
      title: 'Exam Schedule Update',
      message: 'Mid-term exams will start next Sunday at 9:00 AM...',
      createdBy: 'Class Servant',
      createdDate: 'Mar 3',
      category: 'schedule',
      unread: true,
    ),
    _Announcement(
      id: '2',
      title: 'Bible Memory Challenge',
      message:
          'This month we are focusing on Psalm 23. Try to memorize the whole chapter!',
      createdBy: 'Program Coordinator',
      createdDate: 'Mar 1',
      category: 'event',
      unread: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    if (_items.isEmpty) {
      return Column(
        children: [
          const SizedBox(height: 40),
          Icon(
            Icons.campaign_rounded,
            size: 48,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 8),
          const Text(
            'No announcements',
            style: TextStyle(
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Check back later for updates',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF94A3B8),
            ),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 2),
                        child: Text(
                          '📢',
                          style: TextStyle(fontSize: 22),
                        ),
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
                                  item.createdDate,
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
                  const Divider(
                    height: 1,
                    color: Color(0xFFE2E8F0),
                  ),
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
                              item.createdDate,
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
        question: 'Can you share additional resources about early church fathers?',
        status: 'Answered',
        answered: true,
        answer:
            'Yes, we will share a reading list and a short video next class.',
        date: 'Feb 20',
      ),
    ];

    final pending =
        questions.where((q) => !q.answered).toList(growable: false);
    final answered =
        questions.where((q) => q.answered).toList(growable: false);

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
            label: const Text(
              'Ask a Question',
              style: TextStyle(fontSize: 14),
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (pending.isNotEmpty) ...[
          const Text(
            'Pending',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 8),
          ...pending.map((q) => _QuestionCard(question: q)),
          const SizedBox(height: 16),
        ],
        if (answered.isNotEmpty) ...[
          const Text(
            'Answered',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF6B7280),
            ),
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
            style: TextStyle(
              color: Color(0xFF64748B),
            ),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  question.status,
                  style: TextStyle(
                    fontSize: 11,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            question.question,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF111827),
            ),
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
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF0369A1),
                    ),
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
            question.date,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF9CA3AF),
            ),
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
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: _subject.isEmpty ? null : _subject,
                  items: const [
                    DropdownMenuItem(
                      value: 'Bible Studies',
                      child: Text('Bible Studies'),
                    ),
                    DropdownMenuItem(
                      value: 'Christian History',
                      child: Text('Christian History'),
                    ),
                    DropdownMenuItem(
                      value: 'General',
                      child: Text('General'),
                    ),
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
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF1F2937),
                  ),
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
                          Future.delayed(const Duration(milliseconds: 1500), () {
                            if (!mounted) return;
                            setState(() {
                              _showSuccess = false;
                            });
                            widget.onCancel();
                          });
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                      ),
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
        ] else ...complaints.map((c) => _ComplaintCard(complaint: c)),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  complaint.status,
                  style: TextStyle(
                    fontSize: 11,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            complaint.text,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            complaint.date,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF9CA3AF),
            ),
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
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: _category.isEmpty ? null : _category,
                  items: const [
                    DropdownMenuItem(
                      value: 'teacher',
                      child: Text('Teacher'),
                    ),
                    DropdownMenuItem(
                      value: 'facility',
                      child: Text('Facility'),
                    ),
                    DropdownMenuItem(
                      value: 'course',
                      child: Text('Course'),
                    ),
                    DropdownMenuItem(
                      value: 'administrative',
                      child: Text('Administrative'),
                    ),
                    DropdownMenuItem(
                      value: 'other',
                      child: Text('Other'),
                    ),
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
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF1F2937),
                  ),
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
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF1F2937),
                  ),
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
                          Future.delayed(const Duration(milliseconds: 1500), () {
                            if (!mounted) return;
                            setState(() => _showSuccess = false);
                            widget.onCancel();
                          });
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                      ),
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
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF64748B),
                ),
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

final _textareaDecoration = _inputDecoration.copyWith(
  alignLabelWithHint: true,
);

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
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF6B7280),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF0F172A),
          ),
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
    return const Scaffold(
      body: Center(
        child: Text('Student Profile'),
      ),
    );
  }
}

