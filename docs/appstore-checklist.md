# Checklist Mac App Store

## Estado rapido (14-04-2026)

- Build release macOS: OK
- Archive Xcode: OK
- Duplicados de wallpapers: deduplicados en scripts de sync
- Pendiente para submit: configuracion final en App Store Connect y compra in-app real

## Cuenta y legal

- Cuenta Apple Developer activa
- Identificador de app reservado (`com.wallos.desktop` o equivalente)
- Politica de privacidad publicada

## App

- Icono en resoluciones requeridas
- Pantallas y metadatos de App Store preparados
- Manejo de errores de red y estados vacios
- Licencias de imagenes y atribuciones verificadas

## Tecnico

- Firma con certificados validos
- Pruebas en release mode
- Cumplimiento de sandboxing en macOS
- Entitlements revisados

## Entrega

- Build archivada en Xcode
- Subida a App Store Connect
- Revision de warnings previos al submit
- Plan de versionado y notas de release

## Flujo express (para subir hoy)

1. Ejecutar `npm run release:flutter:archive`
2. Abrir Xcode Organizer y seleccionar el archive de WallOs
3. Subir a App Store Connect con firma automatica
4. Completar metadata final y enviar a review

## Lo que puede hacer Copilot

- Ajustes de build, scripts y CI de release
- Limpieza de assets/duplicados y validaciones de proyecto
- Preparar texto de release notes, FAQ y checklist tecnico

## Lo que debes completar en Apple

- Crear/validar App ID y Team Signing en tu cuenta
- Configurar producto de compra no consumible en App Store Connect
- Cargar privacidad, categoria, metadatos y capturas finales
- Enviar el build a revision y responder feedback de App Review