#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_DIR="$ROOT_DIR/apps/desktop_flutter"

if ! command -v flutter >/dev/null 2>&1; then
  echo "Flutter no esta instalado o no esta en PATH."
  echo "Instala Flutter estable: https://docs.flutter.dev/get-started/install/macos"
  exit 1
fi

if ! command -v xcodebuild >/dev/null 2>&1; then
  echo "Xcode no esta disponible en este sistema."
  echo "Instala Xcode desde App Store y abre la app al menos una vez."
  exit 1
fi

if ! xcodebuild -checkFirstLaunchStatus >/dev/null 2>&1; then
  echo "Xcode requiere finalizar configuracion inicial o licencia."
  echo "Ejecuta estos comandos y vuelve a correr bootstrap:"
  echo "  sudo xcodebuild -license"
  echo "  sudo xcodebuild -runFirstLaunch"
  exit 1
fi

if [ -f "$APP_DIR/pubspec.yaml" ]; then
  echo "Proyecto Flutter ya existe en $APP_DIR"
else
  rm -rf "$APP_DIR"
  flutter create \
    --platforms=macos,ios,android \
    --org com.wallos \
    --project-name wallos_desktop \
    "$APP_DIR"
fi

cd "$APP_DIR"
flutter config --enable-macos-desktop
flutter pub get

echo ""
echo "Bootstrap Flutter completado."
echo "Siguiente paso:"
echo "  cd apps/desktop_flutter"
echo "  flutter run -d macos"