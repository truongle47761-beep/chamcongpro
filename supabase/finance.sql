-- CHẤM CÔNG PRO — Thu/Chi, Mục tiêu và Kho mẫu
-- Chạy riêng một lần trong Supabase Dashboard > SQL Editor.
-- Các bảng mới độc lập với shifts, templates, planned_shifts và off_days.
create table if not exists public.finance_transactions (
 id uuid primary key default gen_random_uuid(),
 user_id uuid not null references auth.users(id) on delete cascade,
 entry_type text not null check (entry_type in ('income','expense')),
 title text not null, category text, job text,
 amount numeric(14,2) not null check (amount > 0),
 entry_date date not null default current_date, note text,
 created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create index if not exists finance_transactions_user_date_idx on public.finance_transactions(user_id,entry_date desc);
create table if not exists public.finance_goals (
 id uuid primary key default gen_random_uuid(),
 user_id uuid not null references auth.users(id) on delete cascade,
 title text not null, target_amount numeric(14,2) not null check(target_amount>0),
 saved_amount numeric(14,2) not null default 0 check(saved_amount>=0),
 start_date date, due_date date, note text,
 created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create index if not exists finance_goals_user_created_idx on public.finance_goals(user_id,created_at desc);
create table if not exists public.finance_templates (
 id uuid primary key default gen_random_uuid(),
 user_id uuid not null references auth.users(id) on delete cascade,
 template_type text not null check(template_type in ('income','expense','goal')),
 name text not null, category text, job text,
 amount numeric(14,2) not null default 0 check(amount>=0), note text,
 created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create index if not exists finance_templates_user_type_idx on public.finance_templates(user_id,template_type);
create table if not exists public.finance_categories (
 id uuid primary key default gen_random_uuid(),
 user_id uuid not null references auth.users(id) on delete cascade,
 kind text not null check(kind in ('income','expense','goal')),
 name text not null, created_at timestamptz not null default now(),
 unique(user_id,kind,name)
);
create index if not exists finance_categories_user_kind_idx on public.finance_categories(user_id,kind);
alter table public.finance_transactions enable row level security;
alter table public.finance_goals enable row level security;
alter table public.finance_templates enable row level security;
alter table public.finance_categories enable row level security;
drop policy if exists "Users manage own finance transactions" on public.finance_transactions;
create policy "Users manage own finance transactions" on public.finance_transactions for all to authenticated using(auth.uid()=user_id) with check(auth.uid()=user_id);
drop policy if exists "Users manage own finance goals" on public.finance_goals;
create policy "Users manage own finance goals" on public.finance_goals for all to authenticated using(auth.uid()=user_id) with check(auth.uid()=user_id);
drop policy if exists "Users manage own finance templates" on public.finance_templates;
create policy "Users manage own finance templates" on public.finance_templates for all to authenticated using(auth.uid()=user_id) with check(auth.uid()=user_id);
drop policy if exists "Users manage own finance categories" on public.finance_categories;
create policy "Users manage own finance categories" on public.finance_categories for all to authenticated using(auth.uid()=user_id) with check(auth.uid()=user_id);
grant select,insert,update,delete on public.finance_transactions to authenticated;
grant select,insert,update,delete on public.finance_goals to authenticated;
grant select,insert,update,delete on public.finance_templates to authenticated;
grant select,insert,update,delete on public.finance_categories to authenticated;
do $$
begin
 if not exists(select 1 from pg_publication_tables where pubname='supabase_realtime' and schemaname='public' and tablename='finance_transactions') then alter publication supabase_realtime add table public.finance_transactions; end if;
 if not exists(select 1 from pg_publication_tables where pubname='supabase_realtime' and schemaname='public' and tablename='finance_goals') then alter publication supabase_realtime add table public.finance_goals; end if;
 if not exists(select 1 from pg_publication_tables where pubname='supabase_realtime' and schemaname='public' and tablename='finance_templates') then alter publication supabase_realtime add table public.finance_templates; end if;
 if not exists(select 1 from pg_publication_tables where pubname='supabase_realtime' and schemaname='public' and tablename='finance_categories') then alter publication supabase_realtime add table public.finance_categories; end if;
end $$;


-- Vị trí lưu giữ tiền / ví / ngân hàng cho từng khoản thu chi.
alter table public.finance_transactions add column if not exists payment_method text not null default 'cash' check(payment_method in ('cash','transfer'));
alter table public.finance_transactions add column if not exists account_name text;
alter table public.finance_templates add column if not exists payment_method text not null default 'cash' check(payment_method in ('cash','transfer'));
alter table public.finance_templates add column if not exists account_name text;
create table if not exists public.finance_accounts (
 id uuid primary key default gen_random_uuid(),
 user_id uuid not null references auth.users(id) on delete cascade,
 name text not null,
 created_at timestamptz not null default now(),
 unique(user_id,name)
);
create index if not exists finance_accounts_user_name_idx on public.finance_accounts(user_id,name);
alter table public.finance_accounts enable row level security;
drop policy if exists "Users manage own finance accounts" on public.finance_accounts;
create policy "Users manage own finance accounts" on public.finance_accounts for all to authenticated using(auth.uid()=user_id) with check(auth.uid()=user_id);
grant select,insert,update,delete on public.finance_accounts to authenticated;
do $$
begin
 if not exists(select 1 from pg_publication_tables where pubname='supabase_realtime' and schemaname='public' and tablename='finance_accounts') then alter publication supabase_realtime add table public.finance_accounts; end if;
end $$;
