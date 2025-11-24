local INITIAL_INTERVAL = 216000 -- 1 hour
local SAVING_GRACE = 18000 -- 5 minutes

script.on_init(function()
  -- 60^3 -> (ticks), seconds, minutes
  storage.time_until_event = INITIAL_INTERVAL
end)

-- math.random(10, 20) * 60 * 60
local function reset_event_time()
  -- Next random event by the minute
  storage.time_until_event = math.random(50, 70) * 3600
end

local function has_valid_online_character()
  for _, player in pairs(game.connected_players) do
    if player.character ~= nil then
      return true
    end
  end

  return false
end

script.on_event({
  defines.events.on_singleplayer_init,
  defines.events.on_multiplayer_init,
  defines.events.on_player_joined_game
}, function()
  if has_valid_online_character() == false then return end
  if #game.connected_players > 1 then return end
  if storage.time_until_event > SAVING_GRACE then return end
  storage.time_until_event = SAVING_GRACE
  game.print("The death timer has been extended upto 5 minutes.")
end)

script.on_event(defines.events.on_tick, function(event)
  if has_valid_online_character() == false then return end

  storage.time_until_event = storage.time_until_event - 1

  if storage.time_until_event > 0 then return end
  reset_event_time() -- prevent further attempts on future frames
  -- event trigger
  local valid_players = game.connected_players
  local index = 1
  while index > #valid_players do
    if valid_players[index].character == nil then
      table.remove(valid_players, index)
    else
      index = index + 1
    end
  end
  local random_player = valid_players[math.random(#valid_players)]

  if random_player.character.health == 0 then
    game.print("[DeathEvent] Attempted to select a dead player.")
    return
  end

  random_player.physical_surface.create_entity {
    name = "artillery-projectile",
    position = random_player.physical_position,
    target = random_player.physical_position,
    force = "neutral"
  }

  random_player.character.die("neutral", random_player.character)
end)
