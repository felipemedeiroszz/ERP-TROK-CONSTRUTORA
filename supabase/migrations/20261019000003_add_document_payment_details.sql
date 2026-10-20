-- Dados adicionais do "Pagamento de funcionário": destinatário e período (de/até) do pagamento.

alter table public.project_documents
  add column if not exists recipient_name text,
  add column if not exists payment_period_start date,
  add column if not exists payment_period_end date;
