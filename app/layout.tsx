import { Analytics } from '@vercel/analytics/next'
import type { Metadata, Viewport } from 'next'
import './globals.css'

export const metadata: Metadata = {
  title: 'TROX — Gestão de Construção',
  description: 'Gestão financeira e operacional dos projetos da TROX Five-Star Construction Corp.',
  generator: 'v0.app',
  manifest: '/manifest.webmanifest',
  icons: {
    icon: 'https://hebbkx1anhila5yf.public.blob.vercel-storage.com/icon-8yvU4RZg0ulwNnpVjbmpjXbcvD6MMb.png',
    apple: 'https://hebbkx1anhila5yf.public.blob.vercel-storage.com/icon-8yvU4RZg0ulwNnpVjbmpjXbcvD6MMb.png',
  },
}

export const viewport: Viewport = {
  colorScheme: 'dark',
  themeColor: '#0A0A0B',
}

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode
}>) {
  return (
    <html lang="pt-BR">
      <body className="antialiased">
        {children}
        {process.env.NODE_ENV === 'production' && <Analytics />}
      </body>
    </html>
  )
}
