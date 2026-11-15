-- Chạy một lần trong Supabase Dashboard → SQL Editor.
-- Tạo bảng ghi chú theo ngày dùng chung cho Lịch chấm công và Lịch dự kiến.
create table if not exists public.shift_day_notes (
 id uuid primary key default gen_random_uuid(),
 user_id uuid not null references auth.users(id) on delete cascade,
 work_date date not null,
 note text not null default '',
 created_at timestamptz not null default now(),
 updated_at timestamptz not null default now(),
 unique(user_id, work_date)
);
create index if not exists shift_day_notes_user_date_idx on public.shift_day_notes(user_id, work_date);
alter table public.shift_day_notes enable row level security;
drop policy if exists "Users manage own shift day notes" on public.shift_day_notes;
create policy "Users manage own shift day notes" on public.shift_day_notes for all to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);
grant select,insert,update,delete on public.shift_day_notes to authenticated;
do $$
begin
 if not exists (select 1 from pg_publication_tables where pubname='supabase_realtime' and schemaname='public' and tablename='shift_day_notes') then
  alter publication supabase_realtime add table public.shift_day_notes;
 end if;
end $$;
