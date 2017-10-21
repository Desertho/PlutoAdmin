Command = {
  Behavior = {
    Normal = 1, 
    HasOptionalArguments = 2,
    OptionalIsRequired = 4, 
    MustBeConfirmed = 8
  },
  
  action,
  parametercount,
  name,
  behavior
}

function Command:new(commandname, paramcount, commandbehaviour, actiontobedone)
  local o = {}
  setmetatable(o, self)
  self.__index = self
  self.action = actiontobedone
  self.parametercount = paramcount
  self.name = commandname
  self.behaviour = commandbehaviour
  return o
end  

-- return bool parsed, string[] arguments, string optionalarguments
function ParseCommand(CommandToBeParsed, ArgumentAmount)
  local arguments
  local optionalarguments
  local list = {}
  CommandToBeParsed = Utilities.TrimEnd(CommandToBeParsed)
  if string.find(CommandToBeParsed, " ", 1, true) == nil then
    return ArgumentAmount == 0, {}, nil
  end
  
  CommandToBeParsed = string.sub(CommandToBeParsed, string.find(CommandToBeParsed, " ", 1, true) + 1)
  while #list < ArgumentAmount do

    if CommandToBeParsed == nil then
        return false, {}, nil
    end
    
    local length = string.find(CommandToBeParsed, " ", 1, true)
    if length == nil then
      list[#list + 1] = CommandToBeParsed
      CommandToBeParsed = nil
    else
      list[#list + 1] = string.sub(CommandToBeParsed, 1, length - 1)
      CommandToBeParsed = string.sub(CommandToBeParsed, string.find(CommandToBeParsed, " ", 1, true) + 1)
    end
  end
  return true, list, CommandToBeParsed
end

function ProcessCommand(player, message)

  local Args = string.gmatch(string.sub(message,2), "%S+")
  local commandname = Args():lower()

  if commandname == "ping" then
    WriteChatToPlayer(player, "^1pong, sucker!")
  end
  
  local command = Command:new("say", 0, Command.Behavior.HasOptionalArguments, 
      function(sender, arguments, optarg)
        WriteChatToAll(optarg)
      end
    )
  
  -- !say
  if commandname == command.name then 
    local parsed, arguments, optionalarguments = ParseCommand(message, 0)
    if parsed and (optionalarguments ~= nil) then
      command.action(player, arguments, optionalarguments)
    else
      WriteChatToPlayer(player, DefaultCmdLang["Message_WrongSyntax"])
    end
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