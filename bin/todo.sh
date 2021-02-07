#!/usr/bin/env zsh
# work with vim-todo-list

pref="$HOME/.todo"
load=""
month=$(date +"%Y%m")

get() {
  if ! [ -f "$pref/conf" ] ;then
    echo $0
    exit 1
  fi
  cat "$pref/conf" | read load
}

parse() {
  echo "$month" > "$pref/conf"
}

_exec() {
  if ! [ -f "$pref/$month.todo.md" ] ;then
    echo $0
    exit 1
  fi
  vim "$pref/$month.todo.md"
}

new_month() {
  curr="$pref/$1"
  prev="$pref/$2"
  echo "-- Uncompleted Lists from $load --" >> "$pref/$month.todo.md"
  cat "$pref/$load.todo.md" | grep "\[\s\]" >> "$pref/$month.todo.md"
}

manage() {
  if [ "$load" != "$month" ] ;then
    new_month
  fi
  date="-- $(date +"%b %d, %Y") --"
  cat "${pref}/$month.todo.md" | grep -q -e "$date"
  if ! [ "$?" -eq 0 ] ;then
    printf "\n$date\n" >> "$pref/$month.todo.md"
  fi
}

main() {
  todo=$(find -maxdepth 1 -name "*.todo.md")
  if [ -n "$todo" ] ;then
    vim "$todo"
  else
    if [ -d "$pref" ] ;then
      get
      manage
      parse
      _exec
    fi
  fi
  unset todo
}

main "$@"
