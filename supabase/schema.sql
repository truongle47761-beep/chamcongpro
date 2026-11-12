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
