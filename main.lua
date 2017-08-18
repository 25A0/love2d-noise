local shader
local dummy_texture

local unpack = unpack or table.unpack

-- Builds the noise shader.
-- Adapted from Stefan Gustavson's GLSLnoise4.c
local function build_shader(path_to_shader)
  local shader = love.graphics.newShader(path_to_shader)

  -- permutation table
  local perm = {151, 160, 137, 91, 90, 15, 131, 13, 201, 95, 96, 53, 194, 233,
                7, 225, 140, 36, 103, 30, 69, 142, 8, 99, 37, 240, 21, 10, 23,
                190, 6, 148, 247, 120, 234, 75, 0, 26, 197, 62, 94, 252, 219,
                203, 117, 35, 11, 32, 57, 177, 33, 88, 237, 149, 56, 87, 174,
                20, 125, 136, 171, 168, 68, 175, 74, 165, 71, 134, 139, 48, 27,
                166, 77, 146, 158, 231, 83, 111, 229, 122, 60, 211, 133, 230,
                220, 105, 92, 41, 55, 46, 245, 40, 244, 102, 143, 54, 65, 25,
                63, 161, 1, 216, 80, 73, 209, 76, 132, 187, 208, 89, 18, 169,
                200, 196, 135, 130, 116, 188, 159, 86, 164, 100, 109, 198, 173,
                186, 3, 64, 52, 217, 226, 250, 124, 123, 5, 202, 38, 147, 118,
                126, 255, 82, 85, 212, 207, 206, 59, 227, 47, 16, 58, 17, 182,
                189, 28, 42, 223, 183, 170, 213, 119, 248, 152, 2, 44, 154, 163,
                70, 221, 153, 101, 155, 167, 43, 172, 9, 129, 22, 39, 253, 19,
                98, 108, 110, 79, 113, 224, 232, 178, 185, 112, 104, 218, 246,
                97, 228, 251, 34, 242, 193, 238, 210, 144, 12, 191, 179, 162,
                241, 81, 51, 145, 235, 249, 14, 239, 107, 49, 192, 214, 31, 181,
                199, 106, 157, 184, 84, 204, 176, 115, 121, 50, 45, 127, 4, 150,
                254, 138, 236, 205, 93, 222, 114, 67, 29, 24, 72, 243, 141, 128,
                195, 78, 66, 215, 61, 156, 180}

  -- gradient table for 2D and 3D
  local grad3 = {{ 0, 1, 1},{ 0, 1,-1},{ 0,-1, 1},{ 0,-1,-1},
                 { 1, 0, 1},{ 1, 0,-1},{-1, 0, 1},{-1, 0,-1},
                 { 1, 1, 0},{ 1,-1, 0},{-1, 1, 0},{-1,-1, 0}, -- 12 cube edges
                 { 1, 0,-1},{-1, 0,-1},{ 0,-1, 1},{ 0, 1, 1}} -- 4 more to make 16

  -- gradient table for 4D
  local grad4 = {{ 0, 1, 1, 1},{ 0, 1, 1,-1},{ 0, 1,-1, 1},{ 0, 1,-1,-1},
                 { 0,-1, 1, 1},{ 0,-1, 1,-1},{ 0,-1,-1, 1},{ 0,-1,-1,-1},
                 { 1, 0, 1, 1},{ 1, 0, 1,-1},{ 1, 0,-1, 1},{ 1, 0,-1,-1},
                 {-1, 0, 1, 1},{-1, 0, 1,-1},{-1, 0,-1, 1},{-1, 0,-1,-1},
                 { 1, 1, 0, 1},{ 1, 1, 0,-1},{ 1,-1, 0, 1},{ 1,-1, 0,-1},
                 {-1, 1, 0, 1},{-1, 1, 0,-1},{-1,-1, 0, 1},{-1,-1, 0,-1},
                 { 1, 1, 1, 0},{ 1, 1,-1, 0},{ 1,-1, 1, 0},{ 1,-1,-1, 0},
                 {-1, 1, 1, 0},{-1, 1,-1, 0},{-1,-1, 1, 0},{-1,-1,-1, 0}}

  -- simplex table
  local simplex4 = {{0,64,128,192},{0,64,192,128},{0,0,0,0},{0,128,192,64},
                    {0,0,0,0},{0,0,0,0},{0,0,0,0},{64,128,192,0},
                    {0,128,64,192},{0,0,0,0},{0,192,64,128},{0,192,128,64},
                    {0,0,0,0},{0,0,0,0},{0,0,0,0},{64,192,128,0},
                    {0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0},
                    {0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0},
                    {64,128,0,192},{0,0,0,0},{64,192,0,128},{0,0,0,0},
                    {0,0,0,0},{0,0,0,0},{128,192,0,64},{128,192,64,0},
                    {64,0,128,192},{64,0,192,128},{0,0,0,0},{0,0,0,0},
                    {0,0,0,0},{128,0,192,64},{0,0,0,0},{128,64,192,0},
                    {0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0},
                    {0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0},
                    {128,0,64,192},{0,0,0,0},{0,0,0,0},{0,0,0,0},
                    {192,0,64,128},{192,0,128,64},{0,0,0,0},{192,64,128,0},
                    {128,64,0,192},{0,0,0,0},{0,0,0,0},{0,0,0,0},
                    {192,64,0,128},{0,0,0,0},{192,128,0,64},{192,128,64,0}}

  -- construct perm and 3d gradient texture
  local perm_image_data = love.image.newImageData(256, 256)
  for x = 0, 255 do
    for y = 0, 255 do
      local offset = (x * 256 + y) * 4
      -- note the switch from 0-based indexing to 1-based indexing
      local value = perm[((y + perm[x + 1]) % 256) + 1]
      local r = grad3[(value % 0x10) + 1][1] * 64 + 64 -- Gradient x
      local g = grad3[(value % 0x10) + 1][2] * 64 + 64 -- Gradient y
      local b = grad3[(value % 0x10) + 1][3] * 64 + 64 -- Gradient z
      local a = value                                -- Permuted index
      perm_image_data:setPixel(x, y, r, g, b, a)
    end
  end
  local perm_image = love.graphics.newImage(perm_image_data)
  perm_image:setFilter("nearest", "nearest")
  -- send texture to the shader
  shader:send("permTexture", perm_image)

  -- construct simplex texture
  local simplex_image_data = love.image.newImageData(64, 1)
  for i = 0, 63 do
    simplex_image_data:setPixel(i, 0, unpack(simplex4[i + 1]))
  end
  local simplex_image = love.graphics.newImage(simplex_image_data)
  simplex_image:setFilter("nearest", "nearest")
  -- send texture to the shader
  pcall(function() shader:send("simplexTexture", simplex_image) end)

  -- construct 4d gradient texture
  local gradient_image_data = love.image.newImageData(256, 256)

  for x = 0, 255 do
    for y = 0, 255 do
      local offset = (x * 256 + y) * 4
      -- note the switch from 0-based indexing to 1-based indexing
      local value = perm[((y + perm[x + 1]) % 256) + 1]
      local r = grad4[(value % 0x20) + 1][1] * 64 + 64 -- Gradient x
      local g = grad4[(value % 0x20) + 1][2] * 64 + 64 -- Gradient y
      local b = grad4[(value % 0x20) + 1][3] * 64 + 64 -- Gradient z
      local a = grad4[(value % 0x20) + 1][4] * 64 + 64 -- Gradient w
      gradient_image_data:setPixel(x, y, r, g, b, a)
    end
  end
  local gradient_image = love.graphics.newImage(gradient_image_data)
  gradient_image:setFilter("nearest", "nearest")
  -- send texture to the shader
  pcall(function() shader:send("gradTexture", gradient_image) end)

  return shader
end

local time = 0
local fps = 0
local second_acc = 0
local frames_this_second = 0

function love.load()
  dummy_texture = love.graphics.newCanvas(1, 1)
  shader = build_shader("GLSLnoisetest4.frag")
end

function love.draw()
  love.graphics.setShader(shader)
  love.graphics.draw(dummy_texture, 200, 100, 0, 400, 400)
  love.graphics.setShader()
  love.graphics.setColor(255, 255, 255, 255)
  love.graphics.print(string.format("FPS: %d", fps), 10, 10)
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
  shader:send("time", time)
end
