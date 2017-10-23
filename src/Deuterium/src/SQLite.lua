sqlite3 = require("lsqlite3")


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
          guid INTEGER, 
          message TEXT
        );
        CREATE TABLE IF NOT EXISTS commands (
          id INTEGER PRIMARY KEY AUTOINCREMENT, 
          time VARCHAR (32), 
          playername VARCHAR (255), 
          guid INTEGER,
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

SLOG.init()