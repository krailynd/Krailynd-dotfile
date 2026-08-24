#!/usr/bin/env bash
current=$(tmux show-environment -g TMUX_TARGET 2>/dev/null | sed 's/^TMUX_TARGET=//')
echo "Target actual: ${current:-ninguno}"
echo ""
read -r -p "IP objetivo (Enter vacio para borrar): " t
t="${t// /}"
if [[ -n "$t" ]]; then
  tmux set-environment -g TMUX_TARGET "$t"
else
  tmux set-environment -gu TMUX_TARGET
fi
tmux refresh-client -S 2>/dev/null
