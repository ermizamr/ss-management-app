import { serve } from "https://deno.land/std@0.224.0/http/server.ts";

import { corsHeaders, corsPreflightResponse, jsonResponse } from "../_shared/cors.ts";
import { requireAdmin } from "../_shared/admin_guard.ts";

type SetAccountStatusBody = {
  user_id: string;
  account_status: string;
};

serve(async (req) => {
  if (req.method === "OPTIONS") return corsPreflightResponse();

  const guard = await requireAdmin(req);
  if (!guard.ok) {
    return jsonResponse(guard.body, { status: guard.status, headers: corsHeaders });
  }

  try {
    const body = (await req.json()) as Partial<SetAccountStatusBody>;
    const userId = (body.user_id ?? "").trim();
    const accountStatus = (body.account_status ?? "").trim();

    if (!userId || !accountStatus) {
      return jsonResponse(
        { error: "Missing required fields: user_id, account_status." },
        { status: 400 },
      );
    }

    const { error } = await guard.adminClient
      .from("profiles")
      .update({ account_status: accountStatus })
      .eq("id", userId);

    if (error) {
      return jsonResponse({ error: error.message }, { status: 400 });
    }

    return jsonResponse({ ok: true, user_id: userId, account_status: accountStatus });
  } catch (e) {
    return jsonResponse(
      { error: e instanceof Error ? e.message : "Unknown error" },
      { status: 500 },
    );
  }
});
