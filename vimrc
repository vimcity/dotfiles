set tabstop=2
set shiftwidth=2
set expandtab
syntax on
set termguicolors
set background=dark

colorscheme catppuccin_frappe

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

" Normal-mode p uses Neovim's local yank register. Paste the host clipboard
" with the terminal's native paste shortcut, which also works over SSH.
nnoremap p "0p
xnoremap p "0p

" Keep change/cut operations out of clipboard.
nnoremap c "_c
nnoremap C "_C
nnoremap x "_x
nnoremap X "_X

xnoremap c "_c
xnoremap C "_C
xnoremap x "_x
xnoremap X "_X
nnoremap ^ $
nnoremap $ ^

" ===========================================
" Scroll Centering
" ===========================================
nnoremap <C-d> <C-d>zz
nnoremap <C-u> <C-u>zz
set rtp+=/opt/homebrew/opt/fzf
