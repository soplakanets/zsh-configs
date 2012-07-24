[[ -o login ]] || return

# Color table taken from: http://www.understudy.net/custom.html
#Prompt Color Table Z shell
fg_black=$'\e[0;30m'
fg_red=$'\e[0;31m'
fg_green=$'\e[0;32m'
fg_brown=$'\e[0;33m'
fg_blue=$'\e[0;34m'
fg_purple=$'\e[0;35m'
fg_cyan=$'\e[0;36m'
fg_lgray=$'\e[0;37m'
fg_dgray=$'\e[1;30m'
fg_lred=$'\e[1;31m'
fg_lgreen=$'\e[1;32m'
fg_yellow=$'\e[1;33m'
fg_lblue=$'\e[1;34m'
fg_pink=$'\e[1;35m'
fg_lcyan=$'\e[1;36m'
fg_white=$'\e[1;37m'
#Text Background Colors
bg_red=$'\e[0;41m'
bg_green=$'\e[0;42m'
bg_brown=$'\e[0;43m'
bg_blue=$'\e[0;44m'
bg_purple=$'\e[0;45m'
bg_cyan=$'\e[0;46m'
bg_gray=$'\e[0;47m'
#Attributes
at_normal=$'\e[0m'
at_bold=$'\e[1m'
at_italics=$'\e[3m'
at_underl=$'\e[4m'
at_blink=$'\e[5m'
at_outline=$'\e[6m'
at_reverse=$'\e[7m'
at_nondisp=$'\e[8m'
at_strike=$'\e[9m'
at_boldoff=$'\e[22m'
at_italicsoff=$'\e[23m'
at_underloff=$'\e[24m'
at_blinkoff=$'\e[25m'
at_reverseoff=$'\e[27m'
at_strikeoff=$'\e[29m'


function git_current_branch() {
  local ref=$(git symbolic-ref HEAD 2> /dev/null) || return
  echo $( git_format_branch "${ref#refs/heads/}" )
}

git_format_branch() {
  [ -z $1 ] && return
  if [[ -n $(git status -s --ignore-submodules=dirty  2> /dev/null) ]]; then
    echo " [%{${fg_lred}%}${1}%{${at_normal}%}] "
  else
    echo " [%{${fg_lgreen}%}${1}%{${at_normal}%}] "
  fi
}

export PROMPT=$'%3c %{${fg_lblue}%}→%{${at_normal}%} '
export RPROMPT=$'$(git_current_branch) %*'
setopt prompt_subst

export EDITOR='vim'
export PAGER='less'

# Configure LESS
export LESS_TERMCAP_mb=$'\E[01;31m'       # begin blinking
export LESS_TERMCAP_md=$'\E[01;38;5;74m'  # begin bold
export LESS_TERMCAP_me=$'\E[0m'           # end mode
export LESS_TERMCAP_se=$'\E[0m'           # end standout-mode
export LESS_TERMCAP_so=$'\E[38;5;246m'    # begin standout-mode - info box
export LESS_TERMCAP_ue=$'\E[0m'           # end underline
export LESS_TERMCAP_us=$'\E[04;38;5;146m' # begin underline

RC_DIR="${HOME}/.zsh"


# ------------------------------------------
# Helper functions
# ------------------------------------------
_display_warning() {
    echo $1 >&2
}

# This function will re-compile all rc files if needed
# and remove any old compiled version if found.
src() {
    autoload -U zrecompile

    [ -f $HOME/.zshrc ] && zrecompile -p $HOME/.zshrc
    [ -f $HOME/.zshrc.zwc.old ] && rm -f $HOME/.zshrc.zwc.old

    [ -f $HOME/.zshrc.local ] && zrecompile -p $HOME/.zshrc.local
    [ -f $HOME/.zshrc.local.zwc.old ] && rm -f $HOME/.zshrc.local.zwc.old

    for rcfile in $RC_DIR/*.zsh; do
        zrecompile -p $rcfile
        [ -f "${rcfile}.zwc.old" ] && rm -f "${rcfile}.zwc.old"
    done

    source $HOME/.zshrc
}


# ------------------------------------------
# General
# ------------------------------------------
bindkey -e # Use emacs style keys


# ------------------------------------------
# Navigation
# ------------------------------------------
alias ..='cd ..'
alias ...='cd ../..'
alias -- -='cd -'

alias ll='ls -lahtr'

bindkey -s "\C-t" "dirs -v\rcd ~"

setopt auto_name_dirs
setopt auto_pushd
setopt pushd_ignore_dups


# ------------------------------------------
# Named directories
# ------------------------------------------
W=$HOME/Workspace ; : ~W
D=$HOME/Downloads ; : ~D


# ------------------------------------------
# Command line
# ------------------------------------------
autoload -U edit-command-line
zle -N edit-command-line
bindkey '\C-x\C-e' edit-command-line


# ------------------------------------------
# Command history
# ------------------------------------------
HISTFILE=$HOME/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

setopt append_history
setopt extended_history
setopt hist_expire_dups_first
setopt hist_ignore_dups # ignore duplication command history list
setopt hist_ignore_space
setopt hist_verify
setopt inc_append_history
setopt share_history # share command history data

bindkey '^r' history-incremental-search-backward
bindkey -s "\C-h" "history\r!"


# ------------------------------------------
# Command settings
# ------------------------------------------
# grep
export GREP_OPTIONS='--color=auto'
export GREP_COLOR='1;32'

# ls
alias ls='ls -GF'


# ------------------------------------------
# Piping aliases
# ------------------------------------------
alias -g L='| less'
alias -g M='| more'
alias -g G='| grep'


# ------------------------------------------
# Autocomplete
# ------------------------------------------
autoload -Uz compinit
compinit -C
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors ''
zstyle ':completion::complete:*' cache-path $HOME/.zsh/cache/

zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'
zstyle ':completion:*:*:*:*:processes' command "ps -u `whoami` -o pid,user,comm -w -w"


# ------------------------------------------
# Colorize output of some commands
# ------------------------------------------
if [ `which grc` ]; then
  alias ping="grc --colour=auto ping"
  alias traceroute="grc --colour=auto traceroute"
  alias make="grc --colour=auto make"
fi


# ------------------------------------------
# Load other configs from ~/.zsh
# ------------------------------------------
if [ -d $RC_DIR ]; then
    for rcfile in $RC_DIR/*.zsh ; do
        if [ -r $rcfile ]; then
            source $rcfile
        else
            _display_warning "File ${rcfile} exists but is not readable."
        fi
    done
fi


# ------------------------------------------
# Load local settings
#
# ~/.zshrc.local is a place to put computer
# dependent settings, like PATH adjustments
# ------------------------------------------
[ -r $HOME/.zshrc.local ] && source $HOME/.zshrc.local

