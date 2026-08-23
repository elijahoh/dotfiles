# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Basic aliases
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias vim='nvim'

# Git Prompt Setup
set_bash_prompt() {
  local branch git_info status_lines
  local staged="" unstaged="" untracked=""

  local c_branch="\[\e[38;5;110m\]"
  local c_staged="\[\e[38;5;108m\]"
  local c_unstaged="\[\e[38;5;167m\]"
  local c_untracked="\[\e[38;5;244m\]"
  local c_reset="\[\e[0m\]"

  if git rev-parse --is-inside-work-tree &>/dev/null; then
    branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
    status_lines=$(git status --porcelain 2>/dev/null)

    if [[ -n "$status_lines" ]]; then
      grep -q '^[MADRC]' <<<"$status_lines" && staged="${c_staged}+"
      grep -q '^.[MADRC]' <<<"$status_lines" && unstaged="${c_unstaged}!"
      grep -q '^??' <<<"$status_lines" && untracked="${c_untracked}?"
    fi

    git_info="${c_branch}${branch}${staged}${unstaged}${untracked}${c_reset}"
    PS1="[\u@\h \W ${git_info}]\$ "
  else
    PS1='[\u@\h \W]\$ '
  fi
}
PROMPT_COMMAND=set_bash_prompt

# Tooling Integrations
eval "$(mise activate bash)"
export PATH="$PATH:/home/eo/.local/bin"

# Source workspace functions and project shortcuts
if [ -f ~/.bash_aliases ]; then
  . ~/.bash_aliases
fi
