# ------------------------------------------------------------------------------
# PROJECT DIRECTORY REGISTRY
# ------------------------------------------------------------------------------
declare -A PROJECTS=(
  ["ex"]="$HOME/obsidianvault/1 Projects/exclamation.dev/til"
  ["exclamation"]="$HOME/projects/exclamation.dev"
  ["cs50"]="$HOME/lab/cs50p"
)

# ------------------------------------------------------------------------------
# HERDR CLI WRAPPER
# ------------------------------------------------------------------------------
herdr() {
  case "$1" in
  ls | list-sessions) command herdr session list ;;
  attach | a) [[ "$2" == "-t" && -n "$3" ]] && command herdr session attach "$3" || command herdr ;;
  new) [[ "$2" == "-s" && -n "$3" ]] && command herdr session start "$3" || command herdr ;;
  kill-session) [[ "$2" == "-t" && -n "$3" ]] && command herdr session stop "$3" || echo "Usage: herdr kill-session -t <session_name>" ;;
  kill-server) command herdr server stop ;;

  *) command herdr "$@" ;;
  esac
}

# ------------------------------------------------------------------------------
# TMUX FALLBACKS
# ------------------------------------------------------------------------------
tmux_dev() {
  local session_name="dev"
  local target_dir="${1:-$PWD}"

  if command tmux has-session -t "$session_name" 2>/dev/null; then
    command tmux attach-session -t "$session_name"
    return
  fi

  local left_top_pane
  left_top_pane=$(command tmux new-session -d -s "$session_name" -c "$target_dir" -P -F "#{pane_id}")
  command tmux send-keys -t "$left_top_pane" 'nvim' C-m

  local right_pane
  right_pane=$(command tmux split-window -h -p 10 -t "$left_top_pane" -c "$target_dir" -P -F "#{pane_id}")
  command tmux send-keys -t "$right_pane" 'aider --model openrouter/~anthropic/claude-sonnet-latest' C-m

  command tmux split-window -v -p 25 -t "$left_top_pane" -c "$target_dir" -P -F "#{pane_id}"
  command tmux select-pane -t "$left_top_pane"
  command tmux attach-session -t "$session_name"
}

# ------------------------------------------------------------------------------
# PRIMARY LAUNCHER (LazyVim + Terminal CLI + Aider)
# ------------------------------------------------------------------------------
dev() {
  local input_arg="${1:-$PWD}"
  local target_dir

  # 1. Resolve alias or raw path
  if [[ -n "${PROJECTS[$input_arg]}" ]]; then
    target_dir="${PROJECTS[$input_arg]}"
  else
    target_dir="$(realpath "$input_arg" 2>/dev/null || echo "$input_arg")"
  fi

  # 2. Verify target directory exists
  if [[ ! -d "$target_dir" ]]; then
    echo "Error: Directory '$target_dir' does not exist."
    return 1
  fi

  # 3. Fallback to Tmux if Herdr is missing
  if ! command -v herdr &>/dev/null; then
    tmux_dev "$target_dir"
    return
  fi

  local socket_path="${HERDR_SOCKET_PATH:-$HOME/.config/herdr/herdr.sock}"

  # 4. Cold-start daemon: Launch in subshell to suppress job control output ([1] PID)
  if [[ ! -S "$socket_path" ]]; then
    (command herdr server >/dev/null 2>&1 &)
    local i=0
    while [[ ! -S "$socket_path" && $i -lt 20 ]]; do
      sleep 0.1
      ((i++))
    done
  fi

  local workspace_name="$(basename "$target_dir")"
  local ws_id

  # 5. Check if workspace already exists in background daemon
  ws_id=$(command herdr workspace list 2>/dev/null | python3 -c 'import sys, json; d=json.load(sys.stdin); print("\n".join(w["workspace_id"] for w in d.get("result",{}).get("workspaces",[]) if w.get("label")=="'"$workspace_name"'"))' 2>/dev/null | head -n1)

  # 6. Build 3-pane layout via CLI
  if [[ -n "$ws_id" ]]; then
    command herdr workspace focus "$ws_id" >/dev/null 2>&1
  else
    local res_ws new_ws_id p_top_left res_aider p_right
    res_ws=$(command herdr workspace create --label "$workspace_name" --cwd "$target_dir" 2>/dev/null)
    new_ws_id=$(echo "$res_ws" | python3 -c 'import sys, json; d=json.load(sys.stdin); print(d.get("result",{}).get("workspace",{}).get("workspace_id",""))' 2>/dev/null)
    p_top_left=$(echo "$res_ws" | python3 -c 'import sys, json; d=json.load(sys.stdin); print(d.get("result",{}).get("root_pane",{}).get("pane_id",""))' 2>/dev/null)

    if [[ -n "$new_ws_id" ]]; then
      command herdr workspace focus "$new_ws_id" >/dev/null 2>&1
    fi

    if [[ -n "$p_top_left" ]]; then
      # Pane 1 (Top-Left): LazyVim
      command herdr pane run "$p_top_left" "nvim" >/dev/null 2>&1

      # Pane 2 (Right): Aider AI
      res_aider=$(command herdr pane split "$p_top_left" --direction right --cwd "$target_dir" 2>/dev/null)
      p_right=$(echo "$res_aider" | python3 -c 'import sys, json; d=json.load(sys.stdin); print(d.get("result",{}).get("pane",{}).get("pane_id",""))' 2>/dev/null)
      if [[ -n "$p_right" ]]; then
        command herdr pane run "$p_right" "aider --model openrouter/~anthropic/claude-sonnet-latest" >/dev/null 2>&1
      fi

      # Pane 3 (Bottom-Left): Terminal CLI
      command herdr pane split "$p_top_left" --direction down --cwd "$target_dir" 2>/dev/null 2>&1

      # Refocus LazyVim pane
      command herdr pane focus --direction up >/dev/null 2>&1
    fi
  fi

  # 7. Attach interactive client
  if [[ -z "$HERDR_ENV" ]]; then
    cd "$target_dir" || return
    command herdr
  fi
}
