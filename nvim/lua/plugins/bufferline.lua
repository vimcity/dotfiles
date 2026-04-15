-- Keep showtabline=2 always so native Vim tabs (:tabnew, gt/gT) remain visible
-- LazyVim defaults always_show_bufferline=false which lets bufferline set showtabline=0
-- when only one buffer is open, which also hides the native tabline.
return {
  "akinsho/bufferline.nvim",
  opts = {
    options = {
      always_show_bufferline = true,
    },
  },
}
