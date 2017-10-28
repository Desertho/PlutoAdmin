Group = {

--[[table<string>]]  permissions,
--[[string]]         group_name,
--[[string]]         login_password,
--[[string]]         prefix,
--[[func]]           CanDo

}

function Group:new(name, password, perms, prefix)
  if password == nil then password = "" end
  if perms == nil then perms = "" end
  if prefix == nil then prefix = "" end
  
  local group = {}
  self.__index = self
  setmetatable(group, self)
  group.group_name = name:lower()
  group.login_password = password
  group.prefix = prefix
  group.permissions = perms:Split(",")
  
  group.CanDo = function(permission)
    if table.HasValue(group.permissions, permission) or table.HasValue(group.permissions, "*all*") then
      return true
    end
    return false
  end
  
  return group
end

GroupsDatabase = {
  Groups = {},
  
  init = function()
    if not (Utilities.IO.file_exists(ConfigValues.ConfigPath .. "groups.ini")) then
      LIP.save(ConfigValues.ConfigPath .. "groups.ini", ordered_table.new{
        "default", {
          pass = "",
          permissions = "ping,rules,iamgod,version,pm,admins",
          prefix = ""
        },
        "friend", {
          pass = "",
          permissions = "res,map,kick,warn,unwarn",
          prefix = "^0[^6Friend^0]^7"
        },        
        "moderator", {
          pass = "",
          permissions = "res,map,status,kick,warn,unwarn",
          prefix = "^0[^1M^0]^7"
        },
        "admin", {
          pass = "",
          permissions = "say,res,map,status,kick,warn,unwarn,warns",
          prefix = "^0[^3A^0]^7"
        }, 
        "leader", {
          pass = "",
          permissions = "say,res,map,status,kick,warn,unwarn,warns,setgroup",
          prefix = "^0[^:Leader^0]^7"
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
  
  GetEntityPermission = function(player, group, permission)
    if table.HasValue(GroupsDatabase.GetGroup("default").permissions, permission) then 
      return true
    end
    return group.CanDo(permission)
  end,
  
  FindEntryFromPlayers = function(GUID)
    for player in util.iterPlayers() do
      if player:getguid() == GUID then
        return player
      end
    end
    return nil
  end,
  
  GetAdminsString = function(players)
    local result = {}
    for i, player in pairs(players) do
      local grp = player:GetGroup()
      if not Utilities.String.IsNullOrWhiteSpace(grp.prefix) then
        result[#result + 1] = Command.GetString("admins", "formatting"):gsubMul{
          ["<name>"] = player.name,
          ["<formattedname>"] = player:GetFormattedName(),
          ["<rankname>"] = grp.group_name,
          ["<shortrank>"] = grp.prefix
        }
      end
    end
    return result
  end
}

function Player:GetGroup()
  return GroupsDatabase.GetPlayerGroup(self)
end

function Player:SetGroup(group_name, issuer)
  SGRP.SetGroup(self, group_name, issuer)
end

function Player:GetFormattedName()
  local grp = self:GetGroup()
  if not Utilities.String.IsNullOrWhiteSpace(grp.prefix) then
    return Lang_GetString("FormattedNameRank"):gsubMul{
      ["<shortrank>"] = grp.prefix,
      ["<rankname>"] = grp.group_name,
      ["<name>"] = self.name
    }
  end
  return Lang_GetString("FormattedNameRankless"):gsubMul{
    ["<name>"] = self.name
  }
end