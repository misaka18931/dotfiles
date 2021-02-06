# zsh configuration file with ohmyzsh

# set user binary to PATH
if [ -d "$HOME/.local/bin" ] ;then
  export PATH="$HOME/.local/bin:$PATH"
fi
if [ -d "$HOME/.local/script" ] ;then
  export PATH="$HOME/.local/script:$PATH"
fi

# load proxy settings
if [ -f "$HOME/.proxyrc" ] ;then
  . "$HOME/.proxyrc"
fi
# oh-my-zsh settings
export ZSH="/home/solitary/.oh-my-zsh"
ZSH_THEME="ys"

plugins=(git zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='vim'
fi

# Compilation flags
export ARCHFLAGS="-arch x86_64"

# alias
alias ~="cd"
alias ..="cd .."
alias .2="cd ../.."
alias .3="cd ../../.."
alias la="ls -a"
alias zshconf="$EDITOR ~/.zshrc"
alias xmonadconf="$EDITOR ~/.xmonad/xmonad.hs"
alias xmobarconf="$EDITOR ~/.config/xmobar/xmobar.hs"
alias ohmyzsh="$EDITOR ~/.oh-my-zsh"
alias vimconf="$EDITOR ~/.vimrc"
alias pc="proxychains4 -q "
alias clip="xclip -selection c "

# start Xsession on login
if [ "$0" = "-zsh" ] && ! [ -n "$SSH_CONNECTION" ] ;then
  exec startx
fi
