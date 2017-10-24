DefaultCmdLang = {

  Message_CommandNotFound = "^1Command not found.",
  Message_GroupNotFound = "^1No group was found under that name.",
  Message_NotLoggedIn = "^1You need to log in first.",
  Message_NoPermission = "^1You do not have permission to do that.",

  command_say_usage = "^1Usage: !say <message>",

  command_ping_usage = "^1Usage: !ping",

  command_rules_usage = "^1Usage: !rules",
  
  command_iamgod_usage = "^1Usage: !iamgod <group>",
  command_iamgod_message = "^2<target> ^5has been added to group ^1<rankname>",
  command_iamgod_error1 = "^1Error: ^3There can be only one god exist...",
  command_iamgod_error2 = "^1Error: Invalid group"

}

ConfigValues = {
  ConfigPath = ScriptPath .. "Deuterium\\",
  
  ChatPrefix = "^0[^:Snek^0]^7",
  ChatPrefixPM = "^0[^5PM^0]^7"
}

function CmdLang_GetString(key)
  local value = DefaultCmdLang[key]
  if value == nil then
    print("[Error] Language string not found: " .. key)
    return ""
  else
    return value
  end
end  
