set tabstop=2
set shiftwidth=2
set expandtab
syntax on
set termguicolors
set background=dark

" ===========================================
" Catppuccin Theme
" ===========================================
colorscheme catppuccin_frappe

" ===========================================
" Cursor Shape Configuration
" ===========================================
" Thin line cursor in insert mode, block in normal mode
let &t_SI = "\e[6 q"  " Insert mode: thin line
let &t_EI = "\e[2 q"  " Normal mode: block
" Reset cursor on vim exit
autocmd VimLeave * silent !echo -ne "\e[2 q"

" ===========================================
" Clipboard Integration
" ===========================================
" Enable system clipboard for yank/paste operations
set clipboard=unnamed     " Use system clipboard on macOS
" Alternative: set clipboard=unnamedplus  " Use this on Linux 
                          

