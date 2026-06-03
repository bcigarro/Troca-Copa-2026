create extension if not exists "pgcrypto";

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text not null,
  city text,
  state text,
  district text,
  whatsapp text,
  show_whatsapp boolean default false,
  contact_preference text,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create table if not exists public.stickers (
  id uuid primary key default gen_random_uuid(),
  code text not null unique,
  number integer not null,
  name text not null,
  team text,
  category text,
  type text default 'comum',
  sort_order integer,
  is_special boolean default false,
  created_at timestamptz default now()
);

create table if not exists public.user_stickers (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  sticker_id uuid not null references public.stickers(id) on delete cascade,
  quantity integer not null default 0 check (quantity >= 0),
  wanted boolean not null default false,
  updated_at timestamptz default now(),
  unique (user_id, sticker_id)
);

create table if not exists public.trade_interests (
  id uuid primary key default gen_random_uuid(),
  from_user_id uuid not null references auth.users(id) on delete cascade,
  to_user_id uuid not null references auth.users(id) on delete cascade,
  status text not null default 'pending',
  created_at timestamptz default now(),
  updated_at timestamptz default now(),
  constraint trade_interests_status_check check (status in ('pending', 'accepted', 'rejected', 'cancelled', 'completed')),
  constraint trade_interests_distinct_users_check check (from_user_id <> to_user_id)
);

create table if not exists public.trade_interest_items (
  id uuid primary key default gen_random_uuid(),
  trade_interest_id uuid not null references public.trade_interests(id) on delete cascade,
  sticker_id uuid not null references public.stickers(id) on delete cascade,
  from_user_id uuid not null references auth.users(id) on delete cascade,
  to_user_id uuid not null references auth.users(id) on delete cascade
);

create index if not exists stickers_search_idx on public.stickers (number, code, team, category);
create index if not exists user_stickers_user_idx on public.user_stickers (user_id);
create index if not exists user_stickers_sticker_idx on public.user_stickers (sticker_id);
create index if not exists trade_interests_users_idx on public.trade_interests (from_user_id, to_user_id, status);

create or replace function public.set_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists set_profiles_updated_at on public.profiles;
create trigger set_profiles_updated_at before update on public.profiles for each row execute function public.set_updated_at();
drop trigger if exists set_user_stickers_updated_at on public.user_stickers;
create trigger set_user_stickers_updated_at before update on public.user_stickers for each row execute function public.set_updated_at();
drop trigger if exists set_trade_interests_updated_at on public.trade_interests;
create trigger set_trade_interests_updated_at before update on public.trade_interests for each row execute function public.set_updated_at();

alter table public.profiles enable row level security;
alter table public.stickers enable row level security;
alter table public.user_stickers enable row level security;
alter table public.trade_interests enable row level security;
alter table public.trade_interest_items enable row level security;

create policy "authenticated users can read exchange profiles" on public.profiles for select to authenticated using (true);
create policy "users can insert own profile" on public.profiles for insert to authenticated with check (id = auth.uid());
create policy "users can update own profile" on public.profiles for update to authenticated using (id = auth.uid()) with check (id = auth.uid());
create policy "users can delete own profile" on public.profiles for delete to authenticated using (id = auth.uid());
create policy "authenticated users can read stickers" on public.stickers for select to authenticated using (true);
create policy "users can read own collection" on public.user_stickers for select to authenticated using (user_id = auth.uid());
create policy "users can insert own collection" on public.user_stickers for insert to authenticated with check (user_id = auth.uid());
create policy "users can update own collection" on public.user_stickers for update to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy "users can delete own collection" on public.user_stickers for delete to authenticated using (user_id = auth.uid());
create policy "users can read involved trade interests" on public.trade_interests for select to authenticated using (from_user_id = auth.uid() or to_user_id = auth.uid());
create policy "users can create outbound trade interests" on public.trade_interests for insert to authenticated with check (from_user_id = auth.uid());
create policy "senders can cancel pending interests" on public.trade_interests for update to authenticated using (from_user_id = auth.uid() and status = 'pending') with check (from_user_id = auth.uid() and status = 'cancelled');
create policy "recipients can answer pending interests" on public.trade_interests for update to authenticated using (to_user_id = auth.uid() and status = 'pending') with check (to_user_id = auth.uid() and status in ('accepted', 'rejected'));
create policy "involved users can complete accepted interests" on public.trade_interests for update to authenticated using ((from_user_id = auth.uid() or to_user_id = auth.uid()) and status = 'accepted') with check ((from_user_id = auth.uid() or to_user_id = auth.uid()) and status = 'completed');
create policy "users can read involved trade items" on public.trade_interest_items for select to authenticated using (exists (select 1 from public.trade_interests ti where ti.id = trade_interest_id and (ti.from_user_id = auth.uid() or ti.to_user_id = auth.uid())));
create policy "senders can create trade items" on public.trade_interest_items for insert to authenticated with check (from_user_id = auth.uid());
