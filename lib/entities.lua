-- entities.lua

entity = {}
entity.__index = entity

function entity.new()
  local _e = {
    to_remove = false
  }
  setmetatable(_e, entity)
  return _e
end

function entity:start()
end
function entity:update(_dt)
end
function entity:draw()
end
function entity:stop()
end

entity_manager = {
  entities_to_add = {},
  entities = {},
}

function entity_manager.add(_entity)
  add(entity_manager.entities_to_add, _entity)
end

function entity_manager.remove(_entity)
  local _result = del(entity_manager.entities_to_add, _entity)
  if _result == nil then
    _entity.to_remove = true
  end
end

function entity_manager.update(_dt)
  _dt = _dt or 1
  -- add new
  for _e in all(entity_manager.entities_to_add) do
    add(entity_manager.entities, _e)
    _e:start()
  end
  entity_manager.entities_to_add = {}

  -- update
  for _e in all(entity_manager.entities) do
    _e:update(_dt)
  end

  -- clear removed
  local _i = 1
  while entity_manager.entities[_i] ~= nil do
    if entity_manager.entities[_i].to_remove then
      _e:stop()
      deli(entity_manager.entities, _i)
    else
      _i = _i + 1
    end
  end
end

function entity_manager.draw()
  for _e in all(entity_manager.entities) do
    _e:draw()
  end
end
