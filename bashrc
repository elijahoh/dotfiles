# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Environment Variables
export EDITOR="nvim"
export KUBE_EDITOR="nvim"

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
[[ ":$PATH:" != *":$HOME/.local/bin:"* ]] && export PATH="$PATH:$HOME/.local/bin"

### MANAGED BY RANCHER DESKTOP START (DO NOT EDIT)

export PATH="/home/eo/.rd/bin:$PATH"
### MANAGED BY RANCHER DESKTOP END (DO NOT EDIT)

# Clean duplicate directories from PATH
export PATH="$(echo "$PATH" | awk -v RS=: -v ORS=: '!seen[$0]++' | sed 's/:$//')"

# Kubectl completion

if command -v kubectl &>/dev/null; then
  # Load system bash completion if not already initialized
  if ! declare -F _init_completion &>/dev/null; then

    [ -r /usr/share/bash-completion/bash_completion ] && source /usr/share/bash-completion/bash_completion
  fi

  source <(kubectl completion bash)
  complete -o default -F __start_kubectl k
fi

# Source workspace functions and project shortcuts
if [ -f ~/.bash_aliases ]; then
  source ~/.bash_aliases
fi
