-- player.lua

player = entity.new()
player.body = collider.new(64, 64, -2, -4, 2, 4, LAYER_PLAYER)

PLAYER_ATTACK_TIME = 4
PLAYER_ATTACK_COOLDOWN = 4

player.animation = nil
player.anim_frame = 0
player.anim_time = 0
player.is_down = true
player.is_left = true
player.attack = {}
player.attack.active = false
player.attack.timer = 0
player.attack.cooldown = 0
player.attack.direction = vec2.new(0.0, 1.0)
player.attack.collider = collider.new(0, 0, 0, 0, 0, 0, LAYER_PLAYERWEAPON)


idle_down_animation = {
  { f = 1 }
}

idle_up_animation = {
  { f = 4 }
}

run_down_animation = {
  { f = 2, sfx = 0 },
  { f = 2 },
  { f = 2 },
  { f = 2 },
  { f = 2 },
  { f = 3, sfx = 0 },
  { f = 3 },
  { f = 3 },
  { f = 3 },
  { f = 3 },
}

run_up_animation = {
  { f = 5, sfx = 0 },
  { f = 5 },
  { f = 5 },
  { f = 5 },
  { f = 5 },
  { f = 6, sfx = 0 },
  { f = 6 },
  { f = 6 },
  { f = 6 },
  { f = 6 },
}

function player:start()
  physics.register(self.body)
end

function player:update(_dt)
  local _dir = vec2.new()
  if btn(0) then _dir.x = _dir.x - 1 end
  if btn(1) then _dir.x = _dir.x + 1 end
  if btn(2) then _dir.y = _dir.y - 1 end
  if btn(3) then _dir.y = _dir.y + 1 end

  -- sprite direction
  if _dir.y < 0 then
    self.is_down = false
  elseif _dir.y > 0 then
    self.is_down = true
  end
  if _dir.x < 0 then
    self.is_left = false
    if _dir.y == 0 then
      self.is_down = true
    end
  elseif _dir.x > 0 then
    self.is_left = true
    if _dir.y == 0 then
      self.is_down = true
    end
  end
  --_dir = _dir:normalized()
  --[[if (abs(_dir.x) == 1 and abs(_dir.y) == 1) then
    _dir.x = sgn(_dir.x) * 0.75
    _dir.y = sgn(_dir.y) * 0.75
  end]]--

  -- move
  local _speed = 1.0
  local _delta = _dir:mul(_speed * _dt)
  physics.move(self.body, _delta.x, _delta.y, LAYER_WALLS)

  -- animation
  if _dir:is_zero() then
    if self.is_down then
      self.animation = idle_down_animation
    else
      self.animation = idle_up_animation
    end
    self.anim_time = 0
  else
    if self.is_down then
      self.animation = run_down_animation
    else
      self.animation = run_up_animation
    end
    self.anim_time = self.anim_time + _dt
  end

  local _i = (flr(self.anim_time) % #self.animation) + 1
  self.anim_frame = self.animation[_i]

  -- animation sound
  if not _dir:is_zero() then
    if self.anim_frame.sfx then
      sfx(self.anim_frame.sfx)
    end
  end

  -- attack
  local _attack = self.attack
  _attack.collider.x = self.body.x
  _attack.collider.y = self.body.y

  if not _attack.active then
    if _dir.y == 0 then
      if _dir.x < 0 then
        _attack.direction:set(-1, 0)
      elseif _dir.x > 0 then
        _attack.direction:set(1, 0)
      end
    elseif _dir.x == 0 then
      if _dir.y < 0 then
        _attack.direction:set(0, -1)
      elseif _dir.y > 0 then
        _attack.direction:set(0, 1)
      end
    end

    _attack.cooldown = max(_attack.cooldown - 1, 0)
    if btnp(4) and _attack.cooldown == 0 then
      _attack.active = true
      _attack.timer = PLAYER_ATTACK_TIME

      local _direction = _attack.direction
      local _attack_offset = 3
      local _attack_length = 8
      local _attack_width = 2
      local _perpendicular_direction = vec2.new(_direction.y, -_direction.x)
      local _p1 = _direction:mul(_attack_length + _attack_offset):add(_perpendicular_direction:mul(_attack_width))
      local _p2 = _direction:mul(_attack_offset):add(_perpendicular_direction:mul(-_attack_width))

      if _direction.y == 0 then
        _p1.y = _p1.y + 1
        _p2.y = _p2.y + 1
      else
        _p1.x = _p1.x + 1
        _p2.x = _p2.x + 1
      end
      _attack.collider.min_x = min(_p1.x, _p2.x)
      _attack.collider.min_y = min(_p1.y, _p2.y)
      _attack.collider.max_x = max(_p1.x, _p2.x)
      _attack.collider.max_y = max(_p1.y, _p2.y)

      physics.register(_attack.collider)
      sfx(1)
      --log("player attack")
    end
  else
    _attack.timer = _attack.timer - 1

    if _attack.timer == 0 then
      _attack.active = false
      physics.unregister(_attack.collider)
    end
  end
end

function player:stop()
  physics.unregister(self.body)
end

function player:draw()
  renderer.spr(self.anim_frame.f, flr(self.body.x - 4), flr(self.body.y - 4), 1, 1, self.is_left)
  local _attack = self.attack
  if _attack.active then
    local _flip_x = _attack.direction.x > 0
    local _flip_y = _attack.direction.y < 0
    local _c_x, _c_y = _attack.collider:min()
    local _s = 7
    local _z = 1

    if _attack.direction.y ~= 0 then
      _s = 8
    end
    if _attack.direction.y < 0 then
      _z = -1
    end

    if _s == 7 then
      _c_y = _c_y - 2
    else
      _c_x = _c_x - 2
    end

    --print(_flip_y)
    renderer.spr(_s, _c_x, _c_y, 1, 1, _flip_x, _flip_y, _z)
  end
end
