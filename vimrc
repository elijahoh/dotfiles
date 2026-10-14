" Enable syntax highlighting
if has("syntax")
  syntax on
endif

" Maintain position on reopen
au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif

" Enable filetype detection, plugins, and indentation
filetype plugin indent on

" General usability
set mouse=a
set backspace=indent,eol,start

" Indentation settings (2 spaces)
set tabstop=2
set softtabstop=2
set shiftwidth=2
set expandtab
set autoindent

" Highlight trailing whitespace as errors
autocmd BufRead,BufNewFile * match Error /\s\+$/

" Disable history, registers, and swap files when opening sensitive files
autocmd BufReadPre .env*,*secret*,*.pem,*/.ssh/id_* setlocal nobackup nowritebackup noswapfile noundofile | set viminfo=
