// Edge Function: define a senha/e-mail do administrador.
// Chame uma vez (POST), depois REMOVA a função para não deixar um backdoor.
//
// Deploy:
//   supabase functions deploy set-admin-password
//
// Supabase injeta SUPABASE_URL e SUPABASE_SERVICE_ROLE_KEY automaticamente.
// NUNCA coloque a service_role key no código.

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const ADMIN_USER_ID = "a6c8c814-7e83-4668-9e2b-ffa30e832326";
const ADMIN_EMAIL = "admin@troy.com";
const NEW_PASSWORD = "troyadmin2026";

Deno.serve(async (req: Request) => {
  if (req.method !== "POST") {
    return Response.json({ error: "Use o método POST" }, { status: 405 });
  }

  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");

  if (!supabaseUrl || !serviceRoleKey) {
    return Response.json({ error: "Configuração do servidor ausente" }, { status: 500 });
  }

  const supabaseAdmin = createClient(supabaseUrl, serviceRoleKey, {
    auth: { autoRefreshToken: false, persistSession: false },
  });

  const { data, error } = await supabaseAdmin.auth.admin.updateUserById(
    ADMIN_USER_ID,
    {
      email: ADMIN_EMAIL,
      password: NEW_PASSWORD,
      email_confirm: true,
    },
  );

  if (error) {
    return Response.json({ error: error.message }, { status: 400 });
  }

  return Response.json({
    success: true,
    user: { id: data.user.id, email: data.user.email },
  });
});
