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

type AcademicYearRow = {
  id: string;
  name?: string | null;
  status?: string | null;
  created_at?: string | null;
};

export function AcademicYearsPage() {
  const [years, setYears] = React.useState<AcademicYearRow[]>([]);
  const [isLoading, setIsLoading] = React.useState(true);
  const [error, setError] = React.useState<string | null>(null);

  const [newName, setNewName] = React.useState("");
  const [startDate, setStartDate] = React.useState("");
  const [endDate, setEndDate] = React.useState("");
  const [isCreating, setIsCreating] = React.useState(false);
  const [isEnding, setIsEnding] = React.useState(false);
  const [archivingId, setArchivingId] = React.useState<string | null>(null);

  const activeYear = years.find((y) => y.status === "active") ?? null;

  const load = React.useCallback(async () => {
    setError(null);
    setIsLoading(true);
    const { data, error: loadError } = await supabase
      .from("academic_years")
      .select("*")
      .order("created_at", { ascending: false });

    if (loadError) {
      setError(loadError.message);
      setYears([]);
      setIsLoading(false);
      return;
    }

    setYears((data ?? []) as AcademicYearRow[]);
    setIsLoading(false);
  }, []);

  React.useEffect(() => {
    void load();
  }, [load]);

  async function createYear(e: React.FormEvent) {
    e.preventDefault();
    setError(null);
    setIsCreating(true);
    try {
      const name = newName.trim();
      const start = startDate.trim();
      const end = endDate.trim();

      if (!name || !start || !end) return;

      const { error: rpcError } = await supabase.rpc("start_new_academic_year", {
        p_name: name,
        p_start_date: start,
        p_end_date: end,
      });

      if (rpcError) {
        setError(rpcError.message);
        return;
      }

      setNewName("");
      setStartDate("");
      setEndDate("");
      await load();
    } finally {
      setIsCreating(false);
    }
  }

  async function endActiveYear() {
    if (!activeYear) return;
    setError(null);
    setIsEnding(true);
    try {
      const { error: rpcError } = await supabase.rpc("end_academic_year", {
        year_id: activeYear.id,
      });

      if (rpcError) {
        setError(rpcError.message);
        return;
      }

      await load();
    } finally {
      setIsEnding(false);
    }
  }

  async function archiveYear(yearId: string) {
    setError(null);
    setArchivingId(yearId);
    try {
      const { error: rpcError } = await supabase.rpc("archive_academic_year", {
        year_id: yearId,
      });

      if (rpcError) {
        setError(rpcError.message);
        return;
      }

      await load();
    } finally {
      setArchivingId(null);
    }
  }

  return (
    <div className="flex flex-col gap-6">
      <div>
        <div className="text-2xl font-semibold">Academic Year</div>
        <div className="text-sm text-muted-foreground">
          Manage the active academic year. Access is enforced by Supabase RLS.
        </div>
      </div>

      {error ? (
        <ErrorBanner title="Request failed" message={error} />
      ) : null}

      <Card>
        <CardHeader className="border-b">
          <CardTitle>Current status</CardTitle>
        </CardHeader>
        <CardContent className="grid gap-3">
          <div className="text-sm">
            <span className="text-muted-foreground">Active year: </span>
            <span className="font-medium">
              {activeYear?.name ?? "None"}
            </span>
          </div>
          <div>
            <Button
              variant="destructive"
              disabled={!activeYear || isEnding}
              onClick={() => void endActiveYear()}
            >
              {isEnding ? "Ending…" : "End active academic year"}
            </Button>
          </div>
        </CardContent>
      </Card>

      <Card>
        <CardHeader className="border-b">
          <CardTitle>Start new academic year</CardTitle>
        </CardHeader>
        <CardContent>
          <form className="grid gap-3 md:grid-cols-[1fr_auto]" onSubmit={createYear}>
            <div className="grid gap-2">
              <Label htmlFor="yearName">Year name</Label>
              <Input
                id="yearName"
                placeholder="e.g., 2026-2027"
                value={newName}
                onChange={(e) => setNewName(e.target.value)}
                required
              />
              <div className="grid gap-2 md:grid-cols-2">
                <div className="grid gap-2">
                  <Label htmlFor="startDate">Start date</Label>
                  <Input
                    id="startDate"
                    type="date"
                    value={startDate}
                    onChange={(e) => setStartDate(e.target.value)}
                    required
                  />
                </div>
                <div className="grid gap-2">
                  <Label htmlFor="endDate">End date</Label>
                  <Input
                    id="endDate"
                    type="date"
                    value={endDate}
                    onChange={(e) => setEndDate(e.target.value)}
                    required
                  />
                </div>
              </div>
              <div className="text-xs text-muted-foreground">
                Calls the DB RPC <span className="font-mono">start_new_academic_year</span>.
              </div>
            </div>
            <div className="flex items-end">
              <Button type="submit" disabled={isCreating}>
                {isCreating ? "Creating…" : "Create"}
              </Button>
            </div>
          </form>
        </CardContent>
      </Card>

      <Card>
        <CardHeader className="border-b">
          <CardTitle>All academic years</CardTitle>
        </CardHeader>
        <CardContent>
          {isLoading ? (
            <div className="text-sm text-muted-foreground">Loading…</div>
          ) : (
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Name</TableHead>
                  <TableHead>Status</TableHead>
                  <TableHead>Created</TableHead>
                  <TableHead />
                </TableRow>
              </TableHeader>
              <TableBody>
                {years.map((y) => (
                  <TableRow key={y.id}>
                    <TableCell className="font-medium">
                      {y.name ?? y.id}
                    </TableCell>
                    <TableCell>{y.status ?? "—"}</TableCell>
                    <TableCell className="text-muted-foreground">
                      {y.created_at ? new Date(y.created_at).toLocaleString() : "—"}
                    </TableCell>
                    <TableCell className="text-right">
                      <Button
                        size="sm"
                        variant="outline"
                        disabled={y.status !== "ended" || archivingId === y.id}
                        onClick={() => void archiveYear(y.id)}
                      >
                        {archivingId === y.id ? "Archiving…" : "Archive"}
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
