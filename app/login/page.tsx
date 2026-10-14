'use client'

import Image from 'next/image'
import { FormEvent, useState } from 'react'
import { ArrowRight, Mail, Lock, Eye, EyeOff, CheckCircle, Shield, Zap } from 'lucide-react'
import { useRouter } from 'next/navigation'
import { createClient } from '@/lib/supabase/client'

export default function LoginPage() {
  const router = useRouter()
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [showPassword, setShowPassword] = useState(false)
  const [rememberMe, setRememberMe] = useState(false)
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

  return (
    <main className="auth-split-shell">
      <div className="auth-split-left">
        <div className="auth-split-logo">
          <Image src="/trox-logo.png" alt="TROX Five-Star Construction Corp" width={160} height={92} priority />
        </div>
        <div className="auth-split-overlay" />
        <div className="auth-split-content">
          <h1 className="auth-split-headline">CONSTRUÇÃO DE EXCELÊNCIA</h1>
          <p className="auth-split-subheadline">Sistema de gestão empresarial de alto padrão</p>
        </div>
        <div className="auth-split-status">
          <div className="status-item">
            <CheckCircle size={16} />
            <span>Sistema Operacional</span>
          </div>
          <div className="status-item">
            <Shield size={16} />
            <span>Segurança Ativa</span>
          </div>
          <div className="status-item">
            <Zap size={16} />
            <span>Performance Otimizada</span>
          </div>
        </div>
      </div>
      <div className="auth-split-right">
        <div className="auth-form-container">
          <div className="auth-form-header">
            <p className="auth-form-eyebrow">ÁREA ADMINISTRATIVA</p>
            <h2>Acesso ao Workspace</h2>
            <p>Entre com suas credenciais para gerenciar projetos</p>
          </div>
          <form onSubmit={handleSubmit} className="auth-split-form">
            <div className="form-field">
              <label htmlFor="email">E-mail</label>
              <div className="input-wrapper">
                <Mail size={18} className="input-icon" />
                <input
                  id="email"
                  type="email"
                  autoComplete="email"
                  required
                  placeholder="seu@email.com"
                  value={email}
                  onChange={(event) => setEmail(event.target.value)}
                />
              </div>
            </div>
            <div className="form-field">
              <label htmlFor="password">Senha</label>
              <div className="input-wrapper">
                <Lock size={18} className="input-icon" />
                <input
                  id="password"
                  type={showPassword ? 'text' : 'password'}
                  autoComplete="current-password"
                  required
                  placeholder="••••••••"
                  value={password}
                  onChange={(event) => setPassword(event.target.value)}
                />
                <button
                  type="button"
                  className="password-toggle"
                  onClick={() => setShowPassword(!showPassword)}
                  aria-label={showPassword ? 'Ocultar senha' : 'Mostrar senha'}
                >
                  {showPassword ? <EyeOff size={18} /> : <Eye size={18} />}
                </button>
              </div>
            </div>
            <div className="form-options">
              <label className="checkbox-wrapper">
                <input
                  type="checkbox"
                  checked={rememberMe}
                  onChange={(event) => setRememberMe(event.target.checked)}
                />
                <span>Manter sessão ativa</span>
              </label>
              <a href="#" className="forgot-password">Esqueceu a senha?</a>
            </div>
            {error && <p className="auth-split-error" role="alert">{error}</p>}
            <button className="auth-split-submit" type="submit" disabled={pending}>
              {pending ? 'Entrando…' : 'Acessar Sistema'}
              <ArrowRight size={18} />
            </button>
          </form>
          <div className="auth-split-footer">
            <Shield size={14} />
            <span>Acesso restrito e monitorado</span>
          </div>
        </div>
      </div>
    </main>
  )
}
