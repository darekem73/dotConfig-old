set number  "This turns on line numbering
"set numberwidth=4       "Set the line numbers to 4 spaces
"set expandtab
"set shiftwidth=4
"set softtabstop=4
set smartindent
nnoremap <F2> :set invpaste paste?<CR>
set pastetoggle=<F2>
set showmode

nnoremap <F5> "=strftime("%Y-%m-%d %T")<CR>P
inoremap <F5> <C-R>=strftime("%Y-%m-%d %T")<CR>

set nocompatible
syntax on
set nowrap
"set nobackup
"set nowritebackup
set noswapfile
set backspace=indent,eol,start
set ruler
set noeb
set vb
set t_vb= 
if has('autocmd')
        autocmd GUIEnter * set vb t_vb=
endif

set hlsearch
"set relativenumber

filetype plugin indent on
let vimclojure#HighlightBuiltins = 1

if v:progname =~? "gvim"
        set guifont=AR\ PL\ UMing\ TW\ Light\ 11
        set guioptions=agimrLtT
        unmenu ToolBar
        unmenu! ToolBar
endif

"set guifont=DejaVu\ Sans\ Mono\ 12
set guifont=ProFontWindows\ 14

"colorscheme osx_like
colorscheme desert

