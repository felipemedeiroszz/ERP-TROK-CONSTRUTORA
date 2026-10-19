-- Schema principal do sistema de gestão financeira da Trox.
-- Todas as tabelas são isoladas por dono (owner_id = auth.uid()) via RLS.
-- Migração idempotente: pode ser aplicada mais de uma vez com segurança.

-- ---------------------------------------------------------------------------
-- Pessoas / entidades
-- ---------------------------------------------------------------------------

create table if not exists public.clients (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users (id) on delete cascade,
  full_name text not null,
  email text,
  phone text,
  city text,
  state text,
  address text,
  notes text,
  avatar_path text,
  created_at timestamptz not null default now()
);

create table if not exists public.employees (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users (id) on delete cascade,
  full_name text not null,
  position text,
  phone text,
  email text,
  is_active boolean not null default true,
  avatar_path text,
  created_at timestamptz not null default now()
);

create table if not exists public.suppliers (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users (id) on delete cascade,
  company_name text not null,
  contact_name text,
  email text,
  phone text,
  category text,
  tax_id text,
  address text,
  notes text,
  is_active boolean not null default true,
  avatar_path text,
  created_at timestamptz not null default now()
);

create table if not exists public.projects (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users (id) on delete cascade,
  code text not null,
  name text not null,
  client text,
  client_id uuid references public.clients (id) on delete set null,
  status text not null default 'planejamento',
  contract_value numeric(14, 2) not null default 0,
  progress integer not null default 0,
  start_date date,
  delivery_date date,
  description text,
  image_path text,
  image_name text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- ---------------------------------------------------------------------------
-- Documentos
-- ---------------------------------------------------------------------------

create table if not exists public.project_documents (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users (id) on delete cascade,
  project_id uuid not null references public.projects (id) on delete cascade,
  category text,
  file_name text not null,
  storage_path text not null,
  mime_type text,
  file_size bigint not null default 0,
  created_at timestamptz not null default now()
);

-- ---------------------------------------------------------------------------
-- Financeiro
-- ---------------------------------------------------------------------------

create table if not exists public.project_expenses (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users (id) on delete cascade,
  project_id uuid not null references public.projects (id) on delete cascade,
  name text not null,
  description text,
  expense_date date not null,
  amount numeric(14, 2) not null default 0,
  attachment_path text,
  attachment_name text,
  attachment_mime_type text,
  status text not null default 'pendente',
  created_at timestamptz not null default now()
);

create table if not exists public.project_revenues (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users (id) on delete cascade,
  project_id uuid not null references public.projects (id) on delete cascade,
  name text not null,
  description text,
  revenue_date date not null,
  amount numeric(14, 2) not null default 0,
  created_at timestamptz not null default now()
);

create table if not exists public.project_payables (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users (id) on delete cascade,
  project_id uuid not null references public.projects (id) on delete cascade,
  name text not null,
  description text,
  due_date date not null,
  amount numeric(14, 2) not null default 0,
  status text not null default 'pendente',
  created_at timestamptz not null default now()
);

create table if not exists public.project_receivables (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users (id) on delete cascade,
  project_id uuid not null references public.projects (id) on delete cascade,
  name text not null,
  description text,
  due_date date not null,
  amount numeric(14, 2) not null default 0,
  status text not null default 'pendente',
  created_at timestamptz not null default now()
);

-- ---------------------------------------------------------------------------
-- Operações: veículos, equipamentos, combustível, imóveis
-- ---------------------------------------------------------------------------

create table if not exists public.project_vehicles (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users (id) on delete cascade,
  name text not null,
  plate text,
  vehicle_type text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.project_vehicle_rentals (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users (id) on delete cascade,
  project_id uuid not null references public.projects (id) on delete cascade,
  vehicle_name text not null,
  supplier text,
  start_date date,
  end_date date,
  pricing_type text not null default 'diaria',
  rate numeric(14, 2) not null default 0,
  total numeric(14, 2) not null default 0,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.project_equipment_rentals (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users (id) on delete cascade,
  project_id uuid not null references public.projects (id) on delete cascade,
  equipment_name text not null,
  supplier text,
  start_date date,
  end_date date,
  daily_rate numeric(14, 2) not null default 0,
  total numeric(14, 2) not null default 0,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.project_fuel_expenses (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users (id) on delete cascade,
  project_id uuid not null references public.projects (id) on delete cascade,
  vehicle_name text,
  vehicle_source text not null default 'proprio',
  vehicle_id uuid references public.project_vehicles (id) on delete set null,
  expense_date date not null,
  amount numeric(14, 2) not null default 0,
  liters numeric(10, 2),
  station text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.project_property_rentals (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users (id) on delete cascade,
  project_id uuid not null references public.projects (id) on delete cascade,
  property_name text not null,
  address text,
  start_date date not null,
  end_date date not null,
  daily_rate numeric(14, 2) not null default 0,
  total numeric(14, 2) not null default 0,
  employee_ids uuid[] not null default '{}',
  assignees text[] not null default '{}',
  admin_assigned boolean not null default false,
  notes text,
  created_at timestamptz not null default now()
);

-- ---------------------------------------------------------------------------
-- Execução: atividades, marcos, tarefas e configurações
-- ---------------------------------------------------------------------------

create table if not exists public.project_activity_logs (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users (id) on delete cascade,
  project_id uuid not null references public.projects (id) on delete cascade,
  activity text not null,
  description text,
  activity_date date not null default current_date,
  created_at timestamptz not null default now()
);

create table if not exists public.project_milestones (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users (id) on delete cascade,
  project_id uuid not null references public.projects (id) on delete cascade,
  title text not null,
  description text,
  start_date date,
  due_date date,
  status text not null default 'pendente',
  created_at timestamptz not null default now()
);

create table if not exists public.project_tasks (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users (id) on delete cascade,
  project_id uuid not null references public.projects (id) on delete cascade,
  title text not null,
  description text,
  assignee text,
  due_date date,
  priority text not null default 'normal',
  status text not null default 'pendente',
  created_at timestamptz not null default now()
);

create table if not exists public.project_settings (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users (id) on delete cascade,
  project_id uuid not null references public.projects (id) on delete cascade,
  project_name text,
  project_description text,
  notify_deadlines boolean not null default true,
  notify_activities boolean not null default true,
  updated_at timestamptz not null default now(),
  constraint project_settings_project_id_key unique (project_id)
);

create table if not exists public.notification_reads (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users (id) on delete cascade,
  notification_key text not null,
  created_at timestamptz not null default now(),
  constraint notification_reads_owner_key unique (owner_id, notification_key)
);

-- ---------------------------------------------------------------------------
-- Índices
-- ---------------------------------------------------------------------------

create index if not exists projects_owner_idx on public.projects (owner_id, created_at desc);
create index if not exists clients_owner_idx on public.clients (owner_id);
create index if not exists employees_owner_idx on public.employees (owner_id);
create index if not exists suppliers_owner_idx on public.suppliers (owner_id);
create index if not exists project_documents_project_idx on public.project_documents (project_id);
create index if not exists project_expenses_project_idx on public.project_expenses (project_id, expense_date desc);
create index if not exists project_revenues_project_idx on public.project_revenues (project_id, revenue_date desc);
create index if not exists project_payables_project_idx on public.project_payables (project_id, due_date);
create index if not exists project_receivables_project_idx on public.project_receivables (project_id, due_date);
create index if not exists project_vehicles_owner_idx on public.project_vehicles (owner_id);
create index if not exists project_vehicle_rentals_project_idx on public.project_vehicle_rentals (project_id, start_date desc);
create index if not exists project_equipment_rentals_project_idx on public.project_equipment_rentals (project_id, start_date desc);
create index if not exists project_fuel_expenses_project_idx on public.project_fuel_expenses (project_id, expense_date desc);
create index if not exists project_property_rentals_project_idx on public.project_property_rentals (project_id, start_date desc);
create index if not exists project_activity_logs_project_idx on public.project_activity_logs (project_id, activity_date desc);
create index if not exists project_milestones_project_idx on public.project_milestones (project_id, due_date);
create index if not exists project_tasks_project_idx on public.project_tasks (project_id, due_date);
create index if not exists notification_reads_owner_idx on public.notification_reads (owner_id);

-- ---------------------------------------------------------------------------
-- RLS: cada usuário só acessa os próprios registros (owner_id = auth.uid())
-- ---------------------------------------------------------------------------

do $$
declare
  t text;
  tables text[] := array[
    'clients', 'employees', 'suppliers', 'projects',
    'project_documents', 'project_expenses', 'project_revenues',
    'project_payables', 'project_receivables',
    'project_vehicles', 'project_vehicle_rentals', 'project_equipment_rentals',
    'project_fuel_expenses', 'project_property_rentals',
    'project_activity_logs', 'project_milestones', 'project_tasks',
    'project_settings', 'notification_reads'
  ];
begin
  foreach t in array tables loop
    execute format('alter table public.%I enable row level security', t);

    execute format('drop policy if exists %I on public.%I', t || '_owner_select', t);
    execute format(
      'create policy %I on public.%I for select to authenticated using (owner_id = (select auth.uid()))',
      t || '_owner_select', t
    );

    execute format('drop policy if exists %I on public.%I', t || '_owner_insert', t);
    execute format(
      'create policy %I on public.%I for insert to authenticated with check (owner_id = (select auth.uid()))',
      t || '_owner_insert', t
    );

    execute format('drop policy if exists %I on public.%I', t || '_owner_update', t);
    execute format(
      'create policy %I on public.%I for update to authenticated using (owner_id = (select auth.uid())) with check (owner_id = (select auth.uid()))',
      t || '_owner_update', t
    );

    execute format('drop policy if exists %I on public.%I', t || '_owner_delete', t);
    execute format(
      'create policy %I on public.%I for delete to authenticated using (owner_id = (select auth.uid()))',
      t || '_owner_delete', t
    );
  end loop;
end $$;
