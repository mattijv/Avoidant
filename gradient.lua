local gradient = {}

gradient.newVertGradient = function(w, h, c1, c2)
  local data = love.image.newImageData(1, h)
  for j=0, h-1 do
    local percent = j/h
    local r = c1[1] + (c2[1] - c1[1]) * percent
    local g = c1[2] + (c2[2] - c1[2]) * percent
    local b = c1[3] + (c2[3] - c1[3]) * percent
    local a = c1[4] + (c2[4] - c1[4]) * percent
    data:setPixel(0, j, r, g, b, a)
  end

  local img = love.graphics.newImage(data)
  img:setWrap('repeat', 'clamp')

  local quad = love.graphics.newQuad(0, 0, w, h, 1, h)

  return img, quad
end

return gradient