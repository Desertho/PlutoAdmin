Utilities = {

  RawSayAll = function(message) 
    util.chatPrint(message)
  end,

  RawSayTo = function(player, message)
    player:tell(message)
  end,
  
  String = {
    TrimEnd = function(str)
      return str:gsub("%s+$", "")
    end, 
    
    IsNullOrWhiteSpace = function(str)
      return not(str ~= nil and str:match("%S") ~= nil)
    end
  },
  
  IO = {
    file_exists = function(path)
       local f = io.open(path,"r")
       if f ~= nil then io.close(f) return true else return false end
    end
  },
  
  HasFlag = function(flag, flags)
    return flag & flags ~= 0
  end,
  
  HasValue = function(tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end
    return false
  end,
  
  DefaultError = function(E)
    return  E:gsub("Z:\\home\\musta\\Desktop\\Finally\\scripts\\mp\\", "" )
  end
}

-- split a string
function string:split(delimiter)
  local result = { }
  local from  = 1
  local delim_from, delim_to = string.find( self, delimiter, from  )
  while delim_from do
    table.insert( result, string.sub( self, from , delim_from-1 ) )
    from  = delim_to + 1
    delim_from, delim_to = string.find( self, delimiter, from  )
  end
  table.insert( result, string.sub( self, from  ) )
  return result
end

function string:gsubMul(t)
  for k,v in pairs(t) do
    self = self:gsub(k,v)
  end
  return self
end

function string:IndexOf(s)
  return string.find(self, s, 1, true)
end

function string:Contains(s)
  if s == nil then return false end
  return string.IndexOf(self, s) ~= nil
end

function WriteChatToAll(message)
  Utilities.RawSayAll(ConfigValues.ChatPrefix .. " " .. message)
end

function WriteChatToPlayer(player, message)
  if message == nil then message = "" end
  Utilities.RawSayTo(player, ConfigValues.ChatPrefixPM .. " " .. message)
end

function WriteChatToPlayerMultiline(player, messages, delay)
  if delay == nil then delay = 500 end

  for i, message in ipairs(messages) do
    callbacks.afterDelay.add((i - 1) * delay, 
      function() WriteChatToPlayer(player, message) end
    )
  end
end

function ChangeMap(devmapname)
  util.executeCommand("map " .. devmapname)
end

function FindPlayers(identifier)
  local result = {}
  identifier = identifier:lower()
  for player in util.iterPlayers() do
    if player.name:lower():Contains(identifier) then
      result[#result + 1] = player
    end
  end
  return result
end

function FindSinglePlayer(identifier)
  local players = FindPlayers(identifier)
  if #players ~= 1 then
    return nil
  end
  return players[1]
end

function FindMaps(identifier)
  local result = {}
  identifier = identifier:lower()
  for mapname, devmapname in pairs(Data.StandardMapNames) do
    if mapname:Contains(identifier) or devmapname:Contains(identifier) then
      result[#result + 1] = devmapname
    end
  end
  return result
end

function FindSingleMap(identifier)
  local maps = FindMaps(identifier)
  if #maps ~= 1 then
    return nil
  end
  return maps[1]
end