# Troca Copa 2026

PWA mobile-first para troca de figurinhas do album da Copa do Mundo FIFA 2026. O app e focado exclusivamente em trocas entre colecionadores, sem venda, pagamento ou marketplace.

## Publicacao rapida

Este repositorio contem uma versao estatica leve pronta para Vercel:

- `index.html`: shell do PWA.
- `preview.html`: interface navegavel do MVP.
- `manifest.json`: configuracao instalavel.
- `sw.js`: service worker simples.
- `vercel.json`: configuracao de site estatico.

## Supabase

Projeto criado: `Troca Copa 2026`

- Project ID: `owvfogbepauqzljlsdit`
- URL: `https://owvfogbepauqzljlsdit.supabase.co`
- Seed aplicado e verificado: 980 figurinhas, 68 especiais, 48 selecoes.

## Variaveis de ambiente

```env
NEXT_PUBLIC_SUPABASE_URL=
NEXT_PUBLIC_SUPABASE_ANON_KEY=
```

## Proximos passos

- Importar este repositorio na Vercel.
- Testar a URL HTTPS no celular e instalar o PWA.
- Evoluir a versao estatica para Next.js com persistencia real no Supabase.
