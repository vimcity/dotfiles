return {
  'smart-splits-nvim/smart-splits.nvim',
  version = '^3.0.0',
  dependencies = {
    {
      'rawnly/smart-splits-backend-rex',
      opts = {
        -- bin = 'rex',     -- name or path of the rex executable
        -- timeout = 2000,  -- ms to wait for a rex command
      },
    },
  },
  opts = {
    mux = {
      backend = 'smart-splits-backend-rex',
    },
  },
  keys = function()
    local ss = require('smart-splits')
    return {
      { '<C-h>', ss.move_cursor_left },
      { '<C-j>', ss.move_cursor_down },
      { '<C-k>', ss.move_cursor_up },
      { '<C-l>', ss.move_cursor_right },
      { '<C-Left>', ss.resize_left },
      { '<C-Down>', ss.resize_down },
      { '<C-Up>', ss.resize_up },
      { '<C-Right>', ss.resize_right },
    }
  end,
}
