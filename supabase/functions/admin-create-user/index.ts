import { serve } from "https://deno.land/std@0.224.0/http/server.ts";

import { corsHeaders, corsPreflightResponse, jsonResponse } from "../_shared/cors.ts";
import { requireAdmin } from "../_shared/admin_guard.ts";

type CreateUserBody = {
  email?: string;
  password: string;
  role: string;
  academic_id: string;
  name: string;
  grade_id?: string | null;
};

serve(async (req) => {
  if (req.method === "OPTIONS") return corsPreflightResponse();

  const guard = await requireAdmin(req);
  if (!guard.ok) {
    return jsonResponse(guard.body, { status: guard.status, headers: corsHeaders });
  }

  try {
    const body = (await req.json()) as Partial<CreateUserBody>;

    const password = (body.password ?? "").trim();
    const role = (body.role ?? "").trim();
    const academicId = (body.academic_id ?? "").trim();
    const name = (body.name ?? "").trim();

    if (!password || !role || !academicId || !name) {
      return jsonResponse(
        {
          error: "Missing required fields: password, role, academic_id, name.",
        },
        { status: 400 },
      );
    }

    const email = (body.email ?? "").trim() || `${academicId}@school.local`;

    const { data: created, error: createError } =
      await guard.adminClient.auth.admin.createUser({
        email,
        password,
        email_confirm: true,
      });

    if (createError || !created.user) {
      return jsonResponse(
        { error: createError?.message ?? "Failed to create user" },
        { status: 400 },
      );
    }

    const userId = created.user.id;

    const { error: profileError } = await guard.adminClient
      .from("profiles")
      .upsert({
        id: userId,
        name,
        role,
        academic_id: academicId,
        grade_id: body.grade_id ?? null,
        account_status: "active",
      });

    if (profileError) {
      return jsonResponse({ error: profileError.message }, { status: 400 });
    }

    return jsonResponse({ user_id: userId, email });
  } catch (e) {
    return jsonResponse(
      { error: e instanceof Error ? e.message : "Unknown error" },
      { status: 500 },
    );
  }
});
