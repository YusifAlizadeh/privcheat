#!/usr/bin/env bash
#
# ctf-init — scaffold a per-challenge workspace.
#
#   ctf-init web-login
#   ctf-init pwn-babyheap -d ~/ctf
#
# Layout:
#   <name>/
#   ├── files/     # challenge artifacts (download them here)
#   ├── loot/      # tool output; enum-*.sh write here automatically
#   ├── scripts/   # your solve/exploit scripts
#   └── notes.md   # running notes template (RU)
#
# Inside the workspace, CTF_LOOT_DIR defaults to ./loot, so:
#   enum-net <ip>      -> loot/<ip>/net/<ts>/
#   enum-web <url>     -> loot/<host>/web/<port>/<ts>/
#   enum-bin ./chall   -> loot/<name>/bin/<ts>/
#
set -euo pipefail
SELF="$(readlink -f "${BASH_SOURCE[0]}")"
. "$(dirname "$SELF")/_common.sh"

usage() {
  cat <<'EOF'
Usage: ctf-init <challenge-name> [-d DIR]

Creates a challenge workspace: files/, loot/, scripts/, notes.md.

  -d DIR   parent directory (default: current directory)
  -h       this help
EOF
}

NAME=""; PARENT="$PWD"
while [ $# -gt 0 ]; do
  case "$1" in
    -d) shift; PARENT="${1:? -d needs a directory}" ;;
    -h|--help) usage; exit 0 ;;
    -*) usage >&2; exit 2 ;;
    *) NAME="$1" ;;
  esac
  shift
done

[ -n "$NAME" ] || { usage >&2; exit 2; }
NAME="$(printf '%s' "$NAME" | tr -c 'A-Za-z0-9._-' '_')"
WS="$PARENT/$NAME"
[ -e "$WS" ] && die "already exists: $WS"

mkdir -p "$WS/files" "$WS/loot" "$WS/scripts"

cat >"$WS/notes.md" <<EOF
# $NAME

- **Категория:** 
- **Формат флага:** (напр. \`flag{...}\`, \`CTF{...}\`)
- **Файлы / цель:** 
- **Хинты из описания:** 
- **Очки:** 

## Что уже проверено
- [ ] \`enum-net\` / \`enum-web\` / \`enum-bin\` / \`enum-file\`
- [ ] 

## Находки (по одной строке, важно для райтапа)
- 

## Идеи и тупики
- 

## Итог
- Флаг: 
- Скрипт-решение: \`scripts/\`
EOF

cat >"$WS/scripts/README.md" <<'EOF'
Сюда кладём solve.py / exploit.sh / solver.py.
Коммитить в репозиторий соревнования — по желанию организаторов.
EOF

printf '\n%s  ok%s  workspace ready: %s\n' "$C_GREEN" "$C_RESET" "$WS"
cat <<EOF

  cd $WS
  # положить файлы задания в files/, затем:
  enum-net  10.10.10.10
  enum-web  http://10.10.10.10
  enum-bin  files/chall
  enum-file files/suspect.bin

  Вывод инструментов попадёт в loot/, заметки веди в notes.md.
EOF
