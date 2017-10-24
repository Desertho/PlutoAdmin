local sqlite3 = require("lsqlite3")
inspect = require("inspect")

function switch(t)
  t.case = function (self,x)
    local f=self[x] or self.default
    if f then
      if type(f)=="function" then
        f(x,self)
      else
        error("case "..tostring(x).." not a function")
      end
    end
  end
  return t
end

SLOG = {

  Type = {
  
    main = 1,
    players = 2,
    chat = 3,
    commands = 4,
  
  },
  
  db = nil,

  init = function()
  
    if sqlite3 == nil then
      print("Error: Unable to load lsqlite3 dynamic library")
    else
      SLOG.db = sqlite3.open(ConfigValues.ConfigPath .. "logs.db")
      SLOG.db:exec([=[
        CREATE TABLE IF NOT EXISTS chat (
          id INTEGER PRIMARY KEY AUTOINCREMENT, 
          time VARCHAR (32), 
          playername VARCHAR (255), 
          guid BIGINT, 
          message TEXT
        );
        CREATE TABLE IF NOT EXISTS commands (
          id INTEGER PRIMARY KEY AUTOINCREMENT, 
          time VARCHAR (32), 
          playername VARCHAR (255), 
          guid BIGINT,
          executed BOOLEAN,
          command VARCHAR (255),
          arguments TEXT
        );        
      ]=])
    end
  end,
  
  logTo = function(logType, player, data)
    if (SLOG.db == nil) or (player == nil) or (data == nil) then
      return
    end 
    switch {
      [SLOG.Type.chat] = function (x)
        local stmt = SLOG.db:prepare([[
          INSERT INTO chat (time,playername,guid,message) VALUES (?,?,?,?)
        ]])
        stmt:bind_values(os.date("%Y-%m-%d %H:%M:%S"), player.name, player:getguid(), data.message)
        stmt:step()
        stmt:finalize()
      end,
      [SLOG.Type.commands] = function (x)
        local stmt = SLOG.db:prepare([[
          INSERT INTO commands (time,playername,guid,executed,command,arguments) VALUES (?,?,?,?,?,?)
        ]])
        stmt:bind_values(os.date("%Y-%m-%d %H:%M:%S"), player.name, player:getguid(), data.executed, data.command, data.arguments)
        stmt:step()
        stmt:finalize()
      end,      
      default = function (x) end,
    }:case(logType)
  end

}

SGRP = {
  db = nil,
  
  init = function()
    if sqlite3 == nil then
      print("Error: Unable to load lsqlite3 dynamic library")
    else
      SGRP.db = sqlite3.open(ConfigValues.ConfigPath .. "main.db")
      SGRP.db:exec([=[
        CREATE TABLE IF NOT EXISTS `groups` (
          `id` INTEGER PRIMARY KEY AUTOINCREMENT, 
          `playername` VARCHAR (255), 
          `guid` BIGINT, 
          `group` VARCHAR (255), 
          `set_by` VARCHAR (255)
        );       
      ]=])      
    end
  end,
  
  add = function(player, group, issuer)
    if SGRP.db == nil then return end 
    
    local stmt = SGRP.db:prepare([[
      INSERT OR IGNORE INTO `groups` (`playername`,`guid`,`group`,`set_by`) VALUES (?,?,?,?)
    ]])
    stmt:bind_values(player.name, player:getguid(), group, issuer.name)
    stmt:step()
    stmt:finalize()
  end,
  
  GetGroup = function(player)
    if SGRP.db == nil then return end
    
    local result = nil
    local stmt = SGRP.db:prepare([=[
      SELECT `group` FROM `groups` WHERE `guid` = ?
    ]=])
    stmt:bind(1, player:getguid())
    if stmt:step() == 100 then
      return stmt:get_values()[1]
    end
    stmt:finalize()
    
    return result
  end,
  
  count = function()
    if SGRP.db == nil then return end
    local result = nil
    local sql=[=[
      SELECT COUNT(*) FROM `groups`;
    ]=]
    function showrow(udata,cols,values,names)
      result = values[1]
      return 0
    end
    SGRP.db:exec(sql,showrow)
    
    return tonumber(result)
  end
}

SLOG.init()
SGRP.init()
