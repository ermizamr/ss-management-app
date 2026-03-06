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

type ProfileRow = {
  id: string;
  name?: string | null;
  role?: string | null;
  grade_id?: string | null;
  academic_id?: string | null;
  account_status?: string | null;
};

type GradeRow = {
  id: string;
  name?: string | null;
  code?: string | null;
};

const roleOptions = ["admin", "servant", "student"] as const;

type Draft = {
  role: string;
  grade_id: string | null;
};

export function UsersPage() {
  const [profiles, setProfiles] = React.useState<ProfileRow[]>([]);
  const [grades, setGrades] = React.useState<GradeRow[]>([]);
  const [isLoading, setIsLoading] = React.useState(true);
  const [error, setError] = React.useState<string | null>(null);

  const [drafts, setDrafts] = React.useState<Record<string, Draft>>({});
  const [savingId, setSavingId] = React.useState<string | null>(null);
  const [actionId, setActionId] = React.useState<string | null>(null);

  const [createEmail, setCreateEmail] = React.useState("");
  const [createPassword, setCreatePassword] = React.useState("");
  const [createRole, setCreateRole] = React.useState<string>("student");
  const [createAcademicId, setCreateAcademicId] = React.useState("");
  const [createName, setCreateName] = React.useState("");
  const [createGradeId, setCreateGradeId] = React.useState<string | null>(null);
  const [isCreating, setIsCreating] = React.useState(false);

  const gradeNameById = React.useMemo(() => {
    return new Map(
      grades.map((g) => [g.id, g.name ?? g.code ?? g.id] as const),
    );
  }, [grades]);

  const load = React.useCallback(async () => {
    setError(null);
    setIsLoading(true);

    const [{ data: gradesData, error: gradesError }, { data: profilesData, error: profilesError }] =
      await Promise.all([
        supabase.from("grades").select("*").order("name"),
        supabase.from("profiles").select("*").order("name"),
      ]);

    if (gradesError) {
      setError(gradesError.message);
      setGrades([]);
    } else {
      setGrades((gradesData ?? []) as GradeRow[]);
    }

    if (profilesError) {
      setError(profilesError.message);
      setProfiles([]);
    } else {
      setProfiles((profilesData ?? []) as ProfileRow[]);
    }

    setDrafts({});
    setIsLoading(false);
  }, []);

  React.useEffect(() => {
    void load();
  }, [load]);

  function draftFor(p: ProfileRow): Draft {
    return (
      drafts[p.id] ?? {
        role: p.role ?? "",
        grade_id: p.grade_id ?? null,
      }
    );
  }

  async function saveProfile(id: string) {
    const draft = drafts[id];
    if (!draft) return;

    setError(null);
    setSavingId(id);
    try {
      const { error: updateError } = await supabase
        .from("profiles")
        .update({
          role: draft.role || null,
          grade_id: draft.grade_id,
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

  async function createUser() {
    setError(null);

    const academicId = createAcademicId.trim();
    const name = createName.trim();
    const password = createPassword.trim();
    const email = createEmail.trim();

    if (!academicId || !name || !password) {
      setError("Academic ID, name, and password are required.");
      return;
    }

    setIsCreating(true);
    try {
      const { data, error: invokeError } = await supabase.functions.invoke(
        "admin-create-user",
        {
          body: {
            email: email || undefined,
            password,
            role: createRole,
            academic_id: academicId,
            name,
            grade_id: createGradeId,
          },
        },
      );

      if (invokeError) {
        setError(invokeError.message);
        return;
      }

      if ((data as { error?: string } | null)?.error) {
        setError((data as { error: string }).error);
        return;
      }

      setCreateEmail("");
      setCreatePassword("");
      setCreateRole("student");
      setCreateAcademicId("");
      setCreateName("");
      setCreateGradeId(null);

      await load();
    } finally {
      setIsCreating(false);
    }
  }

  async function resetPasswordFor(userId: string, displayName: string) {
    const newPassword = window.prompt(`New password for ${displayName}:`);
    if (!newPassword) return;

    setError(null);
    setActionId(userId);
    try {
      const { data, error: invokeError } = await supabase.functions.invoke(
        "admin-reset-password",
        { body: { user_id: userId, new_password: newPassword } },
      );

      if (invokeError) {
        setError(invokeError.message);
        return;
      }

      if ((data as { error?: string } | null)?.error) {
        setError((data as { error: string }).error);
        return;
      }
    } finally {
      setActionId(null);
    }
  }

  async function toggleAccountStatus(p: ProfileRow) {
    const current = (p.account_status ?? "active").toLowerCase();
    const next = current === "inactive" ? "active" : "inactive";

    setError(null);
    setActionId(p.id);
    try {
      const { data, error: invokeError } = await supabase.functions.invoke(
        "admin-set-account-status",
        { body: { user_id: p.id, account_status: next } },
      );

      if (invokeError) {
        setError(invokeError.message);
        return;
      }

      if ((data as { error?: string } | null)?.error) {
        setError((data as { error: string }).error);
        return;
      }

      await load();
    } finally {
      setActionId(null);
    }
  }

  return (
    <div className="flex flex-col gap-6">
      <div>
        <div className="text-2xl font-semibold">Users & Roles</div>
        <div className="text-sm text-muted-foreground">
          Update a user’s role and grade assignment.
        </div>
      </div>

      {error ? (
        <ErrorBanner title="Request failed" message={error} />
      ) : null}

      <Card>
        <CardHeader className="border-b">
          <CardTitle>Create user</CardTitle>
        </CardHeader>
        <CardContent className="grid gap-4 md:grid-cols-3">
          <div className="grid gap-2">
            <Label htmlFor="create-academic">Academic ID</Label>
            <Input
              id="create-academic"
              value={createAcademicId}
              onChange={(e) => setCreateAcademicId(e.target.value)}
              placeholder="e.g., STU-0001"
            />
          </div>
          <div className="grid gap-2">
            <Label htmlFor="create-name">Name</Label>
            <Input
              id="create-name"
              value={createName}
              onChange={(e) => setCreateName(e.target.value)}
              placeholder="Full name"
            />
          </div>
          <div className="grid gap-2">
            <Label htmlFor="create-password">Password</Label>
            <Input
              id="create-password"
              type="password"
              value={createPassword}
              onChange={(e) => setCreatePassword(e.target.value)}
            />
          </div>

          <div className="grid gap-2">
            <Label htmlFor="create-email">Email (optional)</Label>
            <Input
              id="create-email"
              type="email"
              value={createEmail}
              onChange={(e) => setCreateEmail(e.target.value)}
              placeholder="If empty, uses academic_id@school.local"
            />
          </div>

          <div className="grid gap-2">
            <Label htmlFor="create-role">Role</Label>
            <select
              id="create-role"
              className="h-10 w-full rounded-md border bg-input-background px-3 text-sm outline-none focus-visible:border-ring focus-visible:ring-ring/50 focus-visible:ring-[3px]"
              value={createRole}
              onChange={(e) => setCreateRole(e.target.value)}
            >
              {roleOptions.map((r) => (
                <option key={r} value={r}>
                  {r}
                </option>
              ))}
            </select>
          </div>

          <div className="grid gap-2">
            <Label htmlFor="create-grade">Grade</Label>
            <select
              id="create-grade"
              className="h-10 w-full rounded-md border bg-input-background px-3 text-sm outline-none focus-visible:border-ring focus-visible:ring-ring/50 focus-visible:ring-[3px]"
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

          <div className="md:col-span-3">
            <Button disabled={isCreating} onClick={() => void createUser()}>
              {isCreating ? "Creating…" : "Create user"}
            </Button>
            <div className="mt-2 text-xs text-muted-foreground">
              Uses the Edge Function <span className="font-mono">admin-create-user</span>.
            </div>
          </div>
        </CardContent>
      </Card>

      <Card>
        <CardHeader className="border-b">
          <CardTitle>All users</CardTitle>
        </CardHeader>
        <CardContent>
          {isLoading ? (
            <div className="text-sm text-muted-foreground">Loading…</div>
          ) : (
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Name</TableHead>
                  <TableHead>Academic ID</TableHead>
                  <TableHead>Role</TableHead>
                  <TableHead>Grade</TableHead>
                  <TableHead>Status</TableHead>
                  <TableHead />
                </TableRow>
              </TableHeader>
              <TableBody>
                {profiles.map((p) => {
                  const d = draftFor(p);
                  const displayName = p.name ?? p.id;
                  const status = (p.account_status ?? "active").toLowerCase();
                  return (
                    <TableRow key={p.id}>
                      <TableCell className="font-medium">
                        {displayName}
                      </TableCell>
                      <TableCell className="text-muted-foreground">
                        {p.academic_id ?? "—"}
                      </TableCell>
                      <TableCell>
                        <select
                          className="h-9 w-full rounded-md border bg-input-background px-3 text-sm outline-none focus-visible:border-ring focus-visible:ring-ring/50 focus-visible:ring-[3px]"
                          value={d.role}
                          onChange={(e) =>
                            setDrafts((prev) => ({
                              ...prev,
                              [p.id]: {
                                ...d,
                                role: e.target.value,
                              },
                            }))
                          }
                        >
                          <option value="">—</option>
                          {roleOptions.map((r) => (
                            <option key={r} value={r}>
                              {r}
                            </option>
                          ))}
                        </select>
                      </TableCell>
                      <TableCell>
                        <select
                          className="h-9 w-full rounded-md border bg-input-background px-3 text-sm outline-none focus-visible:border-ring focus-visible:ring-ring/50 focus-visible:ring-[3px]"
                          value={d.grade_id ?? ""}
                          onChange={(e) =>
                            setDrafts((prev) => ({
                              ...prev,
                              [p.id]: {
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
                      <TableCell className="text-muted-foreground">
                        {status}
                      </TableCell>
                      <TableCell className="text-right">
                        <div className="flex justify-end gap-2">
                          <Button
                            size="sm"
                            disabled={!drafts[p.id] || savingId === p.id}
                            onClick={() => void saveProfile(p.id)}
                          >
                            {savingId === p.id ? "Saving…" : "Save"}
                          </Button>

                          <Button
                            size="sm"
                            variant="outline"
                            disabled={actionId === p.id}
                            onClick={() => void resetPasswordFor(p.id, displayName)}
                          >
                            Reset password
                          </Button>

                          <Button
                            size="sm"
                            variant={status === "inactive" ? "default" : "destructive"}
                            disabled={actionId === p.id}
                            onClick={() => void toggleAccountStatus(p)}
                          >
                            {actionId === p.id
                              ? "Working…"
                              : status === "inactive"
                                ? "Activate"
                                : "Deactivate"}
                          </Button>
                        </div>
                      </TableCell>
                    </TableRow>
                  );
                })}
              </TableBody>
            </Table>
          )}
        </CardContent>
      </Card>
    </div>
  );
}
