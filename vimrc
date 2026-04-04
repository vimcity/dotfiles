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
                          
nnoremap d "_d
vnoremap d "_d
nnoremap D "_D                                                                                                                                                                                                                           █
nnoremap x "_x                                                                                                                                                                                                                           █
xnoremap x "_x                                                                                                                                                                                                                           █
nnoremap c "_c                                                                                                                                                                                                                           █
xnoremap c "_c
nnoremap C "_C
nnoremap X "_X
vnoremap d "_d
vnoremap D "_D
vnoremap c "_c
vnoremap C "_C
vnoremap x "_x
vnoremap X "_X
" Also need operator-pending (for dw, d$, etc.)
onoremap d "_d
onoremap D "_D
onoremap c "_c
onoremap C "_C
onoremap x "_x
onoremap X "_X

