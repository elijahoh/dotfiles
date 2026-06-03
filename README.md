# Dotfiles

Personal Unix/Linux configuration files for shell, Vim, and tmux, managed in a Git repository and linked into `$HOME` with symbolic links.

## What this repo is for

This repository keeps configuration files in one version-controlled place so they are easier to back up, review, and reuse across machines.
Applications such as Bash, Vim, and tmux still expect their config files in standard locations like `~/.bashrc`, `~/.vimrc`, and `~/.tmux.conf`, so symlinks are used to connect those expected paths back to the files stored here.

## Managed files

This repo currently manages:

- `.bashrc`
- `.vimrc`
- `.tmux.conf`

A common convention is to store these files in the repository without the leading dot, then symlink them back into `$HOME` with the expected dot-prefixed names.
For example:

- `bashrc` -> `~/.bashrc`
- `vimrc` -> `~/.vimrc`
- `tmux.conf` -> `~/.tmux.conf`

## Why symlinks

Symlinks let the system and applications keep using the standard config paths while the real files stay in this repository as the single source of truth.
That means edits are made once in the repo, tracked with Git, and immediately reflected when Bash, Vim, or tmux reads the linked file.

## Repository layout

```text
~/dotfiles/
├── bashrc
├── vimrc
├── tmux.conf
├── setup
└── README.md
```

You can expand this later with additional config directories such as `git/`, `nvim/`, or `alacritty/`, depending on how you want to organize the repository.

## Setup

Clone the repository into your home directory:

```bash
git clone https://github.com/elijahoh/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

Then run the setup script:

```bash
chmod +x setup
./setup
```

A typical setup flow is:

1. Check whether the target config files already exist in `$HOME`.
2. Back up existing files into a timestamped backup directory.
3. Move or copy the tracked files into `~/dotfiles` if needed.
4. Create symlinks from `$HOME` back to the repository files.

## Example linking

Manual linking would look like this:

```bash
ln -s ~/dotfiles/bashrc ~/.bashrc
ln -s ~/dotfiles/vimrc ~/.vimrc
ln -s ~/dotfiles/tmux.conf ~/.tmux.conf
```

This is the same basic symlink pattern commonly used in dotfiles setups, whether managed manually or by bootstrap tools.
## Backups

The setup script should back up any existing config files before replacing them with symlinks.
A timestamped backup directory makes it easier to restore earlier files and avoids overwriting an older backup.

Example:

```text
~/backups/20260502_092925/
├── .bashrc
├── .vimrc
└── .tmux.conf
```

## Notes

- `~/.config` is mainly for modern XDG-style applications; traditional files like `.bashrc` and `.vimrc` are still usually read from `$HOME` unless explicitly reconfigured.
- Using `$HOME` in scripts is usually safer than `~` because it behaves more predictably in quoted strings and scripted paths.
- Keep the setup script idempotent where possible so rerunning it does not destroy existing backups or create broken links.

## License

MIT © @elijahoh
