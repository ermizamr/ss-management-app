import 'dart:math';

import 'servant_analytics_repository.dart';

const int kDefaultRiskThreshold = 70;
const int kDefaultTopPerformersCount = 10;

ServantAnalyticsData calculateAnalyticsData(
  ServantAnalyticsSnapshot snapshot, {
  int riskThreshold = kDefaultRiskThreshold,
  int topPerformersCount = kDefaultTopPerformersCount,
}) {
  final assessmentsById = {
    for (final assessment in snapshot.assessments) assessment.id: assessment,
  };

  final assessmentsBySubjectId = <String, List<AssessmentRow>>{};
  for (final assessment in snapshot.assessments) {
    (assessmentsBySubjectId[assessment.subjectId] ??= []).add(assessment);
  }

  final scoresByStudentId = <String, Map<String, double>>{};
  final scoreCountsByStudentId = <String, int>{};
  for (final s in snapshot.scores) {
    if (s.score == null) continue;
    (scoresByStudentId[s.studentId] ??= {})[s.assessmentId] = s.score!;
    scoreCountsByStudentId[s.studentId] =
        (scoreCountsByStudentId[s.studentId] ?? 0) + 1;
  }

  int? subjectAverage(String studentId, String subjectId) {
    final subjectAssessments = assessmentsBySubjectId[subjectId] ?? const [];
    if (subjectAssessments.isEmpty) return 0;

    final studentScores = scoresByStudentId[studentId] ?? const {};

    final hasAllScores = subjectAssessments.every((a) {
      return studentScores.containsKey(a.id);
    });

    if (!hasAllScores) return null;

    final totalWeight = subjectAssessments.fold<int>(
      0,
      (sum, a) => sum + max(0, a.weight),
    );

    if (totalWeight > 0) {
      double weightedScore = 0;
      for (final a in subjectAssessments) {
        final score = studentScores[a.id] ?? 0;
        final percentage = a.maxScore <= 0 ? 0 : (score / a.maxScore) * 100;
        final normalizedWeight = max(0, a.weight) / totalWeight;
        weightedScore += percentage * normalizedWeight;
      }
      return weightedScore.round();
    }

    double totalPercentage = 0;
    for (final a in subjectAssessments) {
      final score = studentScores[a.id] ?? 0;
      final percentage = a.maxScore <= 0 ? 0 : (score / a.maxScore) * 100;
      totalPercentage += percentage;
    }
    return (totalPercentage / subjectAssessments.length).round();
  }

  int overallAverage(String studentId) {
    final studentAssessmentIds =
        (scoresByStudentId[studentId] ?? const {}).keys;
    if (studentAssessmentIds.isEmpty) return 0;

    final subjectIds = <String>{};
    for (final assessmentId in studentAssessmentIds) {
      final assessment = assessmentsById[assessmentId];
      if (assessment == null) continue;
      subjectIds.add(assessment.subjectId);
    }

    if (subjectIds.isEmpty) return 0;

    int totalSubjectAverage = 0;
    for (final subjectId in subjectIds) {
      final avg = subjectAverage(studentId, subjectId);
      if (avg != null) totalSubjectAverage += avg;
    }

    return (totalSubjectAverage / subjectIds.length).round();
  }

  // Grade distribution (overall averages)
  final gradeRanges = <GradeRangeData>[
    GradeRangeData(range: '90-100', min: 90, max: 100),
    GradeRangeData(range: '80-89', min: 80, max: 89),
    GradeRangeData(range: '70-79', min: 70, max: 79),
    GradeRangeData(range: '60-69', min: 60, max: 69),
    GradeRangeData(range: '0-59', min: 0, max: 59),
    GradeRangeData(range: 'Incomplete', min: -1, max: -1),
  ];

  for (final student in snapshot.students) {
    final avg = overallAverage(student.id);
    if (avg == 0) {
      final hasAnyGrade = (scoreCountsByStudentId[student.id] ?? 0) > 0;
      if (!hasAnyGrade) {
        gradeRanges.last.increment();
      } else {
        gradeRanges[4].increment();
      }
      continue;
    }

    for (final r in gradeRanges) {
      if (avg >= r.min && avg <= r.max) {
        r.increment();
        break;
      }
    }
  }

  // Subject averages
  final subjectAverages = <SubjectAverageData>[];
  for (final subject in snapshot.subjects) {
    final validScores = <int>[];
    for (final student in snapshot.students) {
      final avg = subjectAverage(student.id, subject.id);
      if (avg != null) validScores.add(avg);
    }

    final average = validScores.isNotEmpty
        ? (validScores.reduce((a, b) => a + b) / validScores.length).round()
        : 0;

    subjectAverages.add(
      SubjectAverageData(
        subjectId: subject.id,
        name: subject.name,
        average: average,
        highest: validScores.isNotEmpty ? validScores.reduce(max) : 0,
        lowest: validScores.isNotEmpty ? validScores.reduce(min) : 0,
        incomplete: snapshot.students.length - validScores.length,
      ),
    );
  }

  final atRiskStudents = <StudentPerformanceData>[];
  final topPerformers = <StudentPerformanceData>[];
  final studentsWithMissing = <StudentMissingData>[];

  final studentAverages = <StudentPerformanceData>[];

  for (final student in snapshot.students) {
    final avg = overallAverage(student.id);
    final data = StudentPerformanceData(
      id: student.id,
      name: student.name,
      gradeName: snapshot.gradeName,
      average: avg,
    );
    studentAverages.add(data);

    if (avg > 0 && avg < riskThreshold) {
      atRiskStudents.add(data);
    }

    final missingSubjects = <String>[];
    for (final subject in snapshot.subjects) {
      if (subjectAverage(student.id, subject.id) == null) {
        missingSubjects.add(subject.id);
      }
    }
    if (missingSubjects.isNotEmpty) {
      studentsWithMissing.add(
        StudentMissingData(
          id: student.id,
          name: student.name,
          gradeName: snapshot.gradeName,
          missingSubjectCount: missingSubjects.length,
        ),
      );
    }
  }

  studentAverages.sort((a, b) => b.average.compareTo(a.average));
  topPerformers.addAll(
    studentAverages.where((s) => s.average > 0).take(topPerformersCount),
  );

  // Assessment type performance
  const assessmentTypes = [
    'Quiz',
    'Exam',
    'Assignment',
    'Project',
    'Paper',
    'Journal',
    'Presentation',
    'Service',
  ];

  final assessmentPerformance = <AssessmentTypePerformanceData>[];

  for (final type in assessmentTypes) {
    final relevant = snapshot.assessments
        .where((a) => a.gradeType.toLowerCase().contains(type.toLowerCase()))
        .toList(growable: false);

    if (relevant.isEmpty) continue;

    double totalPercentage = 0;
    int count = 0;

    for (final assessment in relevant) {
      for (final student in snapshot.students) {
        final studentScores = scoresByStudentId[student.id];
        final score = studentScores?[assessment.id];
        if (score == null) continue;

        if (assessment.maxScore <= 0) continue;
        totalPercentage += (score / assessment.maxScore) * 100;
        count++;
      }
    }

    if (count <= 0) continue;

    final average = (totalPercentage / count).round();
    if (average <= 0) continue;

    assessmentPerformance.add(
      AssessmentTypePerformanceData(type: type, average: average),
    );
  }

  // Overall stats
  final validAverages = studentAverages.where((s) => s.average > 0).toList();
  final classAverage = validAverages.isNotEmpty
      ? (validAverages.map((s) => s.average).reduce((a, b) => a + b) /
                validAverages.length)
            .round()
      : 0;

  return ServantAnalyticsData(
    academicYearName: snapshot.academicYearName,
    gradeName: snapshot.gradeName,
    classAverage: classAverage,
    studentsWithGrades: validAverages.length,
    totalStudents: snapshot.students.length,
    gradeDistribution: gradeRanges,
    subjectAverages: subjectAverages,
    atRiskStudents: atRiskStudents,
    topPerformers: topPerformers,
    studentsWithMissing: studentsWithMissing,
    assessmentPerformance: assessmentPerformance,
    subjectDetails: (String subjectId) {
      final subject = snapshot.subjects.firstWhere(
        (s) => s.id == subjectId,
        orElse: () => SubjectRow(
          id: subjectId,
          name: 'Subject',
          passingGrade: null,
          weight: null,
        ),
      );

      final gradeRanges = <GradeRangeData>[
        GradeRangeData(range: '90-100', min: 90, max: 100),
        GradeRangeData(range: '80-89', min: 80, max: 89),
        GradeRangeData(range: '70-79', min: 70, max: 79),
        GradeRangeData(range: '60-69', min: 60, max: 69),
        GradeRangeData(range: '0-59', min: 0, max: 59),
      ];

      for (final student in snapshot.students) {
        final avg = subjectAverage(student.id, subjectId);
        if (avg == null || avg <= 0) continue;
        for (final r in gradeRanges) {
          if (avg >= r.min && avg <= r.max) {
            r.increment();
            break;
          }
        }
      }

      final assessments = (assessmentsBySubjectId[subjectId] ?? const [])
          .toList();

      final assessmentBreakdown = <AssessmentBreakdownData>[];
      for (final assessment in assessments) {
        final scores = <double>[];
        for (final s in snapshot.scores) {
          if (s.assessmentId == assessment.id && s.score != null) {
            scores.add(s.score!);
          }
        }

        final avg = (scores.isNotEmpty && assessment.maxScore > 0)
            ? ((scores.reduce((a, b) => a + b) / scores.length) /
                      assessment.maxScore *
                      100)
                  .round()
            : 0;

        assessmentBreakdown.add(
          AssessmentBreakdownData(
            name: assessment.gradeType,
            average: avg,
            weight: assessment.weight,
            completed: scores.length,
            total: snapshot.students.length,
          ),
        );
      }

      return SubjectDetailData(
        subjectId: subjectId,
        subjectName: subject.name,
        gradeDistribution: gradeRanges,
        assessmentBreakdown: assessmentBreakdown,
      );
    },
  );
}

