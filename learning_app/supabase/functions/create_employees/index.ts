// supabase/functions/create_employees/index.ts

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

serve(async (req) => {
  const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
  const SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
  const supabase = createClient(SUPABASE_URL, SERVICE_ROLE_KEY);

  const { employees } = await req.json(); // Expecting a list

  const results = [];

  for (const emp of employees) {
    const { email, password, full_name, role, department } = emp;

    // Create Supabase Auth user
    const { data: user, error: authError } = await supabase.auth.admin.createUser({
      email,
      password,
      email_confirm: true,
    });

    if (authError || !user) {
      results.push({ email, status: "error", message: authError.message });
      continue;
    }

    // Insert into employees table
    const { error: insertError } = await supabase.from("employees").insert({
      full_name,
      email,
      role,
      department,
      supabase_user_id: user.user.id,
    });

    if (insertError) {
      results.push({ email, status: "error", message: insertError.message });
    } else {
      results.push({ email, status: "success" });
    }
  }

  return new Response(JSON.stringify({ results }), {
    headers: { "Content-Type": "application/json" },
    status: 200,
  });
});

