assert(sqlite3 ~= nil, "Error: Unable to load lsqlite3 dynamic library \n" .. debug.traceback())

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

local sqlutil = { 
  runner = function(db, args, statements)
    for i, statement in pairs (statements) do
      local stmt = db:prepare(statement)
      stmt:bind_names(args)
      stmt:step()
      stmt:finalize()
    end
  end
}

SLOG = {

  Type = {
  
    main = 1,
    players = 2,
    chat = 3,
    commands = 4,
  
  },
  
  db = nil,

  init = function()

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

SMAN = {
  db = nil,
  
  init = function()
    
    SMAN.db = sqlite3.open(ConfigValues.ConfigPath .. "main.db")
    SMAN.db:exec([=[
      CREATE TABLE IF NOT EXISTS `groups` (
        `id` INTEGER PRIMARY KEY AUTOINCREMENT, 
        `playername` VARCHAR (255), 
        `guid` BIGINT UNIQUE, 
        `group` VARCHAR (255), 
        `set_by` VARCHAR (255)
      );
      CREATE TABLE IF NOT EXISTS `cmd_warn` (
        `id` INTEGER PRIMARY KEY AUTOINCREMENT, 
        `playername` VARCHAR (255), 
        `guid` BIGINT UNIQUE, 
        `warns` INTEGER
      );      
    ]=])
  end,
  
  CMD_WARN_GET = function(player)
    local result = nil
    local stmt = SMAN.db:prepare([=[
      SELECT `warns` FROM `cmd_warn` WHERE `guid` = ?
    ]=])
    stmt:bind(1, player:getguid())
    if stmt:step() == 100 then
      result = stmt:get_values()[1]
    end
    stmt:finalize()
    
    return (tonumber(result) == nil) and 0 or tonumber(result)
  end,
  
  CMD_WARN_SET = function(player, warns)
    if warns == 0 then
      sqlutil.runner(SMAN.db, {
          guid = player:getguid()
        },
        {[[
            DELETE FROM `cmd_warn` WHERE `guid` = :guid;
         ]]
        }
      )
    else
      sqlutil.runner(SMAN.db, {
          playername = player.name, 
          guid = player:getguid(), 
          warns = warns, 
        },
        {[[
            /* update if exists */
            UPDATE `cmd_warn` SET `warns` = :warns WHERE `guid` = :guid;
         ]],[[
            /* coalesce by guid */
            INSERT OR IGNORE INTO `cmd_warn` 
            ( `playername`,  `guid`,  `warns`) VALUES 
            ( :playername,   :guid,   :warns);
         ]]
        }
      )
    end
  end
}

SGRP = {

  SetGroup = function(player, group, issuer)
    if group == "default" then
      sqlutil.runner(SMAN.db, {
          guid = player:getguid()
        },
        {[[
          DELETE FROM `groups` WHERE `guid` = :guid;
        ]]}
      )
    else
      sqlutil.runner(SMAN.db, {
          playername = player.name, 
          guid = player:getguid(), 
          group = group, 
          set_by = issuer.name
        },
        {[[
            /* update if exists */
            UPDATE `groups` SET 
              `group` = :group, 
              `set_by` = 
                CASE WHEN 
                  :playername = :set_by
                THEN
                  (SELECT set_by FROM `groups` WHERE `guid` = :guid)
                ELSE
                  :set_by
                END
            WHERE `guid` = :guid;
         ]],[[
            /* coalesce by guid */
            INSERT OR IGNORE INTO `groups` 
            ( `playername`,  `guid`,  `group`,  `set_by`) VALUES 
            ( :playername,   :guid,   :group,   :set_by);
         ]]
        }
      )
    end
  end,
  
  GetGroup = function(player)
    local result = nil
    local stmt = SMAN.db:prepare([=[
      SELECT `group` FROM `groups` WHERE `guid` = ?
    ]=])
    stmt:bind(1, player:getguid())
    if stmt:step() == 100 then
      result = stmt:get_values()[1]
    end
    stmt:finalize()
    
    return result
  end,
  
  Count = function()
    local result = nil
    local sql=[=[
      SELECT COUNT(*) FROM `groups`;
    ]=]
    function showrow(udata,cols,values,names)
      result = values[1]
      return 0
    end
    SMAN.db:exec(sql,showrow)
    
    return tonumber(result)
  end
}
