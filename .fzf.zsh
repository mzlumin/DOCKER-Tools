# Setup fzf
# ---------
if [[ ! "$PATH" == */home/mzulmin/.fzf/bin* ]]; then
  export PATH="${PATH:+${PATH}:}/home/mzulmin/.fzf/bin"
fi

# Auto-completion
# ---------------
[[ $- == *i* ]] && source "/home/mzulmin/.fzf/shell/completion.zsh" 2> /dev/null

# Key bindings
# ------------
source "/home/mzulmin/.fzf/shell/key-bindings.zsh"