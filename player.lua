-- player.lua

player = entity.new()
player.c = collider.new(64, 64, -2, -4, 2, 4, 0b1)
player.anim_frame = 0
player.anim_time = 0

player.run_animation = { 1, 1, 1, 1, 2, 2, 2, 3, 3, 3, 3, 2, 2, 2}
player.run_sounds = { 0, nil, nil, nil, nil, nil, nil, 0, nil, nil, nil, nil, nil, nil}

function player:start()
  physics.register(self.c)
end

function player:update(_dt)
  local _dir = vec2.new()
  if btn(0) then _dir.x = _dir.x - 1 end
  if btn(1) then _dir.x = _dir.x + 1 end
  if btn(2) then _dir.y = _dir.y - 1 end
  if btn(3) then _dir.y = _dir.y + 1 end
  --_dir = _dir:normalized()
  if (abs(_dir.x) == 1 and abs(_dir.y) == 1) then
    _dir.x = sgn(_dir.x) * 0.75
    _dir.y = sgn(_dir.y) * 0.75
  end

  local _speed = 1.0
  local _delta = _dir:mul(_speed * _dt)

  physics.move(self.c, _delta.x, _delta.y, 0b10)

  if _dir:is_zero() then
    player.anim_time = 0
  else
    player.anim_time = player.anim_time + _dt
  end

  local _i = (flr(player.anim_time) % #player.run_animation) + 1
  player.anim_frame = player.run_animation[_i]

  if not _dir:is_zero() then
    if player.run_sounds[_i] then
      sfx(player.run_sounds[_i])
    end
  end
end

function player:stop()
  print("player stop")
  physics.unregister(self.c)
end

function player:draw()
  spr(player.anim_frame, flr(self.c.x - 4), flr(self.c.y - 4))
end
