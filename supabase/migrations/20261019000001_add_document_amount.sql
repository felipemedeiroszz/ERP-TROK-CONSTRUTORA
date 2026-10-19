-- Adiciona o valor pago em documentos (usado pela categoria "Pagamento de funcionário").
-- Mantém is_paid para que a migração seja autossuficiente e idempotente.

alter table public.project_documents
  add column if not exists is_paid boolean not null default false,
  add column if not exists amount numeric(14, 2);
