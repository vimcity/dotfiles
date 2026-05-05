set tabstop=2
set shiftwidth=2
set expandtab
syntax on
set termguicolors
set background=dark

" ===========================================
" Catppuccin Theme
" ===========================================
" colorscheme catppuccin_macchiato

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
                          
" Delete/change without yanking into the default register.
" Keep these in normal/visual modes only; operator-pending maps break `dd`.
nnoremap d "_d
nnoremap D "_D
nnoremap c "_c
nnoremap C "_C
nnoremap x "_x
nnoremap X "_X

xnoremap d "_d
xnoremap D "_D
xnoremap c "_c
xnoremap C "_C
xnoremap x "_x
xnoremap X "_X

" ===========================================
" Scroll Centering
" ===========================================
nnoremap <C-d> <C-d>zz
nnoremap <C-u> <C-u>zz
set rtp+=/opt/homebrew/opt/fzf
