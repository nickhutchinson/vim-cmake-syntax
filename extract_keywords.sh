#!/bin/bash
# Invokes cmake to collect keywords (builtin variables, commands, properties).
set -euo pipefail

cmd=(cmake)
case "$*" in
  variables)
    cmd+=(--help-variable-list)
    ;;
  commands)
    cmd+=(--help-command-list)
    ;;
  properties)
    cmd+=(--help-property-list)
    ;;
  *)
    >&2 echo "Usage: ${BASH_SOURCE[0]} variables|commands|properties"
    exit 1
    ;;
esac

"${cmd[@]}"                                                                  \
  | awk 'match($0, /(\w+)<LANG>(\w+)/, m) {
           printf "%1$sC%2$s\n%1$sCXX%2$s\n", m[1], m[2]; next; } 1'         \
  | awk 'match($0, /(\w+)<CONFIG>$/, m) {
           printf "%1$sDEBUG%2$s\n%1$sRELEASE%2$s\n", m[1], m[2]; next; } 1' \
  | awk '/^\w+$/ { print $0 }'                                               \
  | tr "\n" " "
