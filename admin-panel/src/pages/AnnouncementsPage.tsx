import * as React from "react";

import { supabase } from "../lib/supabase";
import { ErrorBanner } from "../components/ErrorBanner";
import { Button } from "../components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "../components/ui/card";
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

type AnnouncementRow = {
  id: string;
  title?: string | null;
  message?: string | null;
  category?: string | null;
  priority?: string | null;
  created_at?: string | null;
  expires_on?: string | null;
  active?: boolean | null;
  grade_id?: string | null;
  academic_year_id?: string | null;
  created_by?: string | null;
};

type GradeRow = {
  id: string;
  name?: string | null;
  code?: string | null;
};

type AcademicYearRow = {
  id: string;
  name?: string | null;
  status?: string | null;
  created_at?: string | null;
};

export function AnnouncementsPage() {
  const [announcements, setAnnouncements] = React.useState<AnnouncementRow[]>([]);
  const [grades, setGrades] = React.useState<GradeRow[]>([]);
  const [years, setYears] = React.useState<AcademicYearRow[]>([]);

  const gradeNameById = React.useMemo(() => {
    return new Map(
      grades.map((g) => [g.id, g.name ?? g.code ?? g.id] as const),
    );
  }, [grades]);

  const [createTitle, setCreateTitle] = React.useState("");
  const [createMessage, setCreateMessage] = React.useState("");
  const [createCategory, setCreateCategory] = React.useState("general");
  const [createPriority, setCreatePriority] = React.useState("medium");
  const [createExpiresOn, setCreateExpiresOn] = React.useState("");
  const [createGradeId, setCreateGradeId] = React.useState<string | null>(null);
  const [createAcademicYearId, setCreateAcademicYearId] = React.useState<string | null>(null);
  const [createActive, setCreateActive] = React.useState(true);

  const [isLoading, setIsLoading] = React.useState(true);
  const [isCreating, setIsCreating] = React.useState(false);
  const [deletingId, setDeletingId] = React.useState<string | null>(null);
  const [error, setError] = React.useState<string | null>(null);

  const activeYear = React.useMemo(
    () => years.find((y) => y.status === "active") ?? null,
    [years],
  );

  const load = React.useCallback(async () => {
    setError(null);
    setIsLoading(true);

    const [{ data: yearsData, error: yearsError }, { data: gradesData, error: gradesError }, { data: announcementsData, error: announcementsError }] =
      await Promise.all([
        supabase.from("academic_years").select("*").order("created_at", { ascending: false }),
        supabase.from("grades").select("*").order("name"),
        supabase
          .from("announcements")
          .select(
            "id, title, message, category, priority, created_by, created_at, expires_on, active, grade_id, academic_year_id",
          )
          .order("created_at", { ascending: false }),
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

    if (announcementsError) {
      setError(announcementsError.message);
      setAnnouncements([]);
    } else {
      setAnnouncements((announcementsData ?? []) as AnnouncementRow[]);
    }

    setIsLoading(false);
  }, []);

  React.useEffect(() => {
    void load();
  }, [load]);

  React.useEffect(() => {
    if (!createAcademicYearId && activeYear?.id) {
      setCreateAcademicYearId(activeYear.id);
    }
  }, [activeYear?.id, createAcademicYearId]);

  async function createAnnouncement() {
    setError(null);

    const title = createTitle.trim();
    const message = createMessage.trim();
    if (!title || !message) {
      setError("Title and message are required.");
      return;
    }

    const expires = createExpiresOn.trim();
    const validExpires = expires
      ? Number.isNaN(Date.parse(expires))
        ? null
        : expires
      : null;

    setIsCreating(true);
    try {
      const { error: insertError } = await supabase.from("announcements").insert({
        academic_year_id: createAcademicYearId,
        grade_id: createGradeId,
        title,
        message,
        category: createCategory.trim() || "general",
        priority: createPriority.trim() || "medium",
        expires_on: validExpires,
        active: createActive,
      });

      if (insertError) {
        setError(insertError.message);
        return;
      }

      setCreateTitle("");
      setCreateMessage("");
      setCreateCategory("general");
      setCreatePriority("medium");
      setCreateExpiresOn("");
      setCreateGradeId(null);
      setCreateActive(true);

      await load();
    } finally {
      setIsCreating(false);
    }
  }

  async function deleteAnnouncement(id: string) {
    setError(null);
    setDeletingId(id);
    try {
      const { error: deleteError } = await supabase
        .from("announcements")
        .delete()
        .eq("id", id);

      if (deleteError) {
        setError(deleteError.message);
        return;
      }

      await load();
    } finally {
      setDeletingId(null);
    }
  }

  return (
    <div className="flex flex-col gap-6">
      <div>
        <div className="text-2xl font-semibold">Announcements</div>
        <div className="text-sm text-muted-foreground">
          Create global or grade-scoped announcements.
        </div>
      </div>

      {error ? <ErrorBanner title="Request failed" message={error} /> : null}

      <Card>
        <CardHeader className="border-b">
          <CardTitle>Create announcement</CardTitle>
        </CardHeader>
        <CardContent className="grid gap-4 md:grid-cols-2">
          <div className="grid gap-2">
            <Label htmlFor="title">Title</Label>
            <Input id="title" value={createTitle} onChange={(e) => setCreateTitle(e.target.value)} />
          </div>

          <div className="grid gap-2">
            <Label htmlFor="grade">Grade (optional)</Label>
            <select
              id="grade"
              className="h-10 w-full rounded-md border bg-input-background px-3 text-sm outline-none focus-visible:border-ring focus-visible:ring-ring/50 focus-visible:ring-[3px]"
              value={createGradeId ?? ""}
              onChange={(e) => setCreateGradeId(e.target.value ? e.target.value : null)}
              disabled={isLoading}
            >
              <option value="">Global (all grades)</option>
              {grades.map((g) => (
                <option key={g.id} value={g.id}>
                  {g.name ?? g.code ?? g.id}
                </option>
              ))}
            </select>
          </div>

          <div className="grid gap-2 md:col-span-2">
            <Label htmlFor="message">Message</Label>
            <Input id="message" value={createMessage} onChange={(e) => setCreateMessage(e.target.value)} />
          </div>

          <div className="grid gap-2">
            <Label htmlFor="category">Category</Label>
            <Input id="category" value={createCategory} onChange={(e) => setCreateCategory(e.target.value)} />
          </div>

          <div className="grid gap-2">
            <Label htmlFor="priority">Priority</Label>
            <Input id="priority" value={createPriority} onChange={(e) => setCreatePriority(e.target.value)} />
          </div>

          <div className="grid gap-2">
            <Label htmlFor="expires">Expires on (optional)</Label>
            <Input
              id="expires"
              placeholder="YYYY-MM-DD"
              value={createExpiresOn}
              onChange={(e) => setCreateExpiresOn(e.target.value)}
            />
          </div>

          <div className="grid gap-2">
            <Label htmlFor="academic-year">Academic year</Label>
            <select
              id="academic-year"
              className="h-10 w-full rounded-md border bg-input-background px-3 text-sm outline-none focus-visible:border-ring focus-visible:ring-ring/50 focus-visible:ring-[3px]"
              value={createAcademicYearId ?? ""}
              onChange={(e) => setCreateAcademicYearId(e.target.value || null)}
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

          <div className="md:col-span-2 flex items-center justify-between gap-3">
            <label className="flex items-center gap-2 text-sm">
              <input type="checkbox" checked={createActive} onChange={(e) => setCreateActive(e.target.checked)} />
              Active
            </label>

            <Button disabled={isLoading || isCreating} onClick={() => void createAnnouncement()}>
              {isCreating ? "Creating…" : "Create"}
            </Button>
          </div>
        </CardContent>
      </Card>

      <Card>
        <CardHeader className="border-b">
          <CardTitle>All announcements</CardTitle>
        </CardHeader>
        <CardContent>
          {isLoading ? (
            <div className="text-sm text-muted-foreground">Loading…</div>
          ) : (
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Title</TableHead>
                  <TableHead>Grade</TableHead>
                  <TableHead>Priority</TableHead>
                  <TableHead>Active</TableHead>
                  <TableHead>Created</TableHead>
                  <TableHead />
                </TableRow>
              </TableHeader>
              <TableBody>
                {announcements.map((a) => (
                  <TableRow key={a.id}>
                    <TableCell className="font-medium">
                      <div>{a.title ?? a.id}</div>
                      <div className="text-xs text-muted-foreground">
                        {a.message ?? ""}
                      </div>
                    </TableCell>
                    <TableCell className="text-muted-foreground">
                      {a.grade_id ? gradeNameById.get(a.grade_id) ?? a.grade_id : "Global"}
                    </TableCell>
                    <TableCell className="text-muted-foreground">
                      {a.priority ?? "—"}
                    </TableCell>
                    <TableCell className="text-muted-foreground">
                      {a.active ? "Yes" : "No"}
                    </TableCell>
                    <TableCell className="text-muted-foreground">
                      {a.created_at ? new Date(a.created_at).toLocaleString() : "—"}
                    </TableCell>
                    <TableCell className="text-right">
                      <Button
                        size="sm"
                        variant="destructive"
                        disabled={deletingId === a.id}
                        onClick={() => void deleteAnnouncement(a.id)}
                      >
                        {deletingId === a.id ? "Deleting…" : "Delete"}
                      </Button>
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          )}
        </CardContent>
      </Card>
    </div>
  );
}
