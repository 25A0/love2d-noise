local noise = require("noise")

local shader
local x = 0.0

function love.load()
  noise.init()
  -- compile the shader. The second argument is the seed. If no seed is given,
  -- a default permutation table is used
  shader = noise.build_shader("range.frag", 43)
end

local fps = 0
local second_acc = 0
local frames_this_second = 0

function love.draw()
  local sky = {0.98, 0.77, 0.53}
  love.graphics.clear(sky[1] * 255, sky[2] * 255, sky[3] * 255)
  love.graphics.setColor(37, 37, 37, 255)
  love.graphics.print(string.format("%d FPS", fps), 2, 2)
  love.graphics.translate(0, 200)
  local ranges = 10
  shader:send("fade_color", sky)
  for i=1,ranges do
    shader:send("dist", (ranges - i)/ranges)
    love.graphics.translate(0, 10 + (i) * 2)
    noise.sample(shader, noise.types.simplex2d, 800, 100 + 20 * i, x * (i/ranges), 4 * i, 1.5, 0)
  end
end

function love.update(dt)
  frames_this_second = frames_this_second + 1
  second_acc = second_acc + dt
  if second_acc > 1 then
    second_acc = second_acc - 1
    fps = frames_this_second
    frames_this_second = 0
  end

  local speed = .5
  if love.keyboard.isDown("a") then x = x - dt * speed end
  if love.keyboard.isDown("d") then x = x + dt * speed end
end
