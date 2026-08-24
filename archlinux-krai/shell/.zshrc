# ==============================================================================
# Powerlevel10k Instant Prompt (debe permanecer al inicio absoluto)
# ==============================================================================
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Fix Java GUI rendering en non-reparenting WMs
export _JAVA_AWT_WM_NONREPARENTING=1

# ==============================================================================
# Homebrew & Environment Setup
# ==============================================================================
if [[ -f "/home/linuxbrew/.linuxbrew/bin/brew" ]]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
elif [[ -f "/opt/homebrew/bin/brew" ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# PATH unificado
export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$HOME/go/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH"

export EDITOR="nvim"
export VISUAL="nvim"

# ==============================================================================
# Zsh Options & History
# ==============================================================================
setopt histignorealldups sharehistory
bindkey -e

HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history

# ==============================================================================
# Completion System & Carapace
# ==============================================================================
autoload -Uz compinit
compinit

zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select=2
# ls colors con truecolor directo (no depende de la paleta del tema Alacritty)
export LS_COLORS='rs=0:di=01;38;2;140;215;105:ln=38;2;110;200;210:mh=00:pi=38;2;220;160;80:so=38;2;200;130;190:do=38;2;200;130;190:bd=38;2;255;255;255;48;2;90;120;200:cd=38;2;255;255;255;48;2;90;120;200:or=01;38;2;255;110;110:mi=01;38;2;255;110;110:su=38;2;255;255;255;48;2;150;60;60:sg=38;2;0;0;0;48;2;200;160;60:ca=00:tw=38;2;0;0;0;48;2;90;180;90:ow=38;2;0;0;0;48;2;90;180;90:st=38;2;255;255;255;48;2;90;120;200:ex=01;38;2;95;190;95:*.tar=38;2;220;160;80:*.tgz=38;2;220;160;80:*.gz=38;2;220;160;80:*.zip=38;2;220;160;80:*.zst=38;2;220;160;80:*.xz=38;2;220;160;80:*.7z=38;2;220;160;80:*.rar=38;2;220;160;80:*.deb=38;2;220;160;80:*.jpg=38;2;200;130;190:*.jpeg=38;2;200;130;190:*.png=38;2;200;130;190:*.gif=38;2;200;130;190:*.svg=38;2;200;130;190:*.mp4=38;2;200;130;190:*.mkv=38;2;200;130;190:*.mp3=38;2;200;180;90:*.flac=38;2;200;180;90:*.wav=38;2;200;180;90:*~=38;2;130;130;130:*#=38;2;130;130;130:*.bak=38;2;130;130;130:*.old=38;2;130;130;130:*.tmp=38;2;130;130;130:*.swp=38;2;130;130;130'
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*' menu select=long
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true

zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

# Carapace integration
if command -v carapace >/dev/null 2>&1; then
  export CARAPACE_BRIDGES='zsh,fish,bash,inshellisense'
  zstyle ':completion:*' format $'\e[2;37mCompleting %d\e[m'
  source <(carapace _carapace)
fi

# ==============================================================================
# Custom Aliases
# ==============================================================================
# LSD / LS
if command -v lsd >/dev/null 2>&1; then
  alias ll='lsd -lh --group-dirs=first'
  alias la='lsd -a --group-dirs=first'
  alias l='lsd --group-dirs=first'
  alias lla='lsd -lha --group-dirs=first'
  alias ls='lsd --group-dirs=first'
fi

# Bat / Batcat
if command -v bat >/dev/null 2>&1; then
  alias cat='bat --paging=never'
  alias catn='cat'
  alias catnl='bat'
elif command -v batcat >/dev/null 2>&1; then
  alias cat='/bin/batcat --paging=never'
  alias catn='cat'
  alias catnl='batcat'
fi

# FZF previews
alias fzfbat='fzf --preview="bat --theme=gruvbox-dark --color=always {} 2>/dev/null || cat {}"'
alias fzfnvim='nvim $(fzf --preview="bat --theme=gruvbox-dark --color=always {} 2>/dev/null || cat {}")'

# ==============================================================================
# Custom Functions (Pentesting & Workflow)
# ==============================================================================
function mkt(){
  mkdir -p {nmap,content,exploits,scripts}
}

function extractPorts(){
  local file="$1"
  if [[ ! -f "$file" ]]; then
    echo "Uso: extractPorts <nmap-output-file>"
    return 1
  fi
  ports="$(grep -oP '\d{1,5}/open' "$file" | awk -F'/' '{print $1}' | xargs | tr ' ' ',')"
  ip_address="$(grep -oP '\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}' "$file" | sort -u | head -n 1)"
  echo -e "\n[*] Extracting information...\n"
  echo -e "\t[*] IP Address: $ip_address"
  echo -e "\t[*] Open ports: $ports\n"
  if command -v xclip >/dev/null 2>&1; then
    echo -n "$ports" | xclip -sel clip
    echo -e "[*] Ports copied to clipboard\n"
  elif command -v wl-copy >/dev/null 2>&1; then
    echo -n "$ports" | wl-copy
    echo -e "[*] Ports copied to clipboard\n"
  fi
}

function settarget(){
  if [[ -x /usr/local/bin/settarget ]]; then
    /usr/local/bin/settarget "$@"
  elif [[ $# -eq 1 ]]; then
    mkdir -p ~/.config/bin
    echo "$1" > ~/.config/bin/target
  elif [[ $# -ge 2 ]]; then
    mkdir -p ~/.config/bin
    echo "$1 $2" > ~/.config/bin/target
  else
    echo "Uso: settarget [IP] [NAME] | settarget [IP]"
  fi
}

function man() {
  env \
    LESS_TERMCAP_mb=$'\e[01;31m' \
    LESS_TERMCAP_md=$'\e[01;31m' \
    LESS_TERMCAP_me=$'\e[0m' \
    LESS_TERMCAP_se=$'\e[0m' \
    LESS_TERMCAP_so=$'\e[01;44;33m' \
    LESS_TERMCAP_ue=$'\e[0m' \
    LESS_TERMCAP_us=$'\e[01;32m' \
    man "$@"
}

function fzf-lovely(){
  if [ "$1" = "h" ]; then
    fzf -m --reverse --preview-window down:20 --preview '[[ $(file --mime {}) =~ binary ]] &&
      echo {} is a binary file ||
      (bat --style=numbers --color=always {} ||
       cat {}) 2> /dev/null | head -500'
  else
    fzf -m --preview '[[ $(file --mime {}) =~ binary ]] &&
      echo {} is a binary file ||
      (bat --style=numbers --color=always {} ||
       cat {}) 2> /dev/null | head -500'
  fi
}

function rmk(){
  if command -v scrub >/dev/null 2>&1 && command -v shred >/dev/null 2>&1; then
    scrub -p dod "$1"
    shred -zun 10 -v "$1"
  else
    rm -rf "$1"
  fi
}

# ==============================================================================
# Modern Tools Init (Gentleman-Dots: Atuin, Zoxide, FZF)
# ==============================================================================
if command -v fzf >/dev/null 2>&1; then
  eval "$(fzf --zsh)"
elif [ -f ~/.fzf.zsh ]; then
  source ~/.fzf.zsh
fi

if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi

if command -v atuin >/dev/null 2>&1; then
  eval "$(atuin init zsh)"
fi

# ==============================================================================
# Plugins Zsh
# ==============================================================================
source_if_exists() {
  [[ -f "$1" ]] && source "$1"
}

# Brew plugins
source_if_exists "/home/linuxbrew/.linuxbrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
source_if_exists "/home/linuxbrew/.linuxbrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
source_if_exists "/home/linuxbrew/.linuxbrew/share/powerlevel10k/powerlevel10k.zsh-theme"

# System plugins fallback
source_if_exists "/usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
source_if_exists "/usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
source_if_exists "$HOME/.powerlevel10k/powerlevel10k.zsh-theme"

# ==============================================================================
# Esc Esc -> sudo (toggle). If the line already starts with "sudo ", it removes it.
# ==============================================================================
function sudo-command-line() {
    [[ -z $BUFFER ]] && zle up-history
    if [[ $BUFFER == sudo\ * ]]; then
        LBUFFER="${LBUFFER#sudo }"
    else
        LBUFFER="sudo $LBUFFER"
    fi
}
zle -N sudo-command-line
bindkey "\e\e" sudo-command-line

# ==============================================================================
# Keybindings
# ==============================================================================
bindkey "^[[H" beginning-of-line
bindkey "^[[F" end-of-line
bindkey "^[[3~" delete-char
bindkey "^[[1;3C" forward-word
bindkey "^[[1;3D" backward-word

# ==============================================================================
# Powerlevel10k Configuration & Finalize
# ==============================================================================
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh
(( ! ${+functions[p10k-instant-prompt-finalize]} )) || p10k-instant-prompt-finalize

# ==============================================================================
# Auto-start Terminal Multiplexer (Tmux)
# ==============================================================================
function start_if_needed() {
  if [[ $- == *i* ]] && [[ -t 1 ]] && command -v tmux >/dev/null 2>&1; then
    if [[ -z "$TMUX" ]] && [[ -z "$ZELLIJ" ]] && [[ -z "$HERDR_ENV" ]] && [[ -z "$HERDR_SESSION" ]] && [[ -z "$NO_TMUX" ]]; then
      exec tmux new-session -A -s main
    fi
  fi
}

# start_if_needed  # DESACTIVADO 2026-08-24: no auto tmux al hacer `wsl -d archlinux` (usuario pidió desactivar)

