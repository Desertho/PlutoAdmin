local LIP = require(LibPath .. "LIP")
local inspect = require(LibPath .. "inspect")

Group = {
  permissions,
  group_name,
  login_password,
  prefix,
  CanDo
}

function Group:new(name, password, perms, prefix)
  if sh_name == nil then sh_name = "" end
  if password == nil then password = "" end
  if perms == nil then perms = "" end
  if prefix == nil then prefix = "" end
  
  local group = {}
  self.__index = self
  setmetatable(group, self)
  group.group_name = name:lower()
  group.login_password = password
  group.prefix = prefix
  group.permissions = perms:split(",")
  
  group.CanDo = function(permission)
    if Utilities.HasValue(group.permissions, permission) or Utilities.HasValue(group.permissions, "*all*") then
      return true
    end
    return false
  end
  
  return group
end

GroupsDatabase = {
  Groups = {},
  
  init = function()
    print(ConfigValues.ConfigPath)
    if not (Utilities.IO.file_exists(ConfigValues.ConfigPath .. "groups.ini")) then
      LIP.save(ConfigValues.ConfigPath .. "groups.ini", ordered_table.new{
        "default", {
          pass = "",
          permissions = "ping,rules,iamgod",
          prefix = ""
        },
        "moderator", {
          pass = "",
          permissions = "say",
          prefix = "^0[^1M^0]^7"
        },
        "owner", {
          pass = "",
          permissions = "*all*",
          prefix = "^0[^5Owner^0]^7"
        }
      })
    end
    
    local ini_table = LIP.load(ConfigValues.ConfigPath .. "groups.ini")
    for group, data in pairs(ini_table) do
      local _group = Group:new(group:lower(), data.pass, data.permissions, data.prefix)
      GroupsDatabase.Groups[#GroupsDatabase.Groups + 1] = _group
    end
    
  end,
  
  GetGroup = function(name)
    for i, group in pairs(GroupsDatabase.Groups) do
      if group.group_name == name:lower() then
        return group
      end
    end
    return nil
  end,
  
  GetPlayerGroup = function(player)
    local group = SGRP.GetGroup(player)
    return GroupsDatabase.GetGroup((group == nil) and "default" or group)
  end,
  
  GetEntityPermission = function(player, group, permission_string)
    if Utilities.HasValue(GroupsDatabase.GetGroup("default").permissions, permission_string) then
      return true
    end
    return group.CanDo(permission_string)
  end,
  
  FindEntryFromPlayers = function(GUID)
    local result = nil
    for player in util.iterPlayers() do
      if player:getguid() == GUID then
        if result == nil then
          result = player
        else
          print("Error: found multiple players with same GUID.")
          return nil
        end
      end
    end
    return result
  end
}

GroupsDatabase.init()