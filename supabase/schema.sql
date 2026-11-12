-- CHẤM CÔNG PRO: chạy toàn bộ script này trong Supabase SQL Editor
create extension if not exists pgcrypto;

create table if not exists public.shifts (
 id uuid primary key default gen_random_uuid(),
 user_id uuid not null references auth.users(id) on delete cascade,
 work_date date not null,
 company text not null,
 position text,
 start_time time not null,
 end_time time not null,
 actual_checkin time,
 actual_checkout time,
 hourly_wage numeric(12,2) not null default 0,
 extra_pay numeric(12,2) not null default 0,
 reminder_minutes integer not null default 0,
 notes text,
 completed boolean not null default false,
 created_at timestamptz not null default now(),
 updated_at timestamptz not null default now(),
 constraint shifts_nonnegative_pay check (hourly_wage >= 0 and extra_pay >= 0),
 constraint shifts_valid_reminder check (reminder_minutes in (0,10,20,30,60,120))
);
create table if not exists public.templates (
 id uuid primary key default gen_random_uuid(),
 user_id uuid not null references auth.users(id) on delete cascade,
 kind text not null check (kind in ('company','position','wage')),
 name text not null,
 amount numeric(12,2),
 color text,
 created_at timestamptz not null default now()
);
create index if not exists shifts_user_date_idx on public.shifts(user_id, work_date);
create index if not exists templates_user_kind_idx on public.templates(user_id, kind);
alter table public.shifts enable row level security;
alter table public.templates enable row level security;
drop policy if exists "Users manage own shifts" on public.shifts;
create policy "Users manage own shifts" on public.shifts for all to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);
drop policy if exists "Users manage own templates" on public.templates;
create policy "Users manage own templates" on public.templates for all to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);
grant select,insert,update,delete on public.shifts to authenticated;
grant select,insert,update,delete on public.templates to authenticated;


-- CHẤM CÔNG PRO 2.0: lịch dự kiến và ngày OFF
create table if not exists public.planned_shifts (
 id uuid primary key default gen_random_uuid(),
 user_id uuid not null references auth.users(id) on delete cascade,
 work_date date not null,
 company text not null,
 position text,
 start_time time not null,
 end_time time not null,
 created_at timestamptz not null default now(),
 updated_at timestamptz not null default now(),
 constraint planned_shifts_valid_time check (end_time > start_time)
);
create index if not exists planned_shifts_user_date_idx on public.planned_shifts(user_id, work_date);
alter table public.planned_shifts enable row level security;
drop policy if exists "Users manage own planned shifts" on public.planned_shifts;
create policy "Users manage own planned shifts" on public.planned_shifts for all to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);
grant select,insert,update,delete on public.planned_shifts to authenticated;

create table if not exists public.off_days (
 id uuid primary key default gen_random_uuid(),
 user_id uuid not null references auth.users(id) on delete cascade,
 work_date date not null,
 created_at timestamptz not null default now(),
 unique(user_id, work_date)
);
create index if not exists off_days_user_date_idx on public.off_days(user_id, work_date);
alter table public.off_days enable row level security;
drop policy if exists "Users manage own off days" on public.off_days;
create policy "Users manage own off days" on public.off_days for all to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);
grant select,insert,update,delete on public.off_days to authenticated;

-- Enable live updates for supported tables. Ignore if already published.
do $$
begin
 if not exists (select 1 from pg_publication_tables where pubname='supabase_realtime' and schemaname='public' and tablename='shifts') then
  alter publication supabase_realtime add table public.shifts;
 end if;
 if not exists (select 1 from pg_publication_tables where pubname='supabase_realtime' and schemaname='public' and tablename='templates') then
  alter publication supabase_realtime add table public.templates;
 end if;
 if not exists (select 1 from pg_publication_tables where pubname='supabase_realtime' and schemaname='public' and tablename='planned_shifts') then
  alter publication supabase_realtime add table public.planned_shifts;
 end if;
 if not exists (select 1 from pg_publication_tables where pubname='supabase_realtime' and schemaname='public' and tablename='off_days') then
  alter publication supabase_realtime add table public.off_days;
 end if;
end $$;
