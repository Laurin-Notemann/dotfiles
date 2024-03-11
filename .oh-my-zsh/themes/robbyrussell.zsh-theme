git_show_staged() {
  if ! git rev-parse --is-inside-work-tree &> /dev/null; then
    return
  fi

  local git_status="$(git status --porcelain --untracked-files)"
  local staged_files=0 unstaged_files=0 total_unstaged_files=0 unpushed_commits=0

  while IFS= read -r line; do
    if [[ $line =~ ^[AMDR] ]]; then
      ((staged_files++))
    fi
    if [[ $line =~ ^\.[MD] ]] || [[ $line =~ '^\?\?' ]]; then
      ((total_unstaged_files++))
    fi
    if [[ $line =~ ^UU ]]; then
      ((staged_files--))  # Undo count increment for unmerged files, treated as unstaged
      ((total_unstaged_files++))
    fi
  done <<< "$git_status"

  unstaged_files=$((total_unstaged_files))  # Includes untracked files

  if git rev-parse --verify HEAD &> /dev/null; then
    local current_branch=$(git rev-parse --abbrev-ref HEAD)
    local upstream=$(git for-each-ref --format='%(upstream:short)' $(git symbolic-ref -q HEAD))
    if [[ -n $upstream ]]; then
      unpushed_commits=$(git rev-list --count $upstream..HEAD)
    fi
  else
    unpushed_commits=0
  fi

  local output=""

  if [[ -n $git_status || $unpushed_commits -gt 0 ]]; then
    if [[ $staged_files -gt 0 || $unstaged_files -gt 0 || $unpushed_commits -gt 0 ]]; then
      output="%B%F{#C6C8CF}${unstaged_files}/${staged_files}/${unpushed_commits} "
    fi
  fi

  echo -n "$output"
}



git_clean_dirty_color() {
  if ! git rev-parse --is-inside-work-tree &> /dev/null; then
    return
  fi

  local git_status="$(git status --porcelain 2>/dev/null)"
  if [[ -n $git_status ]]; then
    echo "%B%F{#D1246A}"
  else
    echo "%B%F{#24D18B}"
  fi
}

ZSH_THEME_GIT_PROMPT_PREFIX="("
ZSH_THEME_GIT_PROMPT_SUFFIX=") "
ZSH_THEME_GIT_PROMPT_DIRTY=""
ZSH_THEME_GIT_PROMPT_CLEAN=""

PROMPT='%B%F{#C6C8CF} %c $(git_clean_dirty_color)$(git_prompt_info)$(git_show_staged)%f%b'
