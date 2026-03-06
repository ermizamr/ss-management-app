import * as React from "react";

import { supabase } from "../lib/supabase";
import { ErrorBanner } from "../components/ErrorBanner";
import { Button } from "../components/ui/button";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "../components/ui/card";
import { Input } from "../components/ui/input";
import { Label } from "../components/ui/label";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "../components/ui/table";

type SubjectRow = {
  id: string;
  name?: string | null;
  grade_id?: string | null;
  passing_grade?: number | null;
  weight?: number | null;
  active?: boolean | null;
};

type GradeRow = {
  id: string;
  name?: string | null;
  code?: string | null;
};

type Draft = {
  name: string;
  grade_id: string | null;
  passing_grade: string;
  weight: string;
  active: boolean;
};

function toNumberOrNull(value: string): number | null {
  const trimmed = value.trim();
  if (!trimmed) return null;
  const n = Number(trimmed);
  if (Number.isNaN(n)) return null;
  return n;
}

export function SubjectsPage() {
  const [subjects, setSubjects] = React.useState<SubjectRow[]>([]);
  const [grades, setGrades] = React.useState<GradeRow[]>([]);
  const [drafts, setDrafts] = React.useState<Record<string, Draft>>({});

  const [filterGradeId, setFilterGradeId] = React.useState<string | null>(null);

  const [isLoading, setIsLoading] = React.useState(true);
  const [error, setError] = React.useState<string | null>(null);

  const [createName, setCreateName] = React.useState("");
  const [createGradeId, setCreateGradeId] = React.useState<string | null>(null);
  const [createPassing, setCreatePassing] = React.useState("");
  const [createWeight, setCreateWeight] = React.useState("");
  const [createActive, setCreateActive] = React.useState(true);

  const [isCreating, setIsCreating] = React.useState(false);
  const [savingId, setSavingId] = React.useState<string | null>(null);

  const gradeNameById = React.useMemo(() => {
    return new Map(
      grades.map((g) => [g.id, g.name ?? g.code ?? g.id] as const),
    );
  }, [grades]);

  const visibleSubjects = React.useMemo(() => {
    if (!filterGradeId) return subjects;
    return subjects.filter((s) => s.grade_id === filterGradeId);
  }, [subjects, filterGradeId]);

  const load = React.useCallback(async () => {
    setError(null);
    setIsLoading(true);

    const [{ data: gradesData, error: gradesError }, { data: subjectsData, error: subjectsError }] =
      await Promise.all([
        supabase.from("grades").select("*").order("name"),
        supabase.from("subjects").select("*").order("name"),
      ]);

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

    setDrafts({});
    setIsLoading(false);
  }, []);

  React.useEffect(() => {
    void load();
  }, [load]);

  function draftFor(s: SubjectRow): Draft {
    return (
      drafts[s.id] ?? {
        name: s.name ?? "",
        grade_id: s.grade_id ?? null,
        passing_grade:
          s.passing_grade === null || s.passing_grade === undefined
            ? ""
            : String(s.passing_grade),
        weight: s.weight === null || s.weight === undefined ? "" : String(s.weight),
        active: s.active ?? true,
      }
    );
  }

  async function createSubject() {
    setError(null);
    const name = createName.trim();
    if (!name) {
      setError("Subject name is required.");
      return;
    }

    setIsCreating(true);
    try {
      const { error: insertError } = await supabase.from("subjects").insert({
        name,
        grade_id: createGradeId,
        passing_grade: toNumberOrNull(createPassing),
        weight: toNumberOrNull(createWeight),
        active: createActive,
      });

      if (insertError) {
        setError(insertError.message);
        return;
      }

      setCreateName("");
      setCreateGradeId(null);
      setCreatePassing("");
      setCreateWeight("");
      setCreateActive(true);

      await load();
    } finally {
      setIsCreating(false);
    }
  }

  async function saveSubject(id: string) {
    const d = drafts[id];
    if (!d) return;

    setError(null);
    setSavingId(id);
    try {
      const { error: updateError } = await supabase
        .from("subjects")
        .update({
          name: d.name.trim() || null,
          grade_id: d.grade_id,
          passing_grade: toNumberOrNull(d.passing_grade),
          weight: toNumberOrNull(d.weight),
          active: d.active,
        })
        .eq("id", id);

      if (updateError) {
        setError(updateError.message);
        return;
      }

      await load();
    } finally {
      setSavingId(null);
    }
  }

  return (
    <div className="flex flex-col gap-6">
      <div>
        <div className="text-2xl font-semibold">Subjects</div>
        <div className="text-sm text-muted-foreground">
          Create and manage subjects and their grading settings.
        </div>
      </div>

      {error ? (
        <ErrorBanner title="Request failed" message={error} />
      ) : null}

      <Card>
        <CardHeader className="border-b">
          <CardTitle>Create subject</CardTitle>
          <CardDescription>Fields not supported by your schema may be ignored by RLS/DB.</CardDescription>
        </CardHeader>
        <CardContent className="grid gap-4 md:grid-cols-5">
          <div className="md:col-span-2">
            <Label htmlFor="create-name">Name</Label>
            <Input
              id="create-name"
              placeholder="Mathematics"
              value={createName}
              onChange={(e) => setCreateName(e.target.value)}
            />
          </div>

          <div>
            <Label htmlFor="create-grade">Grade</Label>
            <select
              id="create-grade"
              className="mt-2 h-10 w-full rounded-md border bg-input-background px-3 text-sm outline-none focus-visible:border-ring focus-visible:ring-ring/50 focus-visible:ring-[3px]"
              value={createGradeId ?? ""}
              onChange={(e) => setCreateGradeId(e.target.value ? e.target.value : null)}
            >
              <option value="">—</option>
              {grades.map((g) => (
                <option key={g.id} value={g.id}>
                  {g.name ?? g.code ?? g.id}
                </option>
              ))}
            </select>
          </div>

          <div>
            <Label htmlFor="create-passing">Passing grade</Label>
            <Input
              id="create-passing"
              placeholder="50"
              value={createPassing}
              onChange={(e) => setCreatePassing(e.target.value)}
            />
          </div>

          <div>
            <Label htmlFor="create-weight">Weight</Label>
            <Input
              id="create-weight"
              placeholder="1"
              value={createWeight}
              onChange={(e) => setCreateWeight(e.target.value)}
            />
          </div>

          <div className="md:col-span-5 flex items-center justify-between gap-3">
            <label className="flex items-center gap-2 text-sm">
              <input
                type="checkbox"
                checked={createActive}
                onChange={(e) => setCreateActive(e.target.checked)}
              />
              Active
            </label>

            <Button disabled={isCreating} onClick={() => void createSubject()}>
              {isCreating ? "Creating…" : "Create"}
            </Button>
          </div>
        </CardContent>
      </Card>

      <Card>
        <CardHeader className="border-b">
          <CardTitle>All subjects</CardTitle>
        </CardHeader>
        <CardContent>
          {isLoading ? (
            <div className="text-sm text-muted-foreground">Loading…</div>
          ) : (
            <div className="grid gap-3">
              <div className="grid gap-2 sm:max-w-sm">
                <Label htmlFor="filter-grade">Filter by grade</Label>
                <select
                  id="filter-grade"
                  className="h-10 w-full rounded-md border bg-input-background px-3 text-sm outline-none focus-visible:border-ring focus-visible:ring-ring/50 focus-visible:ring-[3px]"
                  value={filterGradeId ?? ""}
                  onChange={(e) => setFilterGradeId(e.target.value ? e.target.value : null)}
                >
                  <option value="">All grades</option>
                  {grades.map((g) => (
                    <option key={g.id} value={g.id}>
                      {g.name ?? g.code ?? g.id}
                    </option>
                  ))}
                </select>
              </div>

              <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Name</TableHead>
                  <TableHead>Grade</TableHead>
                  <TableHead>Passing</TableHead>
                  <TableHead>Weight</TableHead>
                  <TableHead>Active</TableHead>
                  <TableHead />
                </TableRow>
              </TableHeader>
              <TableBody>
                {visibleSubjects.map((s) => {
                  const d = draftFor(s);
                  return (
                    <TableRow key={s.id}>
                      <TableCell>
                        <Input
                          value={d.name}
                          onChange={(e) =>
                            setDrafts((prev) => ({
                              ...prev,
                              [s.id]: {
                                ...d,
                                name: e.target.value,
                              },
                            }))
                          }
                        />
                      </TableCell>
                      <TableCell>
                        <select
                          className="h-10 w-full rounded-md border bg-input-background px-3 text-sm outline-none focus-visible:border-ring focus-visible:ring-ring/50 focus-visible:ring-[3px]"
                          value={d.grade_id ?? ""}
                          onChange={(e) =>
                            setDrafts((prev) => ({
                              ...prev,
                              [s.id]: {
                                ...d,
                                grade_id: e.target.value ? e.target.value : null,
                              },
                            }))
                          }
                        >
                          <option value="">—</option>
                          {grades.map((g) => (
                            <option key={g.id} value={g.id}>
                              {g.name ?? g.code ?? g.id}
                            </option>
                          ))}
                        </select>
                        <div className="mt-1 text-xs text-muted-foreground">
                          {d.grade_id ? gradeNameById.get(d.grade_id) : "No grade"}
                        </div>
                      </TableCell>
                      <TableCell>
                        <Input
                          inputMode="decimal"
                          value={d.passing_grade}
                          onChange={(e) =>
                            setDrafts((prev) => ({
                              ...prev,
                              [s.id]: {
                                ...d,
                                passing_grade: e.target.value,
                              },
                            }))
                          }
                        />
                      </TableCell>
                      <TableCell>
                        <Input
                          inputMode="decimal"
                          value={d.weight}
                          onChange={(e) =>
                            setDrafts((prev) => ({
                              ...prev,
                              [s.id]: {
                                ...d,
                                weight: e.target.value,
                              },
                            }))
                          }
                        />
                      </TableCell>
                      <TableCell>
                        <label className="flex items-center gap-2 text-sm">
                          <input
                            type="checkbox"
                            checked={d.active}
                            onChange={(e) =>
                              setDrafts((prev) => ({
                                ...prev,
                                [s.id]: {
                                  ...d,
                                  active: e.target.checked,
                                },
                              }))
                            }
                          />
                          {d.active ? "Yes" : "No"}
                        </label>
                      </TableCell>
                      <TableCell className="text-right">
                        <Button
                          size="sm"
                          disabled={!drafts[s.id] || savingId === s.id}
                          onClick={() => void saveSubject(s.id)}
                        >
                          {savingId === s.id ? "Saving…" : "Save"}
                        </Button>
                      </TableCell>
                    </TableRow>
                  );
                })}
              </TableBody>
              </Table>
            </div>
          )}
        </CardContent>
      </Card>
    </div>
  );
}
