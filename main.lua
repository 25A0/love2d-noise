local shader
local dummy_texture

function love.load()
  dummy_texture = love.graphics.newCanvas(1, 1)
  shader = love.graphics.newShader("GLSLnoisetest4.frag")
end

function love.draw()
  love.graphics.setShader(shader)
  love.graphics.draw(dummy_texture, 200, 100, 0, 400, 400)
end