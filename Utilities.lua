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
  
  WriteChatToAll = function(message)
    Utilities.RawSayAll(ConfigValues.ChatPrefix .. " " .. message)
  end,

  WriteChatToPlayer = function(player, message)
    Utilities.RawSayTo(player, ConfigValues.ChatPrefixPM .. " " .. message)
  end
  
}