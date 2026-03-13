#!/usr/bin/env bash

clients_json="$(hyprctl clients -j 2>/dev/null)"

if [[ -z "$clients_json" || "$clients_json" == "[]" ]]; then
  echo '{"text":"min 0","tooltip":"No minimized windows","class":"empty"}'
  exit 0
fi

mapfile -t titles < <(echo "$clients_json" | jq -r '.[] | select(.workspace.name == "special:minimized") | .title' | sed '/^$/d')
count=${#titles[@]}

if (( count == 0 )); then
  echo '{"text":"min 0","tooltip":"No minimized windows","class":"empty"}'
  exit 0
fi

preview=""
max_preview=2
for ((i=0; i<count && i<max_preview; i++)); do
  if (( i > 0 )); then
    preview+=" | "
  fi
  title="${titles[$i]}"
  title="${title:0:22}"
  preview+="$title"
done

if (( count > max_preview )); then
  preview+=" +$((count-max_preview))"
fi

tooltip=$(printf '%s\n' "${titles[@]}")
tooltip=${tooltip%$'\n'}

escaped_tooltip=$(printf '%s' "$tooltip" | jq -Rs .)
escaped_text=$(printf 'min %d  %s' "$count" "$preview" | jq -Rs .)

echo "{\"text\":${escaped_text},\"tooltip\":${escaped_tooltip},\"class\":\"has-items\"}"
