" Rose Frappe - Catppuccin Frappe with Rose Pine rose/pink colors
" A beautiful blend of Catppuccin Frappe's dark elegance with Rose Pine's rose accents

set background=dark
hi clear
if exists("syntax_on")
    syntax reset
endif

let g:colors_name = "rose-frappe"

" Rose Frappe Color Palette
let s:bg = "#232136"           " Rose Pine Moon background
let s:surface = "#2a273f"      " Rose Pine Moon surface/secondary background
let s:text = "#c6d0f5"         " Light text
let s:text_dark = "#191724"    " Very dark text
let s:rose_pink = "#b8669c"    " Saturated rose pink (directory)
let s:rose = "#ebbcba"         " Soft rose (branch, keywords)
let s:salmon = "#f6a192"       " Salmon rose (special)
let s:rose_dark = "#eb6f92"    " Darker rose (errors, deletions)
let s:lavender = "#c4a7e7"     " Lavender (functions, info)
let s:yellow = "#f5e0ac"       " Yellow (modified, warnings)
let s:green = "#a6da95"        " Subtle green (additions)
let s:cyan = "#9ccfd8"         " Cyan (types, renames)
let s:blue = "#89b4fa"         " Blue (comments, info)

" Base highlights
exe 'hi Normal ctermfg=15 ctermbg=0 guifg=' . s:text . ' guibg=' . s:bg
exe 'hi NormalFloat ctermfg=15 ctermbg=NONE guifg=' . s:text . ' guibg=NONE'
exe 'hi FloatBorder ctermfg=9 ctermbg=NONE guifg=' . s:rose_pink . ' guibg=NONE'
exe 'hi LineNr ctermfg=8 ctermbg=NONE guifg=' . s:surface . ' guibg=NONE'
exe 'hi CursorLineNr ctermfg=9 ctermbg=NONE guifg=' . s:rose_pink . ' guibg=NONE gui=bold'
exe 'hi CursorLine ctermbg=NONE guibg=NONE'
exe 'hi Cursor guifg=' . s:bg . ' guibg=' . s:rose

" Directory and Path
exe 'hi Directory ctermfg=9 guifg=' . s:rose_pink . ' gui=bold'

" String and Character
exe 'hi String ctermfg=10 guifg=' . s:salmon
exe 'hi Character ctermfg=10 guifg=' . s:salmon

" Number and Boolean
exe 'hi Number ctermfg=9 guifg=' . s:rose
exe 'hi Boolean ctermfg=9 guifg=' . s:rose_pink . ' gui=bold'

" Function and Identifier
exe 'hi Function ctermfg=13 guifg=' . s:lavender . ' gui=bold'
exe 'hi Identifier ctermfg=13 guifg=' . s:lavender

" Keyword and Statement
exe 'hi Keyword ctermfg=9 guifg=' . s:rose . ' gui=bold'
exe 'hi Statement ctermfg=9 guifg=' . s:rose . ' gui=bold'
exe 'hi Type ctermfg=6 guifg=' . s:cyan . ' gui=bold'

" Comment
exe 'hi Comment ctermfg=8 guifg=' . s:blue

" Operator and Delimiter
exe 'hi Operator ctermfg=15 guifg=' . s:text
exe 'hi Delimiter ctermfg=15 guifg=' . s:text

" Search and selection
exe 'hi Search ctermfg=0 ctermbg=11 guifg=' . s:rose_pink . ' guibg=' . s:surface . ' gui=bold'
exe 'hi IncSearch ctermfg=0 ctermbg=9 guifg=' . s:bg . ' guibg=' . s:rose_pink . ' gui=bold'
exe 'hi Visual ctermfg=9 ctermbg=8 guifg=' . s:rose_pink . ' guibg=' . s:surface

" Diff highlights
exe 'hi DiffAdd ctermfg=10 guifg=' . s:green
exe 'hi DiffDelete ctermfg=9 guifg=' . s:rose_dark
exe 'hi DiffChange ctermfg=11 guifg=' . s:yellow
exe 'hi DiffText ctermfg=9 guifg=' . s:rose . ' gui=bold'

" Diagnostic signs
exe 'hi DiagnosticSignWarn ctermfg=11 guifg=' . s:yellow
exe 'hi DiagnosticSignError ctermfg=9 guifg=' . s:rose_dark
exe 'hi DiagnosticSignInfo ctermfg=13 guifg=' . s:lavender
exe 'hi DiagnosticSignHint ctermfg=10 guifg=' . s:salmon

" Statusline
exe 'hi StatusLine ctermfg=15 ctermbg=8 guifg=' . s:text . ' guibg=' . s:surface
exe 'hi StatusLineNC ctermfg=8 ctermbg=8 guifg=' . s:surface . ' guibg=' . s:surface

" Popup and completion menu
exe 'hi Pmenu ctermfg=15 ctermbg=8 guifg=' . s:text . ' guibg=' . s:surface
exe 'hi PmenuSel ctermfg=0 ctermbg=9 guifg=' . s:bg . ' guibg=' . s:rose_pink . ' gui=bold'
exe 'hi PmenuThumb ctermbg=9 guibg=' . s:rose_pink

" Error highlighting
exe 'hi Error ctermfg=9 guifg=' . s:rose_dark . ' gui=bold'
exe 'hi ErrorMsg ctermfg=9 guifg=' . s:rose_dark

" Warning highlighting
exe 'hi WarningMsg ctermfg=11 guifg=' . s:yellow

" Success highlighting
exe 'hi ModeMsg ctermfg=10 guifg=' . s:green

" Tabline
exe 'hi TabLine ctermfg=15 ctermbg=8 guifg=' . s:text . ' guibg=' . s:surface
exe 'hi TabLineSel ctermfg=9 ctermbg=0 guifg=' . s:rose_pink . ' guibg=' . s:bg . ' gui=bold'
exe 'hi TabLineFill ctermbg=8 guibg=' . s:surface

" Git signs (for gitsigns.nvim and similar)
exe 'hi GitSignsAdd ctermfg=10 guifg=' . s:green
exe 'hi GitSignsChange ctermfg=11 guifg=' . s:yellow
exe 'hi GitSignsDelete ctermfg=9 guifg=' . s:rose_dark

" Links for compatibility
hi! link PreProc Keyword
hi! link Constant Number
hi! link Special String
hi! link Conditional Keyword
hi! link Repeat Keyword
hi! link Label Keyword
hi! link Exception Keyword
hi! link Include Keyword
hi! link Define Keyword
hi! link Macro Keyword
hi! link Structure Type
hi! link StorageClass Type
hi! link Typedef Type
hi! link SpecialChar String
hi! link Tag Keyword
hi! link SpecialComment Comment
hi! link Debug Special
