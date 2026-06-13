#!/usr/bin/env bash
# hypr-borrow.sh
set -euo pipefail

STATE="$XDG_RUNTIME_DIR/hypr-borrow.json"

pull() {
    # Fenster einlesen; Label für Anzeige, Daten getrennt halten
    declare -A MAP_ADDR MAP_WS

    local labels=""
    while IFS=$'\t' read -r addr ws label; do
        MAP_ADDR["$label"]="$addr"
        MAP_WS["$label"]="$ws"
        labels+="$label"$'\n'
    done < <(hyprctl clients -j \
        | jq -r '.[] | select(.title != "") |
            "\(.address)\t\(.workspace.id)\t[\(.workspace.id)] \(.class) — \(.title)"')

    [ -z "$labels" ] && exit 0

    # Walker im dmenu-Modus
    local sel
    sel=$(printf '%s' "$labels" | walker --dmenu --placeholder "Fenster pullen…") || exit 0
    [ -z "$sel" ] && exit 0

    local addr="${MAP_ADDR[$sel]:-}"
    local origin_ws="${MAP_WS[$sel]:-}"
    [ -z "$addr" ] && exit 0

    local cur_ws
    cur_ws=$(hyprctl activeworkspace -j | jq '.id')

    # Herkunft inkl. Float-State + Geometry sichern
    local meta
    meta=$(hyprctl clients -j | jq --arg a "$addr" \
        '.[] | select(.address==$a) | {floating, at, size}')

    jq -n \
        --arg a "$addr" \
        --arg o "$origin_ws" \
        --argjson m "$meta" \
        '{address:$a, origin:($o|tonumber), meta:$m}' > "$STATE"

    hyprctl dispatch movetoworkspacesilent "$cur_ws,address:$addr"
    hyprctl dispatch focuswindow "address:$addr"
}

return_window() {
    [ -f "$STATE" ] || { notify-send "hypr-borrow" "Kein geliehenes Fenster"; exit 0; }

    local addr origin was_float at_x at_y
    addr=$(jq -r '.address' "$STATE")
    origin=$(jq -r '.origin' "$STATE")
    was_float=$(jq -r '.meta.floating' "$STATE")
    at_x=$(jq -r '.meta.at[0]' "$STATE")
    at_y=$(jq -r '.meta.at[1]' "$STATE")

    hyprctl dispatch movetoworkspacesilent "$origin,address:$addr"

    # Floating-Position wiederherstellen
    if [ "$was_float" = "true" ]; then
        hyprctl dispatch movewindowpixel "exact $at_x $at_y,address:$addr"
    fi

    rm -f "$STATE"
}

case "${1:-}" in
    pull)   pull ;;
    return) return_window ;;
    *)      echo "usage: $0 {pull|return}" >&2; exit 1 ;;
esac
