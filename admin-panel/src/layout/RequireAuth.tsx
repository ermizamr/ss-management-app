import * as React from "react";
import { Navigate, Outlet, useLocation } from "react-router";

import { useAuth } from "../auth/AuthProvider";
import { supabase } from "../lib/supabase";
import { ErrorBanner } from "../components/ErrorBanner";
import { Button } from "../components/ui/button";

export function RequireAuth() {
  const { session, isLoading, signOut } = useAuth();
  const location = useLocation();

  const [adminCheck, setAdminCheck] = React.useState<
    | { status: "idle" }
    | { status: "loading" }
    | { status: "ok" }
    | { status: "not-admin" }
    | { status: "error"; message: string }
  >({ status: "idle" });

  const userId = session?.user?.id ?? null;

  React.useEffect(() => {
    let cancelled = false;

    async function run() {
      if (isLoading) return;

      if (!userId) {
        setAdminCheck({ status: "idle" });
        return;
      }

      setAdminCheck({ status: "loading" });

      const { data, error } = await supabase
        .from("profiles")
        .select("role")
        .eq("id", userId)
        .maybeSingle();

      if (cancelled) return;

      if (error) {
        setAdminCheck({ status: "error", message: error.message });
        return;
      }

      if (data?.role !== "admin") {
        setAdminCheck({ status: "not-admin" });
        return;
      }

      setAdminCheck({ status: "ok" });
    }

    void run();
    return () => {
      cancelled = true;
    };
  }, [isLoading, userId]);

  React.useEffect(() => {
    if (adminCheck.status !== "not-admin") return;
    if (!session) return;
    void signOut();
  }, [adminCheck.status, session, signOut]);

  if (isLoading) {
    return (
      <div className="flex min-h-svh items-center justify-center">
        <div className="text-sm text-muted-foreground">Loading…</div>
      </div>
    );
  }

  if (!session) {
    return (
      <Navigate
        to="/sign-in"
        replace
        state={{ from: location.pathname + location.search }}
      />
    );
  }

  if (adminCheck.status === "loading" || adminCheck.status === "idle") {
    return (
      <div className="flex min-h-svh items-center justify-center">
        <div className="text-sm text-muted-foreground">Verifying admin access…</div>
      </div>
    );
  }

  if (adminCheck.status === "not-admin") {
    return (
      <Navigate
        to="/sign-in"
        replace
        state={{
          from: location.pathname + location.search,
          message: "Not an admin. Please sign in with an admin account.",
        }}
      />
    );
  }

  if (adminCheck.status === "error") {
    return (
      <div className="flex min-h-svh items-center justify-center px-4">
        <div className="w-full max-w-md">
          <ErrorBanner
            title="Unable to verify admin access"
            message={adminCheck.message}
          />
          <div className="mt-3 flex justify-end">
            <Button variant="outline" onClick={() => void signOut()}>
              Sign out
            </Button>
          </div>
        </div>
      </div>
    );
  }

  return <Outlet />;
}
