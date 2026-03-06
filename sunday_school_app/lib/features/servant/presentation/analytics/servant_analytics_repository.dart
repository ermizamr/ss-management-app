import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

class ServantAnalyticsRepository {
  ServantAnalyticsRepository({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<ServantAnalyticsSnapshot>
  loadActiveYearForCurrentServantGrade() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw const ServantAnalyticsException('Not signed in');
    }

    final profile = await _client
        .from('profiles')
        .select('id, name, role, grade_id')
        .eq('id', user.id)
        .maybeSingle();

    if (profile == null) {
      throw const ServantAnalyticsException('Profile not found');
    }

    final gradeId = profile['grade_id'] as String?;
    if (gradeId == null || gradeId.isEmpty) {
      throw const ServantAnalyticsException(
        'Servant is not assigned to a grade',
      );
    }

    final academicYear = await _client
        .from('academic_years')
        .select('id, name, status')
        .eq('status', 'active')
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();

    if (academicYear == null) {
      throw const ServantAnalyticsException('No active academic year found');
    }

    final academicYearId = academicYear['id'] as String;

    final gradeRow = await _client
        .from('grades')
        .select('id, name, code')
        .eq('id', gradeId)
        .maybeSingle();

    final gradeName = (gradeRow?['name'] as String?) ?? 'Grade';

    final studentsRows = await _client
        .from('profiles')
        .select('id, name')
        .eq('role', 'student')
        .eq('grade_id', gradeId)
        .order('name');

    final students = studentsRows
        .map(
          (row) => StudentRow(
            id: row['id'] as String,
            name: (row['name'] as String?) ?? 'Student',
          ),
        )
        .toList(growable: false);

    final subjectsRows = await _client
        .from('subjects')
        .select('id, name, grade_id, passing_grade, weight, active')
        .eq('grade_id', gradeId)
        .eq('active', true)
        .order('name');

    final subjects = subjectsRows
        .map(
          (row) => SubjectRow(
            id: row['id'] as String,
            name: (row['name'] as String?) ?? 'Subject',
            passingGrade: (row['passing_grade'] as num?)?.toInt(),
            weight: (row['weight'] as num?)?.toInt(),
          ),
        )
        .toList(growable: false);

    final assessmentsRows = await _client
        .from('assessments')
        .select(
          'id, subject_id, grade_type, max_score, weight, assessment_date, grade_id, academic_year_id',
        )
        .eq('academic_year_id', academicYearId)
        .eq('grade_id', gradeId)
        .order('assessment_date');

    final assessments = assessmentsRows
        .map(
          (row) => AssessmentRow(
            id: row['id'] as String,
            subjectId: row['subject_id'] as String,
            gradeType: (row['grade_type'] as String?) ?? 'Assessment',
            maxScore: (row['max_score'] as num?)?.toDouble() ?? 0,
            weight: (row['weight'] as num?)?.toInt() ?? 0,
            assessmentDate: row['assessment_date'] as String?,
          ),
        )
        .toList(growable: false);

    final assessmentIds = assessments.map((a) => a.id).toList(growable: false);

    final scores = <AssessmentScoreRow>[];
    if (assessmentIds.isNotEmpty) {
      final scoreRows = await _client
          .from('assessment_scores')
          .select('assessment_id, student_id, score')
          .inFilter('assessment_id', assessmentIds);

      for (final row in scoreRows) {
        final assessmentId = row['assessment_id'] as String?;
        final studentId = row['student_id'] as String?;
        if (assessmentId == null || studentId == null) continue;

        scores.add(
          AssessmentScoreRow(
            assessmentId: assessmentId,
            studentId: studentId,
            score: (row['score'] as num?)?.toDouble(),
          ),
        );
      }
    }

    return ServantAnalyticsSnapshot(
      academicYearId: academicYearId,
      academicYearName: (academicYear['name'] as String?) ?? 'Active Year',
      gradeId: gradeId,
      gradeName: gradeName,
      students: students,
      subjects: subjects,
      assessments: assessments,
      scores: scores,
    );
  }
}

class ServantAnalyticsException implements Exception {
  const ServantAnalyticsException(this.message);
  final String message;

  @override
  String toString() => 'ServantAnalyticsException: $message';
}

class ServantAnalyticsSnapshot {
  const ServantAnalyticsSnapshot({
    required this.academicYearId,
    required this.academicYearName,
    required this.gradeId,
    required this.gradeName,
    required this.students,
    required this.subjects,
    required this.assessments,
    required this.scores,
  });

  final String academicYearId;
  final String academicYearName;
  final String gradeId;
  final String gradeName;
  final List<StudentRow> students;
  final List<SubjectRow> subjects;
  final List<AssessmentRow> assessments;
  final List<AssessmentScoreRow> scores;
}

class StudentRow {
  const StudentRow({required this.id, required this.name});
  final String id;
  final String name;
}

class SubjectRow {
  const SubjectRow({
    required this.id,
    required this.name,
    required this.passingGrade,
    required this.weight,
  });
  final String id;
  final String name;
  final int? passingGrade;
  final int? weight;
}

class AssessmentRow {
  const AssessmentRow({
    required this.id,
    required this.subjectId,
    required this.gradeType,
    required this.maxScore,
    required this.weight,
    required this.assessmentDate,
  });

  final String id;
  final String subjectId;
  final String gradeType;
  final double maxScore;
  final int weight;
  final String? assessmentDate;
}

class AssessmentScoreRow {
  const AssessmentScoreRow({
    required this.assessmentId,
    required this.studentId,
    required this.score,
  });

  final String assessmentId;
  final String studentId;
  final double? score;
}
