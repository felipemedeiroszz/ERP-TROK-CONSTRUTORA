// Define a senha de um usuário administrador usando a Admin API do Supabase.
//
// Uso (PowerShell):
//   $env:SUPABASE_URL="https://SEU-PROJETO.supabase.co"
//   $env:SUPABASE_SERVICE_ROLE_KEY="SUA_SERVICE_ROLE_KEY"
//   $env:ADMIN_EMAIL="email-do-admin@exemplo.com"
//   node scripts/set-admin-password.mjs
//
// Opcional: defina ADMIN_PASSWORD para trocar a senha padrão (troyadmin2026).
//
// IMPORTANTE: a SERVICE_ROLE key dá acesso total ao projeto. Nunca a coloque no
// código, no git ou em variáveis NEXT_PUBLIC_*. Use apenas localmente.

import { createClient } from '@supabase/supabase-js'

const url = process.env.SUPABASE_URL ?? process.env.NEXT_PUBLIC_SUPABASE_URL
const serviceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY
const userId = process.env.ADMIN_USER_ID
const email = process.env.ADMIN_EMAIL
const newPassword = process.env.ADMIN_PASSWORD ?? 'troyadmin2026'

function fail(message) {
  console.error(`\n[erro] ${message}\n`)
  process.exit(1)
}

if (!url) fail('Defina SUPABASE_URL (ou NEXT_PUBLIC_SUPABASE_URL).')
if (!serviceRoleKey) fail('Defina SUPABASE_SERVICE_ROLE_KEY.')
if (!userId && !email) fail('Defina ADMIN_USER_ID ou ADMIN_EMAIL do administrador.')
if (newPassword.length < 6) fail('A senha precisa ter pelo menos 6 caracteres (mínimo do Supabase).')

const supabase = createClient(url, serviceRoleKey, {
  auth: { autoRefreshToken: false, persistSession: false },
})

let targetId = userId
if (!targetId) {
  const { data: list, error: listError } = await supabase.auth.admin.listUsers({ page: 1, perPage: 1000 })
  if (listError) fail(`Falha ao listar usuários: ${listError.message}`)

  const target = list.users.find((user) => user.email?.toLowerCase() === email.toLowerCase())
  if (!target) fail(`Nenhum usuário encontrado com o e-mail ${email}.`)
  targetId = target.id
}

const { data: updated, error: updateError } = await supabase.auth.admin.updateUserById(targetId, {
  password: newPassword,
})
if (updateError) fail(`Falha ao atualizar a senha: ${updateError.message}`)

console.log(`\n[ok] Senha atualizada para o usuário ${updated.user?.email} (id: ${updated.user?.id}).\n`)
