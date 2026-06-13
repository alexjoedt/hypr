#!/usr/bin/env bash
# hypr-borrow.sh
set -euo pipefail

STATE="$XDG_RUNTIME_DIR/hypr-borrow.json"

# ── Configuration (override via environment) ────────────────────────────────
# HYPR_BORROW_FLOAT  : float + center the borrowed window  (default: true)
# HYPR_BORROW_GAP    : top/bottom gap in px when floating  (default: 100)
# HYPR_BORROW_WIDTH  : width as fraction of monitor width  (default: 0.5)
: "${HYPR_BORROW_FLOAT:=true}"
: "${HYPR_BORROW_GAP:=100}"
: "${HYPR_BORROW_WIDTH:=0.5}"
# ────────────────────────────────────────────────────────────────────────────

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

    hyprctl dispatch "hl.dsp.window.move({ workspace = ${cur_ws}, window = 'address:${addr}', follow = false })"
    hyprctl dispatch "hl.dsp.focus({ window = 'address:${addr}' })"

    if [ "$HYPR_BORROW_FLOAT" = "true" ]; then
        # Float, resize, then center — same as Super+T
        local win_w win_h
        read -r win_w win_h < <(hyprctl monitors -j | jq -r \
            --argjson gap  "$HYPR_BORROW_GAP" \
            --argjson frac "$HYPR_BORROW_WIDTH" '
            .[] | select(.focused == true) |
            [ ((.width  / .scale) * $frac | floor),
              ((.height / .scale) - ($gap * 2) | floor) ] |
            "\(.[0]) \(.[1])"')
        hyprctl dispatch "hl.dsp.window.float({ action = 'enable', window = 'address:${addr}' })"
        hyprctl dispatch "hl.dsp.window.resize({ x = ${win_w}, y = ${win_h}, window = 'address:${addr}' })"
        hyprctl dispatch "hl.dsp.window.center({ window = 'address:${addr}' })"
    fi
}

return_window() {
    [ -f "$STATE" ] || { notify-send "hypr-borrow" "Kein geliehenes Fenster"; exit 0; }

    local addr origin was_float at_x at_y
    addr=$(jq -r '.address' "$STATE")
    origin=$(jq -r '.origin' "$STATE")
    was_float=$(jq -r '.meta.floating' "$STATE")
    at_x=$(jq -r '.meta.at[0]' "$STATE")
    at_y=$(jq -r '.meta.at[1]' "$STATE")

    hyprctl dispatch "hl.dsp.window.move({ workspace = ${origin}, window = 'address:${addr}', follow = false })"

    # Floating-State wiederherstellen
    if [ "$was_float" = "true" ]; then
        hyprctl dispatch "hl.dsp.window.move({ x = ${at_x}, y = ${at_y}, window = 'address:${addr}' })"
    else
        # Was tiled before — remove floating
        hyprctl dispatch "hl.dsp.window.float({ action = 'disable', window = 'address:${addr}' })"
    fi

    rm -f "$STATE"
}

case "${1:-}" in
    pull)   pull ;;
    return) return_window ;;
    *)      echo "usage: $0 {pull|return}" >&2; exit 1 ;;
esac
