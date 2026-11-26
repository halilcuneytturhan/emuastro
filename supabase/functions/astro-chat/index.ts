// EmuAstro sohbet: kullanıcının haritası + günün transitleri ile Claude'a sorar.
// Gerekli sırlar (supabase secrets set): ANTHROPIC_API_KEY
// SUPABASE_URL ve SUPABASE_SERVICE_ROLE_KEY Supabase tarafından otomatik sağlanır.
import { createClient } from "npm:@supabase/supabase-js@2.45.4";

const FREE_LIMIT = 1, PREMIUM_LIMIT = 5;

Deno.serve(async (req) => {
  const auth = req.headers.get("Authorization") ?? "";
  const admin = createClient(Deno.env.get("SUPABASE_URL")!, Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!);
  const { data: { user } } = await admin.auth.getUser(auth.replace("Bearer ", ""));
  if (!user) return json({ error: "Giriş gerekli" }, 401);

  const { question, chartSummary } = await req.json();
  if (typeof question !== "string" || question.length > 500) return json({ error: "Soru geçersiz" }, 400);

  const { data: prof } = await admin.from("profiles").select("premium_until").eq("id", user.id).single();
  const premium = prof?.premium_until && new Date(prof.premium_until) > new Date();
  const limit = premium ? PREMIUM_LIMIT : FREE_LIMIT;
  const today = new Date().toISOString().slice(0, 10);
  const { data: use } = await admin.from("chat_usage").select("count").eq("user_id", user.id).eq("day", today).maybeSingle();
  if ((use?.count ?? 0) >= limit) return json({ error: "limit", limit }, 429);

  const r = await fetch("https://api.anthropic.com/v1/messages", {
    method: "POST",
    headers: {
      "x-api-key": Deno.env.get("ANTHROPIC_API_KEY")!,
      "anthropic-version": "2023-06-01",
      "content-type": "application/json",
    },
    body: JSON.stringify({
      model: "claude-haiku-5-5",
      max_tokens: 600,
      system: "Sen EmuAstro'nun Türkçe astroloji asistanısın. Kısa, sıcak ve somut yanıt ver. Tıbbi, finansal veya hukuki tavsiye verme; kesin gelecek iddiasında bulunma. Kullanıcının haritası ve günün transitleri:\n" + String(chartSummary ?? "").slice(0, 3000),
      messages: [{ role: "user", content: question }],
    }),
  });
  if (!r.ok) return json({ error: "Yanıt alınamadı" }, 502);
  const out = await r.json();
  const answer = out.content?.[0]?.text ?? "";
  await admin.from("chat_usage").upsert({ user_id: user.id, day: today, count: (use?.count ?? 0) + 1 });
  return json({ answer, remaining: limit - (use?.count ?? 0) - 1 });
});

const json = (b: unknown, s = 200) =>
  new Response(JSON.stringify(b), { status: s, headers: { "content-type": "application/json" } });
