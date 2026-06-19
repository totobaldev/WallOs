# Stack tecnico inicial

## Objetivo

Construir WallOs como producto desktop-first para macOS en Flutter, con base compartida para escalar a moviles y una landing separada para captacion.

## Arquitectura

- `apps/desktop_flutter`
  - Flutter 3.x (canal stable)
  - Target inicial: macOS
  - Targets posteriores: iOS y Android
- `apps/web`
  - React 19 + Vite + TypeScript
  - Landing y marketing
- `packages/shared`
  - Contratos JSON compartidos (colecciones, metadatos de fondos)
  - Assets reutilizables

## UI/UX

- Base visual inspirada en macOS:
  - Superficies transluidas
  - Jerarquia tipografica estilo SF
  - Controles compactos con alto contraste

## Datos y contenido (siguiente fase)

- Catalogo local JSON para MVP
- Migracion a backend ligero (Supabase/Firebase/API propia)
- Descarga y cache de assets 4K por coleccion

## CI/CD sugerido

- GitHub Actions:
  - Job web: lint + build
  - Job flutter: analyze + test + build macOS
- Firma y distribucion de app:
  - Certificados Apple Developer
  - Notarizacion y subida a App Store Connect