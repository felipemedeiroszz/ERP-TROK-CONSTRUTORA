-- Adiciona o controle de pagamento aos documentos (usado pela categoria Invoice).
-- Migração idempotente: pode ser aplicada mais de uma vez com segurança.

alter table public.project_documents
  add column if not exists is_paid boolean not null default false;
