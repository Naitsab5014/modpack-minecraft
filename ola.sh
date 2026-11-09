#!/usr/bin/env bash
# Reinstala todos los mods del pack con packwiz y marca los de cliente
# como opcionales y activados por defecto.
# Uso: ejecutar dentro de la carpeta del modpack (donde está pack.toml)
#   chmod +x reinstall-mods.sh && ./reinstall-mods.sh

set -u

if ! command -v packwiz >/dev/null 2>&1; then
  echo "packwiz no está instalado o no está en el PATH" >&2
  exit 1
fi

if [ ! -f pack.toml ]; then
  echo "Ejecuta este script en la carpeta que contiene pack.toml" >&2
  exit 1
fi

MODS=(
  3dskinlayers
  appleskin
  aquaculture
  architectury-api
  artifacts
  balm
  better-modlist
  betterf3
  camera-mod
  carry-on
  cloth-config
  clumps
  comforts
  controlify
  controlling
  copycats
  create-aeronautics
  create-aquatic-ambitions
  create-broken-bad
  create-design-n-decor
  create-dreams-and-desires
  create-misc-and-things
  create-new-age
  create-rustic-structures
  create-sound-of-steam
  create-stuff-additions
  create-trading-floor
  create-ultimate-factory
  create
  createbetterfps
  curios
  dynamic-village
  entityculling
  farmers-delight
  farmers-structures
  ferrite-core
  freecam
  immediatelyfast
  interiors
  iris
  jade
  jei
  just-enough-professions-jep
  just-enough-resources-jer
  just-zoom
  justenoughbreeding
  konkrete
  kotlin-for-forge
  lithium
  lodestone
  mezzconfig
  minecraft-comes-alive-reborn
  miners-delight-plus
  modernfix
  my-nethers-delight
  oceans-delight
  picture-mode
  power-grid
  prickle
  sable
  searchables
  slice-and-dice
  sodium-extra
  sodium
  sophisticated-backpacks
  sophisticated-core
  voxy-worldgen
  waystones
  xaeros-minimap
  xaeros-world-map
  yacl
  yes-steve-model
)

FAILED=()

echo "==> Reinstalando ${#MODS[@]} mods..."
for slug in "${MODS[@]}"; do
  echo "--> $slug"
  # Intenta primero Modrinth y, si falla, CurseForge
  if packwiz modrinth add "$slug" -y >/dev/null 2>&1; then
    echo "    OK (Modrinth)"
  elif packwiz curseforge add "$slug" -y >/dev/null 2>&1; then
    echo "    OK (CurseForge)"
  else
    echo "    FALLÓ"
    FAILED+=("$slug")
  fi
done

echo
echo "==> Marcando mods de cliente como opcionales (activados por defecto)..."
COUNT=0
for f in mods/*.pw.toml; do
  [ -f "$f" ] || continue
  if grep -qE '^side *= *"client"' "$f"; then
    # Si ya tiene sección [option], no la duplica
    if grep -q '^\[option\]' "$f"; then
      continue
    fi
    {
      echo
      echo "[option]"
      echo "optional = true"
      echo "default = true"
      echo 'description = "Mod de cliente (opcional)"'
    } >> "$f"
    echo "    opcional: $(basename "$f")"
    COUNT=$((COUNT + 1))
  fi
done
echo "    $COUNT mods de cliente marcados"

echo
echo "==> Actualizando índice..."
packwiz refresh

echo
if [ ${#FAILED[@]} -gt 0 ]; then
  echo "Estos mods no se pudieron instalar (revisa el slug o instálalos a mano):"
  printf '  - %s\n' "${FAILED[@]}"
else
  echo "Todos los mods se instalaron correctamente."
fi
