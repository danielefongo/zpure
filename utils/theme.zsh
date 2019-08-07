__shapeshift_config_dir="$HOME/.shapeshift"
__shapeshift_theme_name="shapeshift.theme"
__shapeshift_default_file="$__shapeshift_config_dir/default"

if [[ ! -d "$__shapeshift_config_dir" ]]; then
  mkdir -p "$__shapeshift_config_dir"
fi

function __shapeshift_load() {
    source "$__shapeshift_path/properties"

    if [[ -f "$__shapeshift_default_file" ]]; then
      local chosenRepo=$(cat $__shapeshift_default_file)
      local themeFile="$__shapeshift_config_dir/$chosenRepo/$__shapeshift_theme_name"

      if [[ -f "$themeFile" ]]; then
        source "$themeFile"
      fi
    fi

    reset_results
}

function __shapeshift_set() {
  local repo=$1

  local themeFile="$__shapeshift_config_dir/$repo/$__shapeshift_theme_name"

  if [[ -f "$themeFile" ]]; then
    echo $repo > "$__shapeshift_default_file"
  else
    echo "Not a valid theme"
    return 1
  fi
}

function __shapeshift_import() {
  local repo=$1
  (
    if [[ ! -d $__shapeshift_config_dir/$repo ]]; then
      git clone "https://github.com/$repo" "$__shapeshift_config_dir/$repo" &>/dev/null
      if [[ $? -ne 0 ]]; then
        echo "Not a valid repo"
        return 1
      fi
    fi

    if [[ ! -f "$__shapeshift_config_dir/$repo/$__shapeshift_theme_name" ]]; then
      echo "Not a valid theme"
      rm -rf "$__shapeshift_config_dir/$repo"
      return 1
    fi

    echo "Theme $repo imported"
  )
}

function __shapeshift_themes() {
  (
    if [[ -d "$__shapeshift_config_dir" ]]; then
      cd "$__shapeshift_config_dir"
      find . -mindepth 2 -maxdepth 2 -type d | sed -E 's/\.\///'
    fi
  )
}

function __shapeshift_unique_theme() {
  set -A __shapeshift_repo_names $(__shapeshift_themes | grep -e "/$1$")

  case ${#__shapeshift_repo_names[@]} in
    0 ) ;;
    1 ) repo=${__shapeshift_repo_names[1]};;
    * ) echo "duplicated, use one of the following:"
        echo "- ${(j:\n- :)__shapeshift_repo_names}"
        return 1;;
  esac
}

function shape-shift() {
  local repo=$1
  local importStatus=0

  if [[ -z $repo ]]; then
    rm "$__shapeshift_default_file" 2>/dev/null
  else
    __shapeshift_unique_theme $repo || return

    if [[ ! -d "$__shapeshift_config_dir/$repo" ]]; then
      __shapeshift_import $repo
      importStatus=$?
    fi

    if [[ $importStatus -eq 0 ]]; then
      __shapeshift_set $repo
    fi
  fi

  __shapeshift_load
}

function shape-reshape() {
  (
    __shapeshift_themes | while read repo; do
      cd "$__shapeshift_config_dir/$repo"
      git fetch &>/dev/null

      local upstream=${1:-'@{u}'}
      local local=$(git rev-parse @)
      local remote=$(git rev-parse "$upstream")
      local base=$(git merge-base @ "$upstream")

      if [ $local != $remote -a $local = $base ]; then
        git pull &>/dev/null
        echo "$repo updated."
      fi
    done
  )

  __shapeshift_load
}

if declare -f antigen > /dev/null; then
  fpath+="$__shapeshift_path/_shape-shift"
else
  source "$__shapeshift_path/_shape-shift"
  autoload -U +X compinit && compinit
  compdef _shape-shift shape-shift
fi