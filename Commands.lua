Command = {

}

function ProcessCommand(player, message)

  local Args = string.gmatch(string.sub(message,2), "%S+")
  local commandname = Args():lower()
  local args = {}
  for i in Args do
    args[#args + 1] = i
  end

  if commandname == "ping" then
    WriteChatToPlayer(player, "^1pong, sucker!")
  end

  if (commandname == "say") and (#args > 0) then
    WriteChatToAll(string.sub(message, #commandname + 2))
  end

  if (commandname == "rules") then
    WriteChatToPlayerMultiline(player, {
      "^:Snek iSnipe Rules^0:",
      "^1Don't ^7HardScope^0.",
      "^1Don't ^7HalfScope^0.",
      "^1Don't ^7NoScope^0.",
      "^1Don't ^7DropShot^0.",
      "^1Don't ^7Camp^0/^7Wait^0.",
      "^1Don't ^7HeadGlitch^0.",
      "^2Respect Admins^0."
      }, 1000)
  end

end