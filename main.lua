local noise = require("noise")

local shader
local dummy_texture


local time = 0
local fps = 0
local second_acc = 0
local frames_this_second = 0

local do_show_help = false
local help_text = [[HELP

Press 1-6 to select the type of noise
Press A and D to change the x offset
Press W and S to change the y offset
Press R and F to change the z offset
Press J and L to change the frequency along the x axis
Press I and K to change the frequency along the y axis

]]

-- offsets
local x, y, z = 0.0, 0.0, 0.0
local freq_x, freq_y = 1.0, 1.0
local seed = 124

local current_type = 1 -- noise type
local types = {
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
  noise.init()
  shader = noise.build_shader("noise.frag", seed)
end

function love.draw()
  local w, h = love.window.getMode()
  local draw_w = w - 20
  local draw_h = h - 60
  local min = math.min(draw_w, draw_h)
  local pos_x = (draw_w - min) / 2 + 20
  local pos_y = (draw_h - min) / 2 + 40
  love.graphics.setColor(255, 255, 255, 255)
  -- Draw coordinates
  -- x1
  love.graphics.line(pos_x, pos_y + min, pos_x, pos_y - 18)
  love.graphics.printf(string.format("x1 = %f", x),
                       pos_x + 4, pos_y - 18, min - 8, "left", 0)
  -- x2
  love.graphics.line(pos_x + min, pos_y + min, pos_x + min, pos_y - 18)
  love.graphics.printf(string.format("x2 = %f", x + freq_x),
                       pos_x + 4, pos_y - 18, min - 8, "right", 0)

  -- y1
  love.graphics.line(pos_x + min, pos_y, pos_x - 18, pos_y)
  love.graphics.printf(string.format("y1 = %f", y),
                       pos_x - 2, pos_y + 4, min - 8, "left", math.rad(90))
  -- y2
  love.graphics.line(pos_x + min, pos_y + min, pos_x - 18, pos_y + min)
  love.graphics.printf(string.format("y2 = %f", y + freq_y),
                       pos_x - 2, pos_y + 4, min - 8, "right", math.rad(90))

  -- Draw noise
  love.graphics.setShader(shader)
  love.graphics.push()
    love.graphics.translate(pos_x, pos_y)
    noise.sample(shader, current_type, min, min, x, y, freq_x, freq_y, z, time)
  love.graphics.pop()
  love.graphics.setShader()

  local info_string = string.format("FPS: %d\t%s", fps, types[current_type])
  love.graphics.print(info_string, 10, 2)
  local position_string = string.format("x: %f\ty: %f\tz: %f\tfreq_x: %f\tfreq_y: %f\tseed: %s\tsamples/frame: %d",
                                        x, y, z, freq_x, freq_y, seed, min*min)
  love.graphics.print(position_string, 10, h - 18)
  love.graphics.printf("Press H for help", 10, h - 18, w - 20, "right")

  if do_show_help then
    local border = 50
    love.graphics.setColor(0, 0, 0, 128)
    love.graphics.rectangle("fill", border, border, w - 2 * border, h - 2 * border)
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.printf(help_text, border + 2, border + 2, w - 2 * (border + 2))
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

  if love.keyboard.isDown("l") then freq_x = freq_x * ((1 + dt * speed)) end
  if love.keyboard.isDown("j") then freq_x = freq_x / ((1 + dt * speed)) end
  shader:send("freq_x", freq_x)

  if love.keyboard.isDown("k") then freq_y = freq_y * ((1 + dt * speed)) end
  if love.keyboard.isDown("i") then freq_y = freq_y / ((1 + dt * speed)) end
  shader:send("freq_y", freq_y)

  do_show_help = love.keyboard.isDown("h")
end

function love.keypressed(key)
  local type = tonumber(key)
  if type and types[type] then
    current_type = type
    shader:send("type", type)
  end
end
