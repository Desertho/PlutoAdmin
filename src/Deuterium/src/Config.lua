DefaultCmdLang = {

   Message_CommandNotFound = "^1Command not found.",

   command_say_usage = "^1Usage: !say <message>",
   
   command_ping_usage = "^1Usage: !ping",
   
   command_rules_usage = "^1Usage: !rules"

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