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
    
    local status, executed = xpcall(
      function() return command.action(player, arguments, optionalargument) end,
      function(E) WriteChatToPlayer(args.sender, Utilities.DefaultError(E)) return true end
    )
    
    return (executed == nil) and true or executed
    
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
  if not CommandToBeParsed:Contains(" ") then
    return ArgumentAmount == 0, {}, nil
  end
  
  CommandToBeParsed = string.sub(CommandToBeParsed, CommandToBeParsed:IndexOf(" ") + 1)
  while #list < ArgumentAmount do

    if CommandToBeParsed == nil then
        return false, {}, nil
    end
    
    local length = CommandToBeParsed:IndexOf(" ")
    if length == nil then
      list[#list + 1] = CommandToBeParsed
      CommandToBeParsed = nil
    else
      list[#list + 1] = string.sub(CommandToBeParsed, 1, length - 1)
      CommandToBeParsed = string.sub(CommandToBeParsed, CommandToBeParsed:IndexOf(" ") + 1)
    end
  end
  return true, list, CommandToBeParsed
end

function ProcessCommand(player, message)

  local Args = string.gmatch(string.sub(message,2), "%S+")
  local commandname = Args():lower()
  
  local CommandToBeRun = CommandList.FindCommand(commandname)
  if CommandToBeRun ~= nil then
  
    local group = GroupsDatabase.GetPlayerGroup(player)
    
    if not GroupsDatabase.GetEntityPermission(player, group, CommandToBeRun.name) then
      if group.CanDo(CommandToBeRun.name) then
        WriteChatToPlayer(player, Command.GetMessage("NotLoggedIn"))
      else
        WriteChatToPlayer(player, Command.GetMessage("NoPermission"))
      end
    else
      local executed = CommandToBeRun.Run(player, message)
      SLOG.logTo(SLOG.Type.commands, player, {executed = executed, command = commandname, arguments = message:sub(#commandname + 3)})
    end
  else
    WriteChatToPlayer(player, Command.GetMessage("CommandNotFound"))
  end

end

-- say <message>
CommandList.Add(Command:new("say", 0, Command.Behavior.HasOptionalArguments | Command.Behavior.OptionalIsRequired, 
  function(sender, arguments, optarg)
    WriteChatToAll(optarg)
  end
))

-- ping
CommandList.Add(Command:new("ping", 0, Command.Behavior.Normal, 
  function(sender, arguments, optarg)
    WriteChatToPlayer(sender, "^1pong, sucker!")
  end
))  

-- rules
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
  end
))

-- iamgod <group>
CommandList.Add(Command:new("iamgod", 1, Command.Behavior.Normal, 
  function(sender, arguments, optarg)
    if SGRP.db == nil then 
      print("Error: Groups database not loaded!")
      return false
    end
    arguments[1] = arguments[1]:lower()
    if arguments[1] == "default" then
      WriteChatToPlayer(sender, Command.GetString("iamgod", "error2"))
    end
 
    local group = GroupsDatabase.GetGroup(arguments[1])
    
    if group == nil then
      WriteChatToPlayer(sender, Command.GetMessage("GroupNotFound"))
      return false
    end
    if SGRP.Count() == 0 then
      SGRP.SetGroup(sender, arguments[1], sender)
      WriteChatToAll(Command.GetString("iamgod", "message"):gsubMul{
        ["<target>"] = sender.name,
        ["<rankname>"] = arguments[1],
      })
    else
      WriteChatToPlayer(sender, Command.GetString("iamgod", "error1"));
    end
  end
))  

-- res  
CommandList.Add(Command:new("res", 0, Command.Behavior.Normal, 
  function(sender, arguments, optarg)
    WriteChatToAll(Command.GetString("res", "message"):gsubMul{
      ["<player>"] = sender.name
    })
    gsc.map_restart()
  end
))

-- version
CommandList.Add(Command:new("version", 0, Command.Behavior.Normal, 
  function(sender, arguments, optarg)
    WriteChatToPlayer(sender, "^3Deuterium ^1" .. ConfigValues.Version .. "^3.")
  end))

-- pm
CommandList.Add(Command:new("pm", 1, Command.Behavior.HasOptionalArguments | Command.Behavior.OptionalIsRequired, 
  function(sender, arguments, optarg)
    local target = FindSinglePlayer(arguments[1])
    if target == nil then
      WriteChatToPlayer(sender, Command.GetMessage("NotOnePlayerFound"))
      return false
    end
    
    WriteChatToPlayer(sender, Command.GetString("pm", "send"):gsubMul{
      ["<recipient>"] = target.name,
      ["<message>"] = optarg
    })
    
    callbacks.afterDelay.add(100, function()
        WriteChatToPlayer(target, Command.GetString("pm", "receive"):gsubMul{
          ["<sender>"] = sender.name,
          ["<message>"] = optarg
        })
      end)
  end
))

-- map
CommandList.Add(Command:new("map", 1, Command.Behavior.Normal, 
  function(sender, arguments, optarg)
    local map = FindSingleMap(arguments[1])
    if map == nil then
      WriteChatToPlayer(sender, Command.GetMessage("NotOneMapFound"))
      return false
    end
    
    WriteChatToAll(Command.GetString("map", "message"):gsubMul{
      ["<player>"] = sender.name,
      ["<mapname>"] = map
    })
    
    ChangeMap(map)
  end
))