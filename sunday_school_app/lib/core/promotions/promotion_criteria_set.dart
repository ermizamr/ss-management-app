import 'package:supabase_flutter/supabase_flutter.dart';

enum GradeClassification { excellent, veryGood, good, enough, critical }

class PromotionCriteriaSet {
  const PromotionCriteriaSet({
    required this.minimumOverallAverage,
    required this.minimumSubjectGrade,
    required this.minimumAttendance,
    required this.bandAPlusMin,
    required this.bandAMin,
    required this.bandAMinusMin,
    required this.bandBPlusMin,
    required this.bandBMin,
    required this.excellentLower,
    required this.excellentUpper,
    required this.veryGoodLower,
    required this.veryGoodUpper,
    required this.goodLower,
    required this.goodUpper,
    required this.enoughLower,
    required this.enoughUpper,
  });

  final double minimumOverallAverage;
  final double minimumSubjectGrade;
  final double minimumAttendance;

  final double bandAPlusMin;
  final double bandAMin;
  final double bandAMinusMin;
  final double bandBPlusMin;
  final double bandBMin;

  final double excellentLower;
  final double excellentUpper;
  final double veryGoodLower;
  final double veryGoodUpper;
  final double goodLower;
  final double goodUpper;
  final double enoughLower;
  final double enoughUpper;

  static const defaults = PromotionCriteriaSet(
    minimumOverallAverage: 70,
    minimumSubjectGrade: 60,
    minimumAttendance: 75,
    bandAPlusMin: 97,
    bandAMin: 93,
    bandAMinusMin: 90,
    bandBPlusMin: 87,
    bandBMin: 83,
    excellentLower: 93,
    excellentUpper: 100,
    veryGoodLower: 90,
    veryGoodUpper: 92.99,
    goodLower: 87,
    goodUpper: 89.99,
    enoughLower: 83,
    enoughUpper: 86.99,
  );

  static double _asDouble(Object? v, double fallback) {
    if (v is num) return v.toDouble();
    return fallback;
  }

  factory PromotionCriteriaSet.fromRow(Map<String, dynamic> row) {
    return PromotionCriteriaSet(
      minimumOverallAverage: _asDouble(
        row['minimum_overall_average'],
        defaults.minimumOverallAverage,
      ),
      minimumSubjectGrade: _asDouble(
        row['minimum_subject_grade'],
        defaults.minimumSubjectGrade,
      ),
      minimumAttendance: _asDouble(
        row['minimum_attendance'],
        defaults.minimumAttendance,
      ),
      bandAPlusMin: _asDouble(row['band_a_plus_min'], defaults.bandAPlusMin),
      bandAMin: _asDouble(row['band_a_min'], defaults.bandAMin),
      bandAMinusMin: _asDouble(row['band_a_minus_min'], defaults.bandAMinusMin),
      bandBPlusMin: _asDouble(row['band_b_plus_min'], defaults.bandBPlusMin),
      bandBMin: _asDouble(row['band_b_min'], defaults.bandBMin),
      excellentLower: _asDouble(
        row['excellent_lower'],
        defaults.excellentLower,
      ),
      excellentUpper: _asDouble(
        row['excellent_upper'],
        defaults.excellentUpper,
      ),
      veryGoodLower: _asDouble(row['very_good_lower'], defaults.veryGoodLower),
      veryGoodUpper: _asDouble(row['very_good_upper'], defaults.veryGoodUpper),
      goodLower: _asDouble(row['good_lower'], defaults.goodLower),
      goodUpper: _asDouble(row['good_upper'], defaults.goodUpper),
      enoughLower: _asDouble(row['enough_lower'], defaults.enoughLower),
      enoughUpper: _asDouble(row['enough_upper'], defaults.enoughUpper),
    );
  }

  GradeClassification classify(double pct) {
    if (pct >= excellentLower) return GradeClassification.excellent;
    if (pct >= veryGoodLower) return GradeClassification.veryGood;
    if (pct >= goodLower) return GradeClassification.good;
    if (pct >= enoughLower) return GradeClassification.enough;
    return GradeClassification.critical;
  }

  bool isPassingSubject(double pct) => pct >= minimumSubjectGrade;
}

class PromotionCriteriaRepository {
  const PromotionCriteriaRepository(this._client);

  final SupabaseClient _client;

  Future<PromotionCriteriaSet?> fetchForGradeYear({
    required String academicYearId,
    required String gradeId,
  }) async {
    final row = await _client
        .from('promotion_criteria_sets')
        .select(
          'minimum_overall_average, minimum_subject_grade, minimum_attendance, '
          'band_a_plus_min, band_a_min, band_a_minus_min, band_b_plus_min, band_b_min, '
          'excellent_lower, excellent_upper, '
          'very_good_lower, very_good_upper, '
          'good_lower, good_upper, '
          'enough_lower, enough_upper',
        )
        .eq('academic_year_id', academicYearId)
        .eq('grade_id', gradeId)
        .maybeSingle();

    if (row == null) return null;
    return PromotionCriteriaSet.fromRow((row as Map).cast<String, dynamic>());
  }

  Future<PromotionCriteriaSet?> fetchForCurrentUserActiveYear() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return null;

    final profile = await _client
        .from('profiles')
        .select('grade_id')
        .eq('id', userId)
        .maybeSingle();

    final gradeId = (profile as Map?)?['grade_id']?.toString();
    if (gradeId == null || gradeId.isEmpty) return null;

    final activeYear = await _client
        .from('academic_years')
        .select('id')
        .eq('status', 'active')
        .maybeSingle();

    final academicYearId = (activeYear as Map?)?['id']?.toString();
    if (academicYearId == null || academicYearId.isEmpty) return null;

    return fetchForGradeYear(academicYearId: academicYearId, gradeId: gradeId);
  }
}
