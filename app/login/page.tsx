'use client'

import Image from 'next/image'
import { FormEvent, useState } from 'react'
import { ArrowRight, LockKeyhole, ShieldCheck } from 'lucide-react'
import { useRouter } from 'next/navigation'
import { createClient } from '@/lib/supabase/client'

export default function LoginPage() {
  const router = useRouter()
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [error, setError] = useState('')
  const [pending, setPending] = useState(false)

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault()
    setPending(true)
    setError('')
    const { error: signInError } = await createClient().auth.signInWithPassword({ email, password })
    if (signInError) {
      setError(signInError.message.toLowerCase().includes('confirm') ? 'Confirme seu e-mail antes de entrar.' : 'E-mail ou senha inválidos.')
      setPending(false)
      return
    }
    router.replace('/dashboard')
    router.refresh()
  }

  return <main className="auth-shell"><section className="auth-card"><div className="auth-brand"><Image src="/troy-logo.png" alt="Troy Five-Star Construction Corp" width={150} height={86} priority /></div><div className="auth-heading"><div className="auth-icon"><LockKeyhole size={18} /></div><p className="eyebrow">Troy</p><h1>Área administrativa</h1><p>Acesse o workspace do proprietário para gerenciar seus projetos.</p></div><form onSubmit={handleSubmit} className="auth-form"><label htmlFor="email">E-mail administrativo<input id="email" type="email" autoComplete="email" required value={email} onChange={(event) => setEmail(event.target.value)} /></label><label htmlFor="password">Senha<input id="password" type="password" autoComplete="current-password" required value={password} onChange={(event) => setPassword(event.target.value)} /></label>{error && <p className="auth-error" role="alert">{error}</p>}<button className="button-primary auth-submit" type="submit" disabled={pending}>{pending ? 'Entrando…' : 'Entrar no workspace'}<ArrowRight size={16} /></button></form><div className="auth-footer"><ShieldCheck size={15} /><span>Acesso restrito à conta administradora</span></div></section></main>
}
