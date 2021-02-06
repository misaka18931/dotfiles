#!/bin/bash
# bash config file
# last update: 02-03-21

# set user executables to PATH
if [ -d "$HOME/.local/bin" ]; then
	export PATH=$HOME/.local/bin:$PATH
fi

if [ -d "$HOME/.local/script" ]; then
	export PATH=$HOME/.local/script:$PATH
fi
export LANG=en_US.UTF-8
export http_proxy="http://localhost:8889/"

# load proxy
if [ -f "$HOME/.proxyrc" ] ;then
  . "$HOME/.proxyrc"
fi
