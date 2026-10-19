-- Recria o usuário administrador com e-mail e senha definidos.
--
-- ATENÇÃO: "delete from auth.users" apaga em cascata todos os dados do dono
-- (owner_id ... on delete cascade). Use somente com o banco VAZIO.
-- Rode uma vez no SQL Editor do Supabase. Ajuste as variáveis abaixo se quiser.

create extension if not exists pgcrypto with schema extensions;

do $$
declare
  v_email text := 'admin@troy.com';
  v_password text := 'Eduardo02';
  v_full_name text := 'Administrador';
  v_user_id uuid;
begin
  -- Remove o administrador anterior com o mesmo e-mail (cascade limpa os dados dele).
  delete from auth.users where email = v_email;

  v_user_id := gen_random_uuid();

  insert into auth.users (
    instance_id,
    id,
    aud,
    role,
    email,
    encrypted_password,
    email_confirmed_at,
    confirmation_token,
    recovery_token,
    email_change_token_new,
    email_change,
    email_change_token_current,
    phone_change,
    phone_change_token,
    reauthentication_token,
    raw_app_meta_data,
    raw_user_meta_data,
    created_at,
    updated_at
  ) values (
    '00000000-0000-0000-0000-000000000000',
    v_user_id,
    'authenticated',
    'authenticated',
    v_email,
    extensions.crypt(v_password, extensions.gen_salt('bf')),
    now(),
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '{"provider":"email","providers":["email"]}'::jsonb,
    jsonb_build_object('full_name', v_full_name, 'name', v_full_name),
    now(),
    now()
  );

  -- A identidade é obrigatória para o login por e-mail funcionar.
  insert into auth.identities (
    id,
    user_id,
    provider_id,
    provider,
    identity_data,
    last_sign_in_at,
    created_at,
    updated_at
  ) values (
    gen_random_uuid(),
    v_user_id,
    v_user_id::text,
    'email',
    jsonb_build_object('sub', v_user_id::text, 'email', v_email, 'email_verified', true),
    now(),
    now(),
    now()
  );

  raise notice 'Administrador criado: % (id %)', v_email, v_user_id;
end $$;
