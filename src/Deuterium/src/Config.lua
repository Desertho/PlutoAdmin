DefaultCmdLang = {

  Message_NotOnePlayerFound   = "^1No or more players found under that criteria.",
  Message_NotOneMapFound      = "^1No or more maps found under that criteria.",
  Message_CommandNotFound     = "^1Command not found.",
  Message_GroupNotFound       = "^1No group was found under that name.",
  Message_NotLoggedIn         = "^1You need to log in first.",
  Message_NoPermission        = "^1You do not have permission to do that.",

  command_say_usage           = "^1Usage: !say <message>",

  command_ping_usage          = "^1Usage: !ping",

  command_rules_usage         = "^1Usage: !rules",
  
  command_iamgod_usage        = "^1Usage: !iamgod <group>",
  command_iamgod_message      = "^2<target> ^5has been added to group ^1<rankname>",
  command_iamgod_error1       = "^1Error: ^3There can be only one god exist...",
  command_iamgod_error2       = "^1Error: Invalid group",

  command_res_usage           = "^1Usage: !res",
  command_res_message         = "^5Map was restared by ^1<player>^5.",
  
  command_version_usage       = "^1Usage: !version",
  
  command_pm_usage            = "^1Usage: !pm <player> <message>",
  command_pm_send             = "^1You --> <recipient>: ^2<message>",
  command_pm_receive          = "^1<sender>^0: ^2<message>",
  
  command_map_usage           = "^1Usage: !map <mapname>",
  command_map_message         = "^5Map was changed by ^1<player>^5 to ^2<mapname>^5."
}

ConfigValues = {
  Version                     = "v0.0663",
  
  ConfigPath                  = ScriptPath .. "Deuterium\\",
  
  ChatPrefix                  = "^0[^:Snek^0]^7",
  ChatPrefixPM                = "^0[^5PM^0]^7"
}

Data = {

  StandardMapNames = {
  
    dome        = "mp_dome",
    mission     = "mp_bravo",
    lockdown    = "mp_alpha",
    bootleg     = "mp_bootleg",
    hardhat     = "mp_hardhat",
    bakaara     = "mp_mogadishu",
    arkaden     = "mp_plaza2",
    carbon      = "mp_carbon",
    fallen      = "mp_lambeth",
    outpost     = "mp_radar",
    downturn    = "mp_exchange",
    interchange = "mp_interchange",
    resistance  = "mp_paris",
    seatown     = "mp_seatown",
    village     = "mp_village",
    underground = "mp_underground"
    
  }

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