class ServantAnalyticsData {
  const ServantAnalyticsData({
    required this.academicYearName,
    required this.gradeName,
    required this.classAverage,
    required this.studentsWithGrades,
    required this.totalStudents,
    required this.gradeDistribution,
    required this.subjectAverages,
    required this.atRiskStudents,
    required this.topPerformers,
    required this.studentsWithMissing,
    required this.assessmentPerformance,
    required this.subjectDetails,
  });

  final String academicYearName;
  final String gradeName;
  final int classAverage;
  final int studentsWithGrades;
  final int totalStudents;
  final List<GradeRangeData> gradeDistribution;
  final List<SubjectAverageData> subjectAverages;
  final List<StudentPerformanceData> atRiskStudents;
  final List<StudentPerformanceData> topPerformers;
  final List<StudentMissingData> studentsWithMissing;
  final List<AssessmentTypePerformanceData> assessmentPerformance;
  final SubjectDetailData Function(String subjectId) subjectDetails;
}

class GradeRangeData {
  GradeRangeData({
    required this.range,
    required this.min,
    required this.max,
    this.count = 0,
  });

  final String range;
  final int min;
  final int max;
  int count;

  void increment() => count++;
}

class SubjectAverageData {
  const SubjectAverageData({
    required this.subjectId,
    required this.name,
    required this.average,
    required this.highest,
    required this.lowest,
    required this.incomplete,
  });

