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
" Keep system clipboard only for explicit yank/paste mappings.
" Sync clipboard only after yank. Delete/change won't overwrite it.
set clipboard=

augroup YankToClipboard
  autocmd!
  autocmd TextYankPost * if v:event.operator ==# 'y' | call setreg('+', getreg('0')) | endif
augroup END

nnoremap p "+p
xnoremap p "+p

" Keep change/cut operations out of clipboard.
nnoremap c "_c
nnoremap C "_C
nnoremap x "_x
nnoremap X "_X

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
