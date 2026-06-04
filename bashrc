#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
#PS1='[\u@\h \W]\$ '

# Function to dynamically build the colored prompt
set_bash_prompt() {
    local branch dirty git_info

    # Subtle ANSI 256-colors
    local c_branch="\[\e[38;5;110m\]" # Muted slate blue/cyan
    local c_dirty="\[\e[38;5;167m\]"  # Soft coral/red
    local c_reset="\[\e[0m\]"         # Reset back to standard text

    if git rev-parse --is-inside-work-tree &>/dev/null; then
        branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)

        if [[ -n $(git status --porcelain 2>/dev/null) ]]; then
            dirty="${c_dirty}*"
        else
            dirty=""
        fi

        git_info="${c_branch}${branch}${dirty}${c_reset}"
        PS1="[\u@\h \W ${git_info}]\$ "
    else
        # Standard prompt if not inside a git repo
        PS1='[\u@\h \W]\$ '
    fi
}

# Run the function before drawing every prompt line
PROMPT_COMMAND=set_bash_prompt

eval "$(mise activate bash)"
