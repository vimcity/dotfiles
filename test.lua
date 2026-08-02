   -- create a new scratch buffer and show it
local buf = vim.api.nvim_create_buf(false, true)
vim.api.nvim_win_set_buf(0, buf)
local stop = require("milli").shader(buf, { shader = "rain" })

  -- aiface               AI face, talking-head loop
  -- attackontitan        Attack on Titan tribute
  -- aurora               Northern-lights color sweep
  -- badge                Spinning milli badge
  -- cactus               Chill pixel cactus
  -- catwoman             Catwoman portrait loop
  -- chrome               Chrome logo spin
  -- dancer               Dancing figure
  -- doomfire             Classic PSX DOOM fire, 70x14
  -- flyingcat            Cat cruising through space
  -- flyingdragon         Dragon in flight
  -- hack-matrix          HACK revealed by matrix rain
  -- ididnot              "I did not hit her" meme
  -- lighningtornado      Lightning tornado
  -- lights               Drifting light streaks
  -- milli-fire           MILLI wordmark burning in procedural fire
  -- retrocircle          Retro circle tunnel
  -- robot                Robot head loop
  -- shader               Abstract shader loop
  -- shadertwo            Abstract shader loop II
  -- skullone             Skull I
  -- skullthree           Skull III
  -- skulltwo             Skull II
  -- spaceship            Spaceship flight
  -- spinner              Minimal loading spinner
  -- vibecattwo           Vibing cat II
