function ProcessCommand(player, message)

  local Args = string.gmatch(string.sub(message,2), "%S+")
  local commandname = Args():lower()
  local args = {}
  for i in Args do
    args[#args + 1] = i
  end

  if commandname == "ping" then
    Utilities.WriteChatToPlayer(player, "^1pong, sucker!")
  end

  if (commandname == "say") and (#args > 0) then
    Utilities.WriteChatToAll(args[1])
  end

end