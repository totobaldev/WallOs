# Desarrollo app Flutter (paso a paso)

## Paso 1. Preparar entorno macOS

1. Ejecutar en terminal:
   sudo xcodebuild -license
2. Ejecutar:
   sudo xcodebuild -runFirstLaunch
3. Verificar:
   flutter doctor -v

## Paso 2. Inicializar app base

1. Desde la raiz del repo:
   npm run bootstrap:flutter
2. Sincronizar wallpapers locales:
   npm run wallpapers:sync:flutter
3. Verificar que exista el proyecto en apps/desktop_flutter
4. Correr en macOS:
   cd apps/desktop_flutter
   flutter run -d macos

## Paso 3. Estructura de codigo (MVP)

1. Crear capas:
   - lib/core
   - lib/features/wallpapers
   - lib/features/settings
2. Definir modelo Wallpaper con:
   - id
   - title
   - previewAssetPath
   - tags
3. Cargar data local en JSON para primer catalogo.

## Paso 4. Pantallas MVP

1. Home: grid de wallpapers. (Implementado)
2. Detail: preview + boton "Aplicar fondo". (Implementado)
3. Favorites: lista de guardados. (Implementado)
4. Settings: intervalo de rotacion y calidad por defecto. (Implementado en baseline)

## Paso 5. Calidad y release

1. Analisis estatico:
   flutter analyze
2. Tests iniciales:
   flutter test
3. Build release macOS:
   flutter build macos --release

## Paso 6. App Store prep

1. Iconos y screenshots finales.
2. Entitlements y sandbox.
3. Firma, notarizacion y subida a App Store Connect.

## Estado actual

- Bootstrap Flutter completado.
- Sincronizacion de wallpapers PNG desde la carpeta fondos completada.
- Build macOS debug validado.
