Settings = {

  DefaultSettings = {
    commands = {
      maxwarns = 3
    }
  },
  
  Settings = {},
  
  init = function()
    if not (Utilities.IO.file_exists(ConfigValues.ConfigPath .. "settings.ini")) then
      LIP.save(ConfigValues.ConfigPath .. "settings.ini", Settings.DefaultSettings)
    end
    
    Settings.Settings = LIP.load(ConfigValues.ConfigPath .. "settings.ini")
  end,
  
  Get = function(key)
    local _key = key:Split(".")
    local value = Settings.Settings[_key[1]][_key[2]]
    if value == nil then
      value = Settings.DefaultSettings[_key[1]][_key[2]]
      if value == nil then
        error("Setting string not found: " .. key)
      end
    end
    
    return value
  end
  
}

DefaultLang = {

  ChatPrefix                  = "^0[^:Snek^0]^7",
  ChatPrefixPM                = "^0[^5PM^0]^7",
  FormattedNameRank           = "<shortrank> <name>",
  FormattedNameRankless       = "<name>"

}

DefaultCmdLang = {

  Message_NotOnePlayerFound   = "^1No or more players found under that criteria.",
  Message_NotOneMapFound      = "^1No or more maps found under that criteria.",
  Message_CommandNotFound     = "^1Command not found.",
  Message_GroupNotFound       = "^1No group was found under that name.",
  Message_NotLoggedIn         = "^1You need to log in first.",
  Message_NoPermission        = "^1You do not have permission to do that.",
  Message_YouHaveBeenWarned   = "^1You have been warned!",
  Message_YouHaveBeenUnwarned = "^2You have been unwarned!",

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
  command_map_message         = "^5Map was changed by ^1<player>^5 to ^2<mapname>^5.",

  command_admins_usage        = "^1Usage: !admins",
  command_admins_firstline    = "^1Online Admins: ^7",
  command_admins_formatting   = "<formattedname>",
  command_admins_separator    = "^7, ",
  
  command_status_usage        = "^1Usage: !status [players]",
  command_status_firstline    = "^3Online players:",
  command_status_formatting   = "^1<id>^0 : ^7<namef>",
  
  command_kick_usage          = "^1Usage: !kick <player> [reason]",
  command_kick_message        = "^3<target>^7 was ^5kicked^7 by ^1<issuer>^7. Reason: ^6<reason>",
  
  command_warns_usage         = "^1Usage: !warns <player> [reset]",
  command_warns_message       = "^1<target>^7 has ^3(<warncount>/<maxwarns>) ^7warnings.",
  command_warns_reset         = "^3<target>^7 had his warnings ^2reset ^7by ^1<issuer>^7.",
  
  command_warn_usage          = "^1Usage: !warn <player> [reason]",
  command_warn_message        = "^3<target>^7 was ^3warned (<warncount>/<maxwarns>)^7 by ^1<issuer>^7. Reason: ^6<reason>",

  command_unwarn_usage        = "^1Usage: !unwarn <player> [reason]",
  command_unwarn_message      = "^3<target>^7 was ^2unwarned (<warncount>/<maxwarns>)^7 by ^1<issuer>^7. Reason: ^6<reason>",
  
  command_setgroup_usage      = "^1Usage: !setgroup <player> <groupname/default>",
  command_setgroup_message    = "^2<target> ^5has been added to group ^1<rankname> ^5by ^2<issuer>" 

}

ConfigValues = {
  Version                     = "v0.1074",
  
  ConfigPath                  = ScriptPath .. "Deuterium\\",
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
    
  },
  
  Colors = {
  
    ["^1"] = "red",
    ["^2"] = "green",
    ["^3"] = "yellow",
    ["^4"] = "blue",
    ["^5"] = "lightblue",
    ["^6"] = "purple",
    ["^7"] = "white",
    ["^8"] = "defmapcolor",
    ["^9"] = "grey",
    ["^0"] = "black",
    ["^;"] = "yaleblue",
    ["^:"] = "orange"
    
  }

}

function CmdLang_GetString(key)
  local value = DefaultCmdLang[key]
  if value == nil then
    print("[Error] Command language string not found: " .. key)
    return ""
  else
    return value
  end
end  

function Lang_GetString(key)
  local value = DefaultLang[key]
  if value == nil then
    print("[Error] Language string not found: " .. key)
    return ""
  else
    return value
  end
end