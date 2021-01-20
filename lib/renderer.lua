-- renderer.lua

renderer = {
  sprites = {}
}

function renderer.spr(_n, _x, _y, _w, _h, _flip_x, _flip_y, _z)

  if _flip_x == nil then _flip_x = false end
  if _flip_y == nil then _flip_y = false end



  local _spr = {
    n = _n,
    x = _x,
    y = _y,
    z = _z or 0,
    w = _w or 1,
    h = _h or 1,
    flip_x = _flip_x,
    flip_y = _flip_y,
  }



  local _inserted = false
  for _i, _s in ipairs(renderer.sprites) do
    if _spr.z < _s.z then
      add(renderer.sprites, _spr, _i)
      _inserted = true
      break
    end
  end

  if not _inserted then
    add(renderer.sprites, _spr)
  end
end

function renderer.draw()
  for _i, _s in ipairs(renderer.sprites) do

    spr(_s.n, _s.x, _s.y, _s.w, _s.h, _s.flip_x, _s.flip_y)
  end
  renderer.sprites = {}
end
