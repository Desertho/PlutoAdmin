Command = {

--[[Flags]]   Behavior = {
                Normal = 1, 
                HasOptionalArguments = 2,
                OptionalIsRequired = 4, 
                MustBeConfirmed = 8
              },
              
--[[func]]    action,
--[[int]]     parametercount,
--[[string]]  name,
--[[int]]     behavior,
--[[func]]    Run,
--[[func]]    GetString = function(name, key)
                return CmdLang_GetString("command_" .. name .. "_" .. key)
              end,
              
--[[func]]    GetMessage = function(key)
                return CmdLang_GetString("Message_" .. key)
              end
}

function Command:new(commandname, paramcount, commandbehavior, actiontobedone)
  local command = {}
  self.__index = self
  setmetatable(command, self)
  command.action = actiontobedone
  command.parametercount = paramcount
  command.name = commandname
  command.behavior = commandbehavior
  
  command.Run = function(player, message)
    local parsed, arguments, optionalargument = ParseCommand(message, command.parametercount)
    local execute = false
    if not parsed then
      WriteChatToPlayer(player, Command.GetString(command.name, "usage"))
      return false
    end
    
    if Utilities.HasFlag(Command.Behavior.HasOptionalArguments, command.behavior) then
      if Utilities.HasFlag(Command.Behavior.OptionalIsRequired, command.behavior) and Utilities.String.IsNullOrWhiteSpace(optionalargument) then
        WriteChatToPlayer(player, Command.GetString(command.name, "usage"))
        return false
      end
    elseif not Utilities.String.IsNullOrWhiteSpace(optionalargument) then
      WriteChatToPlayer(player, Command.GetString(command.name, "usage"))
      return false
    end
    
    xpcall( 
      function() return command.action(player, arguments, optionalargument) end,
      function(E) WriteChatToPlayer(args.sender, Utilities.DefaultError(E)) end
    )
    
    return true
    
  end
  return command
end

CommandList = {

  commands = {},
  
  Add = function(command)
    CommandList.commands[#CommandList.commands + 1] = command
  end,
  
  FindCommand = function(commandname)
    for i, command in pairs(CommandList.commands) do
      if command.name == commandname then
        return command
      end
    end
    return nil
  end

}

-- return bool parsed, string[] arguments, string optionalarguments
function ParseCommand(CommandToBeParsed, ArgumentAmount)
  local arguments
  local optionalarguments
  local list = {}
  CommandToBeParsed = Utilities.String.TrimEnd(CommandToBeParsed)
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
  
  local CommandToBeRun = CommandList.FindCommand(commandname)
  if CommandToBeRun ~= nil then
    local executed = CommandToBeRun.Run(player, message)
    SLOG.logTo(SLOG.Type.commands, player, {executed = executed, command = commandname, arguments = message:sub(#commandname + 3)})
  else
    WriteChatToPlayer(player, Command.GetMessage("CommandNotFound"))
  end

end


CommandList.Add(Command:new("say", 0, Command.Behavior.HasOptionalArguments | Command.Behavior.OptionalIsRequired, 
  function(sender, arguments, optarg)
    WriteChatToAll(optarg)
  end))
  
CommandList.Add(Command:new("ping", 0, Command.Behavior.Normal, 
  function(sender, arguments, optarg)
    WriteChatToPlayer(sender, "^1pong, sucker!")
  end))  
  
CommandList.Add(Command:new("rules", 0, Command.Behavior.Normal, 
  function(sender, arguments, optarg)
    WriteChatToPlayerMultiline(sender, {
      "^:Snek iSnipe Rules^0:",
      "^1Don't ^7HardScope^0.",
      "^1Don't ^7HalfScope^0.",
      "^1Don't ^7NoScope^0.",
      "^1Don't ^7DropShot^0.",
      "^1Don't ^7Camp^0/^7Wait^0.",
      "^1Don't ^7HeadGlitch^0.",
      "^2Respect Admins^0."
    }, 1000)
  end))   