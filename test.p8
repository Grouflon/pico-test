pico-8 cartridge // http://www.pico-8.com
version 29
__lua__

#include lib/math.lua
#include lib/particles.lua
#include lib/physics.lua
#include lib/perlin.lua
#include lib/entities.lua
#include lib/renderer.lua
#include lib/log.lua

LAYER_PLAYER = 0b1
LAYER_WALLS = 0b10
LAYER_PLAYERWEAPON = 0b100

#include player.lua

e = emitter.new()
--e.settings.rate.val = 0.08
e.settings.rate.val = 0.2
e.settings.angle.dev = 70
e.settings.life.val = 40.0
e.settings.life.dev = 2.0
e.settings.distance.start.val = 3
e.settings.distance.start.dev = 3
e.settings.distance.stop.val = 40
e.settings.distance.stop.dev = 5
e.settings.size.start.val = 1.5
e.settings.size.start.dev = 0.5
e.settings.size.stop.val = 0.5
e.settings.size.stop.dev = 0.5
e.settings.easing = easing.quad_out
e.settings.color = {7,10,9,8,2}

c2 = collider.new(100, 70, -30, -10, 5, 5, LAYER_WALLS)
c3 = collider.new(100, 70, -10, -70, 20, 20, LAYER_WALLS)

function _init()
  poke(0x5F5C, 255) -- set the initial delay before repeating input. 255 means never repeat.

  local _a = vec2.new(1.5, 1)
  local _b = vec2.new()
  print(vec2.add(_a, _b))
  print(_a:sub(_b))
  print(_a:dot(_b))

  entity_manager.add(player)

  physics.register(c2)
  physics.register(c3)
end

time = 0
function _update()
  cls()

  entity_manager.update()

  local _t = (time % 60.0) / 60.0
  e.active = _t > 0.5
  local _dir = vec2.new(cos(_t), sin(_t))
  local _pos = vec2.new(64,64):add(_dir:mul(30))
  e.settings.angle.val = _t * P2D - 90.0
  e:update(_pos.x, _pos.y)
  time = time + 1
end

function _draw()
  entity_manager.draw()


  renderer.draw()

  e:draw()

  --physics.draw(LAYER_PLAYER, 8)
  physics.draw(LAYER_WALLS, 12)
  --physics.draw(LAYER_PLAYERWEAPON, 15)

  draw_log()
  color()
  --print(#e._particles)
  --print(stat(7).."FPS")
end

__gfx__
0000000000ffff0000ffff0000ffff0000ffff0000ffff0000ffff0000000000000ee00000000000000000000000000000000000000000000000000000000000
000000000f1f1ff00f1f1ff00f1f1ff00ff999f00ff999f00ff999f00000000000e66e0000000000000000000000000000000000000000000000000000000000
0070070000ffff0000ffff0000ffff00009999000099990000999900000000e00006c00000000000000000000000000000000000000000000000000000000000
00077000099499900994999009949990099994900999949009994990c666666e0006c00000000000000000000000000000000000000000000000000000000000
000770009494994994949949949499499999444999994449999444490ccccc6e0006c00000000000000000000000000000000000000000000000000000000000
00700700949494990494949994949449994444440444444999444440000000e00006c00000000000000000000000000000000000000000000000000000000000
00000000044444400044444004444400044444400044444004444400000000000006c00000000000000000000000000000000000000000000000000000000000
0000000000400400000004000040000000400400000004000040000000000000000c000000000000000000000000000000000000000000000000000000000000
__sfx__
0001000004310043200431004300210002100023000230002100021000260002000020000260001300013000130001700017000190001b0001c0001500016000160001b0001b000220001b000130000d00018000
000100000d630156301a6301e630206302263023630236200a0200a0200a0100a0400a0402a20038100381000c1000d1000f1001b100036000000000000000000000000000000000000000000000000000000000
