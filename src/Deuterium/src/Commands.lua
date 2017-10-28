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
  command.behavior = {
    value = commandbehavior,
    HasFlag = function(flag)
      return flag & command.behavior.value ~= 0
    end
  }
  
  command.Run = function(player, message)
    local parsed, arguments, optionalargument = ParseCommand(message, command.parametercount)

    if not parsed then
      player:WriteChat(Command.GetString(command.name, "usage"))
      return false
    end
    
    if command.behavior.HasFlag(Command.Behavior.HasOptionalArguments) then
      if command.behavior.HasFlag(Command.Behavior.OptionalIsRequired) and Utilities.String.IsNullOrWhiteSpace(optionalargument) then
        player:WriteChat(Command.GetString(command.name, "usage"))
        return false
      end
    elseif not Utilities.String.IsNullOrWhiteSpace(optionalargument) then
      player:WriteChat(Command.GetString(command.name, "usage"))
      return false
    end
    
    local status, executed = xpcall(
      function() return command.action(player, arguments, optionalargument) end,
      function(E)
        local e = Utilities.DefaultError(E) 
        print(e)
        WriteChatToAll(e)
      return true end
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
  CommandToBeParsed = CommandToBeParsed:TrimEnd()
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
        player:WriteChat(Command.GetMessage("NotLoggedIn"))
      else
        player:WriteChat(Command.GetMessage("NoPermission"))
      end
    else
      local executed = CommandToBeRun.Run(player, message)
      SLOG.logTo(SLOG.Type.commands, player, {executed = executed, command = commandname, arguments = message:sub(#commandname + 3)})
    end
  else
    player:WriteChat(Command.GetMessage("CommandNotFound"))
  end

end

-- say <message>
CommandList.Add(Command:new("say", 0, Command.Behavior.HasOptionalArguments | Command.Behavior.OptionalIsRequired, 
  function(sender, arguments, optarg)
    WriteChatToAll(optarg:RemoveColors())
  end
))

-- ping
CommandList.Add(Command:new("ping", 0, Command.Behavior.Normal, 
  function(sender, arguments, optarg)
    sender:WriteChat("^1pong, sucker!")
  end
))  

-- rules
CommandList.Add(Command:new("rules", 0, Command.Behavior.Normal, 
  function(sender, arguments, optarg)
    sender:WriteChatMultiline({
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
    assert(SMAN.db ~= nil, "Error: Groups database not loaded! \n" .. debug.traceback())

    arguments[1] = arguments[1]:lower()
    if arguments[1] == "default" then
      sender:WriteChat(Command.GetString("iamgod", "error2"))
    end
 
    local group = GroupsDatabase.GetGroup(arguments[1])
    
    if group == nil then
      sender:WriteChat(Command.GetMessage("GroupNotFound"))
      return false
    end
    if SGRP.Count() == 0 then
      sender:SetGroup(group.group_name, sender)
      WriteChatToAll(Command.GetString("iamgod", "message"):gsubMul{
        ["<target>"] = sender.name,
        ["<rankname>"] = group.group_name,
      })
    else
      sender:WriteChat(Command.GetString("iamgod", "error1"))
    end
  end
))  

-- res  
CommandList.Add(Command:new("res", 0, Command.Behavior.Normal, 
  function(sender, arguments, optarg)
    WriteChatToAll(Command.GetString("res", "message"):gsubMul{
      ["<player>"] = sender.name
    })
    util.executeCommand("fast_restart")
  end
))

-- version
CommandList.Add(Command:new("version", 0, Command.Behavior.Normal, 
  function(sender, arguments, optarg)
    sender:WriteChat("^3Deuterium ^1" .. ConfigValues.Version .. "^3.")
  end
))

-- pm <player> <message>
CommandList.Add(Command:new("pm", 1, Command.Behavior.HasOptionalArguments | Command.Behavior.OptionalIsRequired, 
  function(sender, arguments, optarg)
    local target = FindSinglePlayer(arguments[1])
    if target == nil then
      sender:WriteChat(Command.GetMessage("NotOnePlayerFound"))
      return false
    end
    
    sender:WriteChat(Command.GetString("pm", "send"):gsubMul{
      ["<recipient>"] = target.name,
      ["<message>"] = optarg
    })
    
    callbacks.afterDelay.add(100, function()
        target:WriteChat(Command.GetString("pm", "receive"):gsubMul{
          ["<sender>"] = sender.name,
          ["<message>"] = optarg
        })
      end)
  end
))

-- map <mapname>
CommandList.Add(Command:new("map", 1, Command.Behavior.Normal, 
  function(sender, arguments, optarg)
    local map = FindSingleMap(arguments[1])
    if map == nil then
      sender:WriteChat(Command.GetMessage("NotOneMapFound"))
      return false
    end
    
    WriteChatToAll(Command.GetString("map", "message"):gsubMul{
      ["<player>"] = sender.name,
      ["<mapname>"] = map
    })
    
    ChangeMap(map)
  end
))

-- admins
CommandList.Add(Command:new("admins", 0, Command.Behavior.Normal, 
  function(sender, arguments, optarg)
    sender:WriteChat(Command.GetString("admins", "firstline"))
    sender:WriteChatCondensed(GroupsDatabase.GetAdminsString(table.FromIterator(util.iterPlayers())), 1000, 40, Command.GetString("admins", "separator"))
  end
))

-- status [players]
CommandList.Add(Command:new("status", 0, Command.Behavior.HasOptionalArguments, 
  function(sender, arguments, optarg)
    local statusstrings = {}
    local Players = {}
    
    if Utilities.String.IsNullOrEmpty(optarg) then
      Players = table.FromIterator(util.iterPlayers())
    else
      Players = FindPlayers(optarg)
    end
    for i, player in ipairs(Players) do
      statusstrings[#statusstrings + 1] = Command.GetString("status", "formatting"):gsubMul{
        ["<namef>"] = player:GetFormattedName(),
        ["<name>"] = player.name,
        ["<rankname>"] = player:GetGroup(database).group_name,
        ["<shortrank>"] = player:GetGroup(database).prefix,
        ["<id>"] = tostring(sender:getentitynumber())
      }
    end
    sender:WriteChat(Command.GetString("status", "firstline"))
    sender:WriteChatMultiline(statusstrings)
  end
))

-- kick <player> [reason]
CommandList.Add(Command:new("kick", 1, Command.Behavior.HasOptionalArguments, 
  function(sender, arguments, optarg)
    local target = FindSinglePlayer(arguments[1])
    if target == nil then
      sender:WriteChat(Command.GetMessage("NotOnePlayerFound"))
      return false
    end

    WriteChatToAll(Command.GetString("kick", "message"):gsubMul{
      ["<target>"] = target.name,
      ["<targetf>"] = target:GetFormattedName(),
      ["<issuer>"] = sender.name,
      ["<issuerf>"] = sender:GetFormattedName(),
      ["<reason>"] = (optarg == nil) and "" or optarg
    })

    CMD_kick(target, optarg)
  end
))

-- warn <player> [reason]
CommandList.Add(Command:new("warn", 1, Command.Behavior.HasOptionalArguments, 
  function(sender, arguments, optarg)
    local target = FindSinglePlayer(arguments[1])
    if target == nil then
      sender:WriteChat(Command.GetMessage("NotOnePlayerFound"))
      return false
    end
    
    local warns = SMAN.CMD_WARN_GET(target)
    
    WriteChatToAll(Command.GetString("warn", "message"):gsubMul{
      ["<target>"] = target.name,
      ["<targetf>"] = target:GetFormattedName(),
      ["<issuer>"] = sender.name,
      ["<issuerf>"] = sender:GetFormattedName(),
      ["<reason>"] = (optarg == nil) and "" or optarg,
      ["<warncount>"] = tostring(warns + 1),
      ["<maxwarns>"] = tostring(Settings.Get("commands.maxwarns"))      
    })
    
    target:iPrintLnBold(Command.GetMessage("YouHaveBeenWarned"))
    
    if warns == Settings.Get("commands.maxwarns") - 1 then
      SMAN.CMD_WARN_SET(target, 0)
      CMD_kick(target, optarg)
    else
      SMAN.CMD_WARN_SET(target, warns + 1)
    end
  end
))

-- unwarn <player> [reason]
CommandList.Add(Command:new("unwarn", 1, Command.Behavior.HasOptionalArguments, 
  function(sender, arguments, optarg)
    local target = FindSinglePlayer(arguments[1])
    if target == nil then
      sender:WriteChat(Command.GetMessage("NotOnePlayerFound"))
      return false
    end
    
    local warns = SMAN.CMD_WARN_GET(target)
    
    if warns == 0 then
      sender:WriteChat(Command.GetString("warns", "message"):gsubMul{
        ["<target>"] = target.name,
        ["<targetf>"] = target:GetFormattedName(),
        ["<warncount>"] = tostring(warns),
        ["<maxwarns>"] = tostring(Settings.Get("commands.maxwarns"))
      })
    else
      WriteChatToAll(Command.GetString("unwarn", "message"):gsubMul{
        ["<target>"] = target.name,
        ["<targetf>"] = target:GetFormattedName(),
        ["<issuer>"] = sender.name,
        ["<issuerf>"] = sender:GetFormattedName(),
        ["<reason>"] = (optarg == nil) and "" or optarg,
        ["<warncount>"] = tostring(warns - 1),
        ["<maxwarns>"] = tostring(Settings.Get("commands.maxwarns"))      
      })
      
      target:iPrintLnBold(Command.GetMessage("YouHaveBeenUnwarned"))
      
      SMAN.CMD_WARN_SET(target, warns - 1)
    end
  end
))

-- warns <player> [reset]
CommandList.Add(Command:new("warns", 1, Command.Behavior.HasOptionalArguments, 
  function(sender, arguments, optarg)
    local target = FindSinglePlayer(arguments[1])
    if target == nil then
      sender:WriteChat(Command.GetMessage("NotOnePlayerFound"))
      return false
    end
    
    local warns = SMAN.CMD_WARN_GET(target)
    
    if Utilities.String.IsNullOrWhiteSpace(optarg) then
      sender:WriteChat(Command.GetString("warns", "message"):gsubMul{
        ["<target>"] = target.name,
        ["<targetf>"] = target:GetFormattedName(),
        ["<warncount>"] = tostring(warns),
        ["<maxwarns>"] = tostring(Settings.Get("commands.maxwarns"))
      })
    else
      local reset = Utilities.ParseBool(optarg)
      if not reset then
        sender:WriteChat(Command.GetString("warns", "usage"))
        return false
      end
      
      if warns == 0 then
        sender:WriteChat(Command.GetString("warns", "message"):gsubMul{
          ["<target>"] = target.name,
          ["<targetf>"] = target:GetFormattedName(),
          ["<warncount>"] = tostring(warns),
          ["<maxwarns>"] = tostring(Settings.Get("commands.maxwarns"))
        })
        return false
      end
      
      SMAN.CMD_WARN_SET(target, 0)
      WriteChatToAll(Command.GetString("warns", "reset"):gsubMul{
        ["<target>"] = target.name,
        ["<targetf>"] = target:GetFormattedName(),
        ["<issuer>"] = sender.name,
        ["<issuerf>"] = sender:GetFormattedName()
      })
    end
  end
))

-- setgroup <player> <groupname/default>
CommandList.Add(Command:new("setgroup", 2, Command.Behavior.Normal, 
  function(sender, arguments, optarg)
    assert(SMAN.db ~= nil, "Error: Groups database not loaded! \n" .. debug.traceback())
    
    local target = FindSinglePlayer(arguments[1])
    if target == nil then
      sender:WriteChat(Command.GetMessage("NotOnePlayerFound"))
      return false
    end

    arguments[2] = arguments[2]:lower()
 
    local group = GroupsDatabase.GetGroup(arguments[2])
    
    if group == nil then
      sender:WriteChat(Command.GetMessage("GroupNotFound"))
      return false
    end
    
    sender:SetGroup(group.group_name, sender)
    
    WriteChatToAll(Command.GetString("setgroup", "message"):gsubMul{
      ["<target>"] = target.name,
      ["<targetf>"] = target:GetFormattedName(),
      ["<issuer>"] = sender.name,
      ["<issuerf>"] = sender:GetFormattedName(),
      ["<rankname>"] = group.group_name,
    })
  end
))

function CMD_kick(target, reason)
  if Utilities.String.IsNullOrEmpty(reason) then reason = "You have been kicked" end
  AfterDelay(200, function() 
    util.executeCommand("dropclient " .. target:getentitynumber() .. " \"" .. reason .. "\"")
  end)
end