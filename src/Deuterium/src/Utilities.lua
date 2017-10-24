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
  
  gsubMul = function(s, t)
    for k,v in pairs(t) do
      s = s:gsub(k,v)
    end
    return s
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