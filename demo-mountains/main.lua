local noise = require("noise")

local noise_shader
local range_shader
local noise_texture
local x = 0.0
local ranges = 10

function love.load()
  noise.init()
  -- compile the shader. The second argument is the seed. If no seed is given,
  -- a default permutation table is used
  noise_shader = noise.build_shader("noise.frag", 43)
  noise_shader:send("encoding", 24)
  range_shader = love.graphics.newShader("range.frag")
  noise_texture = love.graphics.newCanvas(800, ranges)
  noise_texture:setFilter("nearest", "nearest")
end

local fps = 0
local second_acc = 0
local frames_this_second = 0

local sky = {0.98, 0.77, 0.53}

function love.draw()
  -- Render noise to the noise texture
  love.graphics.push()
  love.graphics.setCanvas(noise_texture)
  love.graphics.clear(64, 64, 64, 255)
  love.graphics.setShader(noise_shader)
  local octaves = 3
  local frequency_mults = {1, 5, 2}
  local alpha_dampening = {.5, .1, .01}
  for i=1,ranges do
    -- Sample noise at different frequencies
    for octave=1,octaves do
      love.graphics.setColor(255, 255, 255, 255 * alpha_dampening[octave])
      noise.sample(noise_shader, noise.types.simplex2d, 800, 1,
                   frequency_mults[octave] * x * (i/ranges), 4 * i,
                   1.5 * frequency_mults[octave], 0)
    end
    love.graphics.translate(0, 1)
  end
  love.graphics.setCanvas()
  love.graphics.pop()

  love.graphics.clear(sky[1] * 255, sky[2] * 255, sky[3] * 255)
  love.graphics.setColor(37, 37, 37, 255)
  love.graphics.print(string.format("%d FPS", fps), 2, 2)
  love.graphics.translate(0, 200)
  range_shader:send("fade_color", sky)
  range_shader:send("ranges", ranges)
  love.graphics.setShader(range_shader)
  love.graphics.setColor(37, 37, 37, 255)
  for i=1,ranges do
    range_shader:send("range", i)
    love.graphics.translate(0, 10 + (i) * 2)
    love.graphics.draw(noise_texture, 0, 0, 0, 1, (100 + 20 * i)/ranges)
  end
  love.graphics.setShader()
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
