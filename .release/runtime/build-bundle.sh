#!/usr/bin/env bash
# Gera o pacote de demo autocontido em .release/runtime/dist/compass-demo/.
# Mesmo processo que o release.yml vai rodar no CI - mantenha os dois em sincronia.
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$HERE/../.." && pwd)"
OUT="$HERE/dist/compass-demo"

echo "==> Buildando os apps Flutter (web)"
for app in routecraft_app travel_matrix; do
  (cd "$ROOT/$app" && flutter pub get && flutter build web --release)
done

echo "==> Buildando a imagem da API"
(cd "$HERE" && docker compose build backend)
docker pull postgres:15
docker pull nginx:alpine

echo "==> Montando $OUT"
rm -rf "$OUT"
mkdir -p "$OUT/web" "$OUT/seed"
cp -r "$ROOT/routecraft_app/build/web"  "$OUT/web/routecraft"
cp -r "$ROOT/travel_matrix/build/web"   "$OUT/web/travel_matrix"
cp "$ROOT/compass-api/scripts/seed_test_data.py" "$OUT/seed/"
cp "$HERE"/docker-compose.yml "$HERE"/nginx-spa.conf "$HERE"/*.bat "$HERE"/LEIA-ME.md "$OUT/"

echo "==> Exportando imagens (images.tar)"
docker save -o "$OUT/images.tar" compass-demo/api:local postgres:15 nginx:alpine

echo "==> Compactando"
(cd "$HERE/dist" && rm -f compass-demo.zip && powershell -NoProfile -Command \
  "Compress-Archive -Path 'compass-demo' -DestinationPath 'compass-demo.zip' -Force")

echo "Pronto: $HERE/dist/compass-demo.zip"
