import { serve } from "https://deno.land/std@0.224.0/http/server.ts";

import { corsHeaders, corsPreflightResponse, jsonResponse } from "../_shared/cors.ts";
import { requireAdmin } from "../_shared/admin_guard.ts";

type ResetPasswordBody = {
  user_id: string;
  new_password: string;
};

serve(async (req) => {
  if (req.method === "OPTIONS") return corsPreflightResponse();

  const guard = await requireAdmin(req);
  if (!guard.ok) {
    return jsonResponse(guard.body, { status: guard.status, headers: corsHeaders });
  }

  try {
    const body = (await req.json()) as Partial<ResetPasswordBody>;
    const userId = (body.user_id ?? "").trim();
    const newPassword = (body.new_password ?? "").trim();

    if (!userId || !newPassword) {
      return jsonResponse(
        { error: "Missing required fields: user_id, new_password." },
        { status: 400 },
      );
    }

    const { data, error } = await guard.adminClient.auth.admin.updateUserById(
      userId,
      { password: newPassword },
    );

    if (error) {
      return jsonResponse({ error: error.message }, { status: 400 });
    }

    return jsonResponse({ ok: true, user_id: data.user?.id ?? userId });
  } catch (e) {
    return jsonResponse(
      { error: e instanceof Error ? e.message : "Unknown error" },
      { status: 500 },
    );
  }
});
