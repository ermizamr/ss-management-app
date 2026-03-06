import * as React from "react";

import { supabase } from "../lib/supabase";
import { ErrorBanner } from "../components/ErrorBanner";
import { Button } from "../components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "../components/ui/card";
import { Input } from "../components/ui/input";
import { Label } from "../components/ui/label";

type AcademicYearRow = {
  id: string;
  name?: string | null;
  status?: string | null;
  created_at?: string | null;
};

type GradeRow = {
  id: string;
  name?: string | null;
  code?: string | null;
  sort_order?: number | null;
};

type SubjectRow = {
  id: string;
  name?: string | null;
  grade_id?: string | null;
};

type BoundDraft = {
  lower: string;
  upper: string;
};

export function PromotionsPage() {
  const [years, setYears] = React.useState<AcademicYearRow[]>([]);
  const [grades, setGrades] = React.useState<GradeRow[]>([]);
  const [subjects, setSubjects] = React.useState<SubjectRow[]>([]);
  const [selectedYearId, setSelectedYearId] = React.useState<string | null>(null);
  const [selectedGradeId, setSelectedGradeId] = React.useState<string | null>(null);
  const [notes, setNotes] = React.useState("");

  const [usePrerequisite, setUsePrerequisite] = React.useState(false);
  const [prerequisiteSubjectId, setPrerequisiteSubjectId] = React.useState<string | null>(null);

  const [minimumOverallAverage, setMinimumOverallAverage] = React.useState("70");
  const [minimumSubjectGrade, setMinimumSubjectGrade] = React.useState("60");
  const [minimumAttendance, setMinimumAttendance] = React.useState("75");

  const [bandAPlusMin, setBandAPlusMin] = React.useState("97");
  const [bandAMin, setBandAMin] = React.useState("93");
  const [bandAMinusMin, setBandAMinusMin] = React.useState("90");
  const [bandBPlusMin, setBandBPlusMin] = React.useState("87");
  const [bandBMin, setBandBMin] = React.useState("83");

  const [excellent, setExcellent] = React.useState<BoundDraft>({ lower: "93", upper: "100" });
  const [veryGood, setVeryGood] = React.useState<BoundDraft>({ lower: "90", upper: "92.99" });
  const [good, setGood] = React.useState<BoundDraft>({ lower: "87", upper: "89.99" });
  const [enough, setEnough] = React.useState<BoundDraft>({ lower: "83", upper: "86.99" });
  const [critical, setCritical] = React.useState<BoundDraft>({ lower: "0", upper: "82.99" });

  const [isLoading, setIsLoading] = React.useState(true);
  const [isRunning, setIsRunning] = React.useState(false);
  const [error, setError] = React.useState<string | null>(null);
  const [result, setResult] = React.useState<unknown>(null);
  const [criteriaSaving, setCriteriaSaving] = React.useState(false);

  const activeYear = React.useMemo(
    () => years.find((y) => y.status === "active") ?? null,
    [years],
  );

  function toNumberOrDefault(v: string, fallback: number): number {
    const n = Number(v);
    return Number.isFinite(n) ? n : fallback;
  }

  const load = React.useCallback(async () => {
    setError(null);
    setIsLoading(true);

    const [{ data: yearsData, error: yearsError }, { data: gradesData, error: gradesError }, { data: subjectsData, error: subjectsError }] =
      await Promise.all([
        supabase.from("academic_years").select("*").order("created_at", { ascending: false }),
        supabase.from("grades").select("*").order("sort_order", { ascending: true }).order("name", { ascending: true }),
        supabase.from("subjects").select("id, name, grade_id").order("name", { ascending: true }),
      ]);

    if (yearsError) {
      setError(yearsError.message);
      setYears([]);
    } else {
      setYears((yearsData ?? []) as AcademicYearRow[]);
    }

    if (gradesError) {
      setError(gradesError.message);
      setGrades([]);
    } else {
      setGrades((gradesData ?? []) as GradeRow[]);
    }

    if (subjectsError) {
      setError(subjectsError.message);
      setSubjects([]);
    } else {
      setSubjects((subjectsData ?? []) as SubjectRow[]);
    }

    setIsLoading(false);
  }, []);

  React.useEffect(() => {
    void load();
  }, [load]);

  React.useEffect(() => {
    if (!selectedYearId && activeYear?.id) {
      setSelectedYearId(activeYear.id);
    }
  }, [activeYear?.id, selectedYearId]);

  React.useEffect(() => {
    async function loadCriteria() {
      if (!selectedYearId || !selectedGradeId) return;

      const { data, error: loadError } = await supabase
        .from("promotion_criteria_sets")
        .select("*")
        .eq("academic_year_id", selectedYearId)
        .eq("grade_id", selectedGradeId)
        .maybeSingle();

      if (loadError || !data) return;

      const row = data as Record<string, unknown>;

      const moa = row["minimum_overall_average"];
      setMinimumOverallAverage(
        moa === null || moa === undefined ? "70" : String(moa),
      );

      const msg = row["minimum_subject_grade"];
      setMinimumSubjectGrade(
        msg === null || msg === undefined ? "60" : String(msg),
      );

      const ma = row["minimum_attendance"];
      setMinimumAttendance(
        ma === null || ma === undefined ? "75" : String(ma),
      );

      const aPlus = row["band_a_plus_min"];
      setBandAPlusMin(aPlus === null || aPlus === undefined ? "97" : String(aPlus));
      const a = row["band_a_min"];
      setBandAMin(a === null || a === undefined ? "93" : String(a));
      const aMinus = row["band_a_minus_min"];
      setBandAMinusMin(aMinus === null || aMinus === undefined ? "90" : String(aMinus));
      const bPlus = row["band_b_plus_min"];
      setBandBPlusMin(bPlus === null || bPlus === undefined ? "87" : String(bPlus));
      const b = row["band_b_min"];
      setBandBMin(b === null || b === undefined ? "83" : String(b));

      function setBounds(
        setState: React.Dispatch<React.SetStateAction<BoundDraft>>,
        lowerKey: string,
        upperKey: string,
      ) {
        const lower = row[lowerKey];
        const upper = row[upperKey];
        setState({
          lower: lower === null || lower === undefined ? "" : String(lower),
          upper: upper === null || upper === undefined ? "" : String(upper),
        });
      }

      setBounds(setExcellent, "excellent_lower", "excellent_upper");
      setBounds(setVeryGood, "very_good_lower", "very_good_upper");
      setBounds(setGood, "good_lower", "good_upper");
      setBounds(setEnough, "enough_lower", "enough_upper");
    }

    void loadCriteria();
  }, [selectedYearId, selectedGradeId]);

  async function saveCriteria() {
    setError(null);

    if (!selectedYearId || !selectedGradeId) {
      setError("Choose an academic year and grade before saving criteria.");
      return;
    }

    setCriteriaSaving(true);
    try {
      const payload = {
        academic_year_id: selectedYearId,
        grade_id: selectedGradeId,
        minimum_overall_average: toNumberOrDefault(minimumOverallAverage, 70),
        minimum_subject_grade: toNumberOrDefault(minimumSubjectGrade, 60),
        minimum_attendance: toNumberOrDefault(minimumAttendance, 75),
        band_a_plus_min: toNumberOrDefault(bandAPlusMin, 97),
        band_a_min: toNumberOrDefault(bandAMin, 93),
        band_a_minus_min: toNumberOrDefault(bandAMinusMin, 90),
        band_b_plus_min: toNumberOrDefault(bandBPlusMin, 87),
        band_b_min: toNumberOrDefault(bandBMin, 83),
        excellent_lower: toNumberOrDefault(excellent.lower, 93),
        excellent_upper: toNumberOrDefault(excellent.upper, 100),
        very_good_lower: toNumberOrDefault(veryGood.lower, 90),
        very_good_upper: toNumberOrDefault(veryGood.upper, 92.99),
        good_lower: toNumberOrDefault(good.lower, 87),
        good_upper: toNumberOrDefault(good.upper, 89.99),
        enough_lower: toNumberOrDefault(enough.lower, 83),
        enough_upper: toNumberOrDefault(enough.upper, 86.99),
      };

      const { error: upsertError } = await supabase
        .from("promotion_criteria_sets")
        .upsert(payload, { onConflict: "academic_year_id,grade_id" });

      if (upsertError) {
        setError(
          `Failed to save criteria. Details: ${upsertError.message}`,
        );
        return;
      }
    } finally {
      setCriteriaSaving(false);
    }
  }

  const subjectsForSelectedGrade = React.useMemo(() => {
    if (!selectedGradeId) return subjects;
    return subjects.filter((s) => !s.grade_id || s.grade_id === selectedGradeId);
  }, [selectedGradeId, subjects]);

  function buildPromotionNotes(): string | null {
    const trimmed = notes.trim();
    const config = {
      prerequisite: {
        enabled: usePrerequisite,
        subject_id: usePrerequisite ? prerequisiteSubjectId : null,
      },
      minimum_thresholds: {
        minimum_overall_average: minimumOverallAverage.trim() || null,
        minimum_subject_grade: minimumSubjectGrade.trim() || null,
        minimum_attendance: minimumAttendance.trim() || null,
      },
      grade_bands: {
        band_a_plus_min: bandAPlusMin.trim() || null,
        band_a_min: bandAMin.trim() || null,
        band_a_minus_min: bandAMinusMin.trim() || null,
        band_b_plus_min: bandBPlusMin.trim() || null,
        band_b_min: bandBMin.trim() || null,
      },
      grade_classification: {
        excellent,
        very_good: veryGood,
        good,
        enough,
        critical,
      },
    };

    if (!trimmed) return JSON.stringify({ config });
    return JSON.stringify({ notes: trimmed, config });
  }

  async function runPromotion() {
    setError(null);
    setResult(null);

    if (!selectedYearId || !selectedGradeId) {
      setError("Choose an academic year and grade.");
      return;
    }

    setIsRunning(true);
    try {
      const { data, error: rpcError } = await supabase.rpc("run_promotion", {
        p_academic_year_id: selectedYearId,
        p_grade_id: selectedGradeId,
        p_notes: buildPromotionNotes(),
      });

      if (rpcError) {
        setError(rpcError.message);
        return;
      }

      setResult(data);
    } finally {
      setIsRunning(false);
    }
  }

  return (
    <div className="flex flex-col gap-6">
      <div>
        <div className="text-2xl font-semibold">Promotions</div>
        <div className="text-sm text-muted-foreground">
          Run grade promotions for a given academic year.
        </div>
      </div>

      {error ? <ErrorBanner title="Request failed" message={error} /> : null}

      <Card>
        <CardHeader className="border-b">
          <CardTitle>Promotion criteria</CardTitle>
        </CardHeader>
        <CardContent className="grid gap-4 md:grid-cols-3">
          <div className="md:col-span-3 grid gap-2">
            <Label>Prerequisite subject</Label>
            <label className="flex items-center gap-2 text-sm">
              <input
                type="checkbox"
                checked={usePrerequisite}
                onChange={(e) => setUsePrerequisite(e.target.checked)}
                disabled={isLoading}
              />
              This promotion uses a prerequisite subject
            </label>
            <select
              className="h-10 w-full rounded-md border bg-input-background px-3 text-sm outline-none focus-visible:border-ring focus-visible:ring-ring/50 focus-visible:ring-[3px]"
              value={prerequisiteSubjectId ?? ""}
              onChange={(e) => setPrerequisiteSubjectId(e.target.value || null)}
              disabled={isLoading || !usePrerequisite}
            >
              <option value="">—</option>
              {subjectsForSelectedGrade.map((s) => (
                <option key={s.id} value={s.id}>
                  {s.name ?? s.id}
                </option>
              ))}
            </select>
            <div className="text-xs text-muted-foreground">
              If enabled, a student may need to add the prerequisite subject next class; otherwise the overall subjects average is used.
            </div>
          </div>

          <div className="grid gap-2">
            <Label htmlFor="min-overall">Minimum overall average</Label>
            <Input
              id="min-overall"
              inputMode="decimal"
              placeholder="Default: 70"
              value={minimumOverallAverage}
              onChange={(e) => setMinimumOverallAverage(e.target.value)}
              disabled={isLoading}
            />
            <div className="text-xs text-muted-foreground">
              Used when measuring by overall subjects average.
            </div>
          </div>

          <div className="grid gap-2">
            <Label htmlFor="min-subject">Minimum subject grade (passing)</Label>
            <Input
              id="min-subject"
              inputMode="decimal"
              placeholder="Default: 60"
              value={minimumSubjectGrade}
              onChange={(e) => setMinimumSubjectGrade(e.target.value)}
              disabled={isLoading}
            />
            <div className="text-xs text-muted-foreground">
              Minimum threshold passing grade determining feature.
            </div>
          </div>

          <div className="grid gap-2">
            <Label htmlFor="min-attendance">Minimum attendance</Label>
            <Input
              id="min-attendance"
              inputMode="decimal"
              placeholder="Default: 75"
              value={minimumAttendance}
              onChange={(e) => setMinimumAttendance(e.target.value)}
              disabled={isLoading}
            />
          </div>

          <div className="md:col-span-3 grid gap-3">
            <div className="text-sm font-medium">Letter grade bands</div>
            <div className="grid gap-3 md:grid-cols-5">
              <div className="grid gap-2">
                <div className="text-xs text-muted-foreground">A+ min</div>
                <Input inputMode="decimal" value={bandAPlusMin} onChange={(e) => setBandAPlusMin(e.target.value)} disabled={isLoading} />
              </div>
              <div className="grid gap-2">
                <div className="text-xs text-muted-foreground">A min</div>
                <Input inputMode="decimal" value={bandAMin} onChange={(e) => setBandAMin(e.target.value)} disabled={isLoading} />
              </div>
              <div className="grid gap-2">
                <div className="text-xs text-muted-foreground">A- min</div>
                <Input inputMode="decimal" value={bandAMinusMin} onChange={(e) => setBandAMinusMin(e.target.value)} disabled={isLoading} />
              </div>
              <div className="grid gap-2">
                <div className="text-xs text-muted-foreground">B+ min</div>
                <Input inputMode="decimal" value={bandBPlusMin} onChange={(e) => setBandBPlusMin(e.target.value)} disabled={isLoading} />
              </div>
              <div className="grid gap-2">
                <div className="text-xs text-muted-foreground">B min</div>
                <Input inputMode="decimal" value={bandBMin} onChange={(e) => setBandBMin(e.target.value)} disabled={isLoading} />
              </div>
            </div>
          </div>

          <div className="md:col-span-3 grid gap-3">
            <div className="text-sm font-medium">Grade classification bounds</div>
            <div className="grid gap-3 md:grid-cols-5">
              {[
                ["Excellent (A/A+)", excellent, setExcellent],
                ["Very good (A-)", veryGood, setVeryGood],
                ["Good (B+)", good, setGood],
                ["Enough (B)", enough, setEnough],
                ["Critical (below B)", critical, setCritical],
              ].map(([label, v, setV]) => (
                <div key={String(label)} className="grid gap-2">
                  <div className="text-xs text-muted-foreground">{String(label)}</div>
                  <Input
                    inputMode="decimal"
                    placeholder="Lower"
                    value={(v as BoundDraft).lower}
                    onChange={(e) =>
                      (setV as React.Dispatch<React.SetStateAction<BoundDraft>>)((prev) => ({
                        ...prev,
                        lower: e.target.value,
                      }))
                    }
                    disabled={isLoading}
                  />
                  <Input
                    inputMode="decimal"
                    placeholder="Upper"
                    value={(v as BoundDraft).upper}
                    onChange={(e) =>
                      (setV as React.Dispatch<React.SetStateAction<BoundDraft>>)((prev) => ({
                        ...prev,
                        upper: e.target.value,
                      }))
                    }
                    disabled={isLoading}
                  />
                </div>
              ))}
            </div>
            <div className="text-xs text-muted-foreground">
              Use “Save criteria” to persist to <span className="font-mono">promotion_criteria_sets</span>. Prerequisite selection is recorded in the promotion run notes.
            </div>
            <div className="text-xs text-muted-foreground">
              Note: <span className="font-mono">promotion_criteria_sets</span> does not include critical bounds; “Critical” is captured in notes and is typically interpreted as below the “Enough” lower bound.
            </div>
          </div>

          <div className="md:col-span-3 flex items-center gap-2">
            <Button
              variant="outline"
              disabled={isLoading || criteriaSaving}
              onClick={() => void saveCriteria()}
            >
              {criteriaSaving ? "Saving…" : "Save criteria"}
            </Button>
          </div>
        </CardContent>
      </Card>

      <Card>
        <CardHeader className="border-b">
          <CardTitle>Run promotion</CardTitle>
        </CardHeader>
        <CardContent className="grid gap-4 md:grid-cols-3">
          <div className="grid gap-2">
            <Label htmlFor="year">Academic year</Label>
            <select
              id="year"
              className="h-10 w-full rounded-md border bg-input-background px-3 text-sm outline-none focus-visible:border-ring focus-visible:ring-ring/50 focus-visible:ring-[3px]"
              value={selectedYearId ?? ""}
              onChange={(e) => setSelectedYearId(e.target.value || null)}
              disabled={isLoading}
            >
              <option value="">—</option>
              {years.map((y) => (
                <option key={y.id} value={y.id}>
                  {y.name ?? y.id}{y.status === "active" ? " (active)" : ""}
                </option>
              ))}
            </select>
          </div>

          <div className="grid gap-2">
            <Label htmlFor="grade">Grade</Label>
            <select
              id="grade"
              className="h-10 w-full rounded-md border bg-input-background px-3 text-sm outline-none focus-visible:border-ring focus-visible:ring-ring/50 focus-visible:ring-[3px]"
              value={selectedGradeId ?? ""}
              onChange={(e) => setSelectedGradeId(e.target.value || null)}
              disabled={isLoading}
            >
              <option value="">—</option>
              {grades.map((g) => (
                <option key={g.id} value={g.id}>
                  {g.name ?? g.code ?? g.id}
                </option>
              ))}
            </select>
          </div>

          <div className="grid gap-2 md:col-span-3">
            <Label htmlFor="notes">Notes</Label>
            <Input
              id="notes"
              placeholder="Optional run notes"
              value={notes}
              onChange={(e) => setNotes(e.target.value)}
            />
            <div className="text-xs text-muted-foreground">
              Calls the DB RPC <span className="font-mono">run_promotion</span>.
            </div>
          </div>

          <div className="md:col-span-3">
            <Button disabled={isLoading || isRunning} onClick={() => void runPromotion()}>
              {isRunning ? "Running…" : "Run promotion"}
            </Button>
          </div>
        </CardContent>
      </Card>

      <Card>
        <CardHeader className="border-b">
          <CardTitle>Result</CardTitle>
        </CardHeader>
        <CardContent>
          {result ? (
            <pre className="overflow-auto rounded-lg border bg-muted p-3 text-xs">
              {JSON.stringify(result, null, 2)}
            </pre>
          ) : (
            <div className="text-sm text-muted-foreground">
              No result yet.
            </div>
          )}
        </CardContent>
      </Card>
    </div>
  );
}
