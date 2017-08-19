local noise = require("noise")

local shader
local dummy_texture


local time = 0
local fps = 0
local second_acc = 0
local frames_this_second = 0

-- offsets
local x, y, z = 0.0, 0.0, 0.0
local freq = 1.0
local seed = 124

local current_mode -- noise mode
local modes = {
  [1] = "2D classic noise",
  [2] = "2D simplex noise",
  [3] = "3D classic noise",
  [4] = "3D simplex noise",
  [5] = "4D classic noise",
  [6] = "4D simplex noise"
}

function love.load()
  love.window.setMode(800, 600, {vsync = false, resizable = true})
  dummy_texture = love.graphics.newCanvas(1, 1)
  shader = noise.build_shader("noise.frag", seed)
end

function love.draw()
  local w, h = love.window.getMode()
  local draw_h = h - 40
  local min = math.min(w, draw_h)
  local pos_x = (w - min) / 2
  local pos_y = (draw_h - min) / 2 + 20
  love.graphics.setShader(shader)
  love.graphics.draw(dummy_texture, pos_x, pos_y, 0, min, min)
  love.graphics.setShader()
  love.graphics.setColor(255, 255, 255, 255)
  local info_string = string.format("FPS: %d\t%s", fps,
                                    modes[current_mode] or "Press 1-6 to switch modes")
  love.graphics.print(info_string, 10, 2)
  local position_string = string.format("x: %f\ty: %f\tz: %f\tfreq: %f\tseed: %s\tsamples/frame: %d",
                                        x, y, z, freq, seed, min*min)
  love.graphics.print(position_string, 10, h - 18)
end

function love.update(dt)
  frames_this_second = frames_this_second + 1
  second_acc = second_acc + dt
  if second_acc > 1 then
    second_acc = second_acc - 1
    fps = frames_this_second
    frames_this_second = 0
  end

  time = time + dt
  shader:send("w", time)

  local speed = .5
  if love.keyboard.isDown("a") then x = x - dt * speed end
  if love.keyboard.isDown("d") then x = x + dt * speed end
  shader:send("x", x)

  if love.keyboard.isDown("w") then y = y - dt * speed end
  if love.keyboard.isDown("s") then y = y + dt * speed end
  shader:send("y", y)

  if love.keyboard.isDown("r") then z = z + dt * speed end
  if love.keyboard.isDown("f") then z = z - dt * speed end
  shader:send("z", z)

  if love.keyboard.isDown("c") then freq = freq * ((1 + dt * speed)) end
  if love.keyboard.isDown("x") then freq = freq / ((1 + dt * speed)) end
  shader:send("freq", freq)
end

function love.keypressed(key)
  local mode = tonumber(key)
  if mode and modes[mode] then
    current_mode = mode
    shader:send("mode", mode)
  end
end
