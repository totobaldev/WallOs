# WallOs

Monorepo para construir WallOs con dos superficies:

- App de escritorio en Flutter (objetivo inicial: macOS, luego iOS/Android).
- Landing web de producto para marketing, espera y conversion.

## Estructura

- `apps/desktop_flutter`: app Flutter (bootstrap pendiente de ejecutar).
- `apps/web`: landing en React + Vite.
- `packages/shared`: recursos o contratos compartidos.
- `docs`: documentacion tecnica y operativa.

## Requisitos

- Node.js 20+
- Flutter SDK (estable)
- Xcode + Command Line Tools

Antes del primer bootstrap Flutter en macOS, ejecuta:

```bash
sudo xcodebuild -license
sudo xcodebuild -runFirstLaunch
```

## Comandos raiz

```bash
npm run wallpapers:sync
npm run wallpapers:sync:flutter
npm run dev:web
npm run build:web
npm run lint:web
npm run bootstrap:flutter
npm run run:flutter:macos
```

## Wallpapers de fondo

1. Deja tus archivos en la carpeta `fondos` en la raiz del repo.
2. Ejecuta `npm run wallpapers:sync` para sincronizar a la landing.
3. Arranca `npm run dev:web` para verlos rotando en segundo plano.

`dev:web`, `build:web` y `preview:web` ya ejecutan sincronizacion automaticamente antes de iniciar.

## Creadores y donaciones (Flutter)

Para editar autores y links de apoyo que aparecen en el detalle de wallpapers, modifica:

- `fondos/creators.json`

Luego ejecuta:

```bash
npm run wallpapers:sync:flutter
```

## Flujo recomendado

1. Ejecutar la landing y validar branding/posicionamiento.
2. Ejecutar bootstrap Flutter y arrancar MVP macOS.
3. Preparar entrega App Store siguiendo el checklist de `docs/appstore-checklist.md`.

Guia detallada de desarrollo de app: `docs/flutter-step-by-step.md`.