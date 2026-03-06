import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

type GuardResult =
  | { ok: true; adminClient: ReturnType<typeof createClient>; callerId: string }
  | { ok: false; status: number; body: unknown };

export async function requireAdmin(req: Request): Promise<GuardResult> {
  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const anonKey = Deno.env.get("SUPABASE_ANON_KEY");
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");

  if (!supabaseUrl || !anonKey || !serviceRoleKey) {
    return {
      ok: false,
      status: 500,
      body: {
        error:
          "Missing SUPABASE_URL, SUPABASE_ANON_KEY, or SUPABASE_SERVICE_ROLE_KEY.",
      },
    };
  }

  const authHeader = req.headers.get("Authorization") ?? "";

  const callerClient = createClient(supabaseUrl, anonKey, {
    global: { headers: { Authorization: authHeader } },
  });

  const { data, error } = await callerClient.auth.getUser();
  if (error || !data.user) {
    return { ok: false, status: 401, body: { error: "Unauthorized" } };
  }

  const adminClient = createClient(supabaseUrl, serviceRoleKey);
  const { data: profile, error: profileError } = await adminClient
    .from("profiles")
    .select("role")
    .eq("id", data.user.id)
    .maybeSingle();

  if (profileError) {
    return { ok: false, status: 500, body: { error: profileError.message } };
  }

  if (profile?.role !== "admin") {
    return { ok: false, status: 403, body: { error: "Forbidden" } };
  }

  return { ok: true, adminClient, callerId: data.user.id };
}
