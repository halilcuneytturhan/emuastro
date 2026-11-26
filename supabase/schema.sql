-- EmuAstro Supabase şeması. Yeni (ayrı) projede SQL Editor'da bir kez çalıştırılır.
-- Kimlik: Supabase Auth (anonim giriş açık olmalı: Authentication > Providers > Anonymous).

create extension if not exists pgcrypto;

-- Profil: her kullanıcı yalnız kendi satırını okur/yazar.
create table if not exists public.profiles (
  id uuid primary key references auth.users on delete cascade,
  name text not null default '',
  username text unique check (username ~ '^[a-z0-9_.]{3,20}$'),
  birth_local timestamp,
  birth_place text,
  phone_hash text,               -- sha256(normalize(telefon)); düz numara saklanmaz
  premium_until timestamptz,
  created_at timestamptz not null default now()
);
alter table public.profiles enable row level security;
create policy "own profile read" on public.profiles for select using (auth.uid() = id);
create policy "own profile insert" on public.profiles for insert with check (auth.uid() = id);
create policy "own profile update" on public.profiles for update using (auth.uid() = id)
  with check (auth.uid() = id);
-- premium_until istemciden değiştirilemez:
revoke update (premium_until) on public.profiles from authenticated, anon;

-- Rehber eşleştirme: istemci yalnız hash listesi gönderir, yalnız eşleşen
-- kullanıcıların kullanıcı adı ve ismi döner. Rehber kaydedilmez.
create or replace function public.match_contacts(hashes text[])
returns table (id uuid, name text, username text)
language sql security definer set search_path = public as $$
  select p.id, p.name, p.username from profiles p
  where p.phone_hash = any(hashes) and p.id <> auth.uid()
  limit 500;
$$;
revoke all on function public.match_contacts(text[]) from public, anon;
grant execute on function public.match_contacts(text[]) to authenticated;

-- Kullanıcı adıyla arama (yalnız herkese açık alanlar).
create or replace function public.find_user(uname text)
returns table (id uuid, name text, username text)
language sql security definer set search_path = public as $$
  select id, name, username from profiles where username = lower(uname) limit 1;
$$;
grant execute on function public.find_user(text) to authenticated;

-- Hediye kodları: sunucuda üretilir/doğrulanır, kişi başı 3 hak.
create table if not exists public.gift_codes (
  code text primary key,
  sender uuid not null references auth.users on delete cascade,
  redeemed_by uuid references auth.users,
  redeemed_at timestamptz,
  created_at timestamptz not null default now()
);
alter table public.gift_codes enable row level security;
create policy "sender reads own codes" on public.gift_codes for select using (auth.uid() = sender);

create or replace function public.create_gift_code()
returns text language plpgsql security definer set search_path = public as $$
declare c text; n int;
begin
  select count(*) into n from gift_codes where sender = auth.uid();
  if n >= 3 then raise exception 'Hediye hakkın kalmadı'; end if;
  c := 'EMU-' || upper(substr(encode(gen_random_bytes(6), 'hex'), 1, 6)) || '-'
       || upper(substr(encode(gen_random_bytes(1), 'hex'), 1, 1));
  insert into gift_codes(code, sender) values (c, auth.uid());
  return c;
end $$;

create or replace function public.redeem_gift_code(c text)
returns timestamptz language plpgsql security definer set search_path = public as $$
declare g gift_codes; until timestamptz;
begin
  select * into g from gift_codes where code = upper(trim(c)) for update;
  if not found then raise exception 'Kod geçersiz'; end if;
  if g.sender = auth.uid() then raise exception 'Kendi kodunu kullanamazsın'; end if;
  if g.redeemed_by is not null then raise exception 'Bu kod kullanılmış'; end if;
  until := now() + interval '3 days';
  update gift_codes set redeemed_by = auth.uid(), redeemed_at = now() where code = g.code;
  update profiles set premium_until = greatest(coalesce(premium_until, now()), until)
    where id = auth.uid();
  return until;
end $$;
revoke all on function public.create_gift_code() from public, anon;
revoke all on function public.redeem_gift_code(text) from public, anon;
grant execute on function public.create_gift_code() to authenticated;
grant execute on function public.redeem_gift_code(text) to authenticated;

-- Sohbet kotası: Edge Function service role ile yazar.
create table if not exists public.chat_usage (
  user_id uuid not null references auth.users on delete cascade,
  day date not null default current_date,
  count int not null default 0,
  primary key (user_id, day)
);
alter table public.chat_usage enable row level security;
create policy "own usage read" on public.chat_usage for select using (auth.uid() = user_id);

-- Bildirim için cihaz jetonları.
create table if not exists public.push_tokens (
  user_id uuid not null references auth.users on delete cascade,
  token text not null,
  platform text not null check (platform in ('ios','android')),
  updated_at timestamptz not null default now(),
  primary key (user_id, token)
);
alter table public.push_tokens enable row level security;
create policy "own tokens" on public.push_tokens for all using (auth.uid() = user_id)
  with check (auth.uid() = user_id);
