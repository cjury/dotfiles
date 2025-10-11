#!/usr/bin/env bash

cd "$(dirname "${BASH_SOURCE}")";

git config --global url."https://".insteadOf git://
git submodule update --init --recursive

overwrite_all=false
overwrite_none=false

function link_config() {
  for path in .config/*; do
    local dst="$HOME/$path"

    link_file "$(pwd)/$path" "$dst"
  done
}

function link_file() {
  local src="$1"
  local dst="$2"

  local overwrite=false

  if [ -e "$dst" ]; then
    if $overwrite_none; then
      return
    fi
    if ! $overwrite_all; then
      echo "$dst already exists, overwrite?"
      select answer in "Yes" "No" "All" "None"; do
        case "$answer" in
          Yes ) overwrite=true ; break ;;
          No ) overwrite=false; break ;;
          All )
            overwrite_all=true
            overwrite=true
            break
            ;;
          None )
            overwrite_none=true
            overwrite=false
            break
            ;;
        esac
      done
    fi
  fi

  if $overwrite; then
    echo "overwriting $dst"
    rm -rf "$dst"
  fi
  ln -s "$src" "$dst"

}

function link_dotfiles() {
  link_file "$(pwd)/.Xresources" "$HOME/.Xresources"
  link_file "$(pwd)/.tmux.conf" "$HOME/.tmux.conf"

}

function install() {
    link_config
    link_dotfiles
}

if [ "$1" == "--force" -o "$1" == "-f" ]; then
    install
else
    read -p "This may overwrite existing files in your home directory. Are you sure? (y/n) " -n 1
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        install
    fi;
fi
unset sync_config
