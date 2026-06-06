#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
#PS1='[\u@\h \W]\$ '

set_bash_prompt() {
  local branch git_info status_lines
  local staged="" unstaged="" untracked=""

  # Subtle ANSI 256-colors
  local c_branch="\[\e[38;5;110m\]"   # Muted slate blue
  local c_staged="\[\e[38;5;108m\]"   # Soft sage green (+)
  local c_unstaged="\[\e[38;5;167m\]" # Soft coral/red (!)
  # Using 244 to perfectly match your middle-grey Tmux text color
  local c_untracked="\[\e[38;5;244m\]" # Neutral grey (?)
  local c_reset="\[\e[0m\]"            # Reset text

  if git rev-parse --is-inside-work-tree &>/dev/null; then
    branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)

    # Read the quick-parse status format
    status_lines=$(git status --porcelain 2>/dev/null)

    if [[ -n "$status_lines" ]]; then
      # 1. Has staged changes (Changes in index)
      if grep -q '^[MADRC]' <<<"$status_lines"; then
        staged="${c_staged}+"
      fi
      # 2. Has unstaged changes (Changes in working tree)
      if grep -q '^.[MADRC]' <<<"$status_lines"; then
        unstaged="${c_unstaged}!"
      fi
      # 3. Has untracked files
      if grep -q '^??' <<<"$status_lines"; then
        untracked="${c_untracked}?"
      fi
    fi

    # Combine them cleanly right next to the branch name
    git_info="${c_branch}${branch}${staged}${unstaged}${untracked}${c_reset}"
    PS1="[\u@\h \W ${git_info}]\$ "
  else
    PS1='[\u@\h \W]\$ '
  fi
}

PROMPT_COMMAND=set_bash_prompt

eval "$(mise activate bash)"

# Custom Tmux Python Development Profile
tp() {
  local session_name="py-dev"

  # 1. Start a new detached tmux session (-d) named 'py-dev'
  tmux new-session -d -s "$session_name"

  # 2. Automatically launch Neovim in the top pane
  tmux send-keys -t "$session_name" 'nvim' C-m

  # 3. Split the screen horizontally (-v).
  # Give the new bottom pane 25% of the height, leaving 75% for Neovim on top.
  # Add -d so the cursor stays at the top pane
  tmux split-window -d -v -p 25 -t "$session_name"

  # 4. Move keyboard focus back up to the big Neovim pane (pane 0)
  tmux select-pane -t "$session_name".0

  # 5. Attach to your newly created workspace
  tmux attach-session -t "$session_name"
}