  final String subjectId;
  final String name;
  final int average;
  final int highest;
  final int lowest;
  final int incomplete;
}

class StudentPerformanceData {
  const StudentPerformanceData({
    required this.id,
    required this.name,
    required this.gradeName,
    required this.average,
  });

  final String id;
  final String name;
  final String gradeName;
  final int average;
}

class StudentMissingData {
  const StudentMissingData({
    required this.id,
    required this.name,
    required this.gradeName,
    required this.missingSubjectCount,
  });

  final String id;
  final String name;
  final String gradeName;
  final int missingSubjectCount;
}

class AssessmentTypePerformanceData {
  const AssessmentTypePerformanceData({
    required this.type,
    required this.average,
  });
  final String type;
  final int average;
}

class SubjectDetailData {
  const SubjectDetailData({
    required this.subjectId,
    required this.subjectName,
    required this.gradeDistribution,
    required this.assessmentBreakdown,
  });

  final String subjectId;
  final String subjectName;
  final List<GradeRangeData> gradeDistribution;
  final List<AssessmentBreakdownData> assessmentBreakdown;
}

class AssessmentBreakdownData {
  const AssessmentBreakdownData({
    required this.name,
    required this.average,
    required this.weight,
    required this.completed,
    required this.total,
  });

  final String name;
  final int average;
  final int weight;
  final int completed;
  final int total;
}
