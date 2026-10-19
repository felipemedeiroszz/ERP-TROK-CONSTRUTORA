-- Pagamentos recebidos por projeto (aba "Pagamento").
-- Registra cada valor recebido do contrato para calcular o percentual pago.

create table if not exists public.project_payments (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users (id) on delete cascade,
  project_id uuid not null references public.projects (id) on delete cascade,
  amount numeric(14, 2) not null default 0,
  payment_date date not null,
  description text,
  created_at timestamptz not null default now()
);

create index if not exists project_payments_project_idx on public.project_payments (project_id, payment_date desc);

alter table public.project_payments enable row level security;

drop policy if exists project_payments_owner_select on public.project_payments;
create policy project_payments_owner_select on public.project_payments for select to authenticated using (owner_id = (select auth.uid()));

drop policy if exists project_payments_owner_insert on public.project_payments;
create policy project_payments_owner_insert on public.project_payments for insert to authenticated with check (owner_id = (select auth.uid()));

drop policy if exists project_payments_owner_update on public.project_payments;
create policy project_payments_owner_update on public.project_payments for update to authenticated using (owner_id = (select auth.uid())) with check (owner_id = (select auth.uid()));

drop policy if exists project_payments_owner_delete on public.project_payments;
create policy project_payments_owner_delete on public.project_payments for delete to authenticated using (owner_id = (select auth.uid()));
