ConfigValues = {

  ChatPrefix = "^0[^:Snek^0]^7",
  ChatPrefixPM = "^0[^5PM^0]^7"

}

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
  
  HasFlag = function(flag, flags)
    return flag & flags ~= 0
  end,
  
  DefaultError = function(E)
    return  E:gsub("Z:\\home\\musta\\Desktop\\Finally\\scripts\\mp\\", "" )
  end
}

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