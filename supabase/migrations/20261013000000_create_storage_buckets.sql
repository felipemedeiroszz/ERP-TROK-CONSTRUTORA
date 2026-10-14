-- Buckets usados pelo sistema:
-- project-documents: documentos, anexos e imagens dos projetos
-- people-avatars: fotos de clientes, funcionários e fornecedores
-- Ambos permanecem privados; a aplicação usa URLs assinadas.

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values
  ('project-documents', 'project-documents', false, 10485760, array['image/*', 'application/pdf', 'text/plain', 'application/msword', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document', 'application/vnd.ms-excel', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet']),
  ('people-avatars', 'people-avatars', false, 5242880, array['image/jpeg', 'image/png', 'image/webp', 'image/gif'])
on conflict (id) do update set
  public = excluded.public,
  file_size_limit = excluded.file_size_limit,
  allowed_mime_types = excluded.allowed_mime_types;

-- Cada arquivo precisa começar pelo UUID do usuário autenticado.
-- Exemplo: <user_id>/<project_id>/arquivo.pdf

drop policy if exists "project documents authenticated upload" on storage.objects;
create policy "project documents authenticated upload"
on storage.objects for insert to authenticated
with check (
  bucket_id = 'project-documents'
  and (storage.foldername(name))[1] = (select auth.uid()::text)
);

drop policy if exists "project documents authenticated read" on storage.objects;
create policy "project documents authenticated read"
on storage.objects for select to authenticated
using (
  bucket_id = 'project-documents'
  and (storage.foldername(name))[1] = (select auth.uid()::text)
);

drop policy if exists "project documents authenticated update" on storage.objects;
create policy "project documents authenticated update"
on storage.objects for update to authenticated
using (
  bucket_id = 'project-documents'
  and (storage.foldername(name))[1] = (select auth.uid()::text)
)
with check (
  bucket_id = 'project-documents'
  and (storage.foldername(name))[1] = (select auth.uid()::text)
);

drop policy if exists "project documents authenticated delete" on storage.objects;
create policy "project documents authenticated delete"
on storage.objects for delete to authenticated
using (
  bucket_id = 'project-documents'
  and (storage.foldername(name))[1] = (select auth.uid()::text)
);

drop policy if exists "people avatars authenticated upload" on storage.objects;
create policy "people avatars authenticated upload"
on storage.objects for insert to authenticated
with check (
  bucket_id = 'people-avatars'
  and (storage.foldername(name))[1] = (select auth.uid()::text)
);

drop policy if exists "people avatars authenticated read" on storage.objects;
create policy "people avatars authenticated read"
on storage.objects for select to authenticated
using (
  bucket_id = 'people-avatars'
  and (storage.foldername(name))[1] = (select auth.uid()::text)
);

drop policy if exists "people avatars authenticated update" on storage.objects;
create policy "people avatars authenticated update"
on storage.objects for update to authenticated
using (
  bucket_id = 'people-avatars'
  and (storage.foldername(name))[1] = (select auth.uid()::text)
)
with check (
  bucket_id = 'people-avatars'
  and (storage.foldername(name))[1] = (select auth.uid()::text)
);

drop policy if exists "people avatars authenticated delete" on storage.objects;
create policy "people avatars authenticated delete"
on storage.objects for delete to authenticated
using (
  bucket_id = 'people-avatars'
  and (storage.foldername(name))[1] = (select auth.uid()::text)
);
