local noise = require("noise")

local shader

function love.load()
  noise.init()
  -- compile the shader. The second argument is the seed. If no seed is given,
  -- a default permutation table is used
  shader = noise.build_shader("noise.frag", 42)
end

function love.draw()
  love.graphics.translate(100, 0)
  noise.sample(shader, noise.types.simplex2d, 600, 600)
end
