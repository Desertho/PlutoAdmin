Utilities = {

  RawSayAll = function(message) 
    util.chatPrint(message)
  end,

  RawSayTo = function(player, message)
    player:tell(message)
  end,
  
  String = {
    IsNullOrWhiteSpace = function(str)
      return not(str ~= nil and str:match("%S") ~= nil)
    end,
    
    IsNullOrEmpty = function(str)
      return not(str ~= nil and str ~= "")
    end,    
  },
  
  IO = {
    file_exists = function(path)
       local f = io.open(path,"r")
       if f ~= nil then io.close(f) return true else return false end
    end,
    
    path_exists = function (path)
      local ok, err, code = os.rename(path, path)
      if not ok then
        if code == 13 then
          -- Permission denied, but it exists
          return true
        end
      end
      return ok, err
    end,  
    
    ReadAllLines = function(file)
      if not Utilities.IO.file_exists(file) then return {} end
      local lines = {}
      for line in io.lines(file) do 
        lines[#lines + 1] = line
      end
      return lines
    end
  },
  
  ParseBool = function(message)
    message = message:lower():Trim();
    if message == "y" or message == "ye" or message == "yes" or message == "on" or message == "true" or message == "1" then
      return true
    end
    return false
  end,
  
  GetDvar = function(key)
    return gsc.getdvar(key)
  end,
  
  SetDvar = function(key, value)
    gsc.setdvar(key, value)
  end,
  
  FilterComments = function(lines)
    local result = {}
    if lines == nil then return result end
    
    for i,v in ipairs(lines) do
      if v:sub(1,2) ~= "//" then
        result[#result + 1] = v
      end
    end
    return result
  end,
  
  DefaultError = function(E)
    return  E:gsub("%.%.%..-scripts", "" )
  end
}

function AfterDelay(delay, func)
  assert(type(func) == "function", "Not a function \n" .. debug.traceback())
  callbacks.afterDelay.add(delay, func)
end

function string:Literalize()
    return self:gsub("[%(%)%.%%%+%-%*%?%[%]%^%$]", "%%%0")
end

-- split a string
function string:Split(delimiter)
  delimiter = delimiter:Literalize()
  local result = { }
  local from  = 1
  local delim_from, delim_to = string.find( self, delimiter, from  )
  while delim_from do
    table.insert( result, string.sub( self, from , delim_from-1 ) )
    from  = delim_to + 1
    delim_from, delim_to = string.find( self, delimiter, from  )
  end
  table.insert( result, string.sub( self, from  ) )
  return result
end

function string:gsubMul(t)
  for k,v in pairs(t) do
    self = self:gsub(k,v)
  end
  return self
end

function string:IndexOf(s)
  return string.find(self, s, 1, true)
end

function string:TrimEnd()
  return self:gsub("%s+$", "")
end 

function string:Trim()
  return self:match "^%s*(.-)%s*$"
end

function string:Contains(s)
  if s == nil then return false end
  return string.IndexOf(self, s) ~= nil
end

function string:RemoveColors()
  for k,v in pairs(Data.Colors) do
    self = self:gsub(k:Literalize(),"")
  end
  return self
end

function table.HasValue(self, value)
  for i, v in ipairs(self) do
    if value == v then
      return true
    end
  end
  return false
end

function table.Union(self, _table)
  for i, v in ipairs(_table) do
    if not table.HasValue(self, v) then
      table.insert(self, v)
    end
  end
  return self
end

function table.FromIterator(...)
  local arr = {}
  for v in ... do
    arr[#arr + 1] = v
  end
  return arr
end

function table.Condense(self, condenselevel, separator)
  if condenselevel == nil then condenselevel = 40 end
  if separator == nil then separator = ", " end
  
  if #self < 1 then
    return self
  end
  local _lines = {}
  local index = 1
  local line = self[index]
  index = index + 1
  while index < #self do
    if ((line .. separator .. self[index]):RemoveColors():len() > condenselevel) then
      _lines[#_lines + 1] = line
      line = self[index]
    else
      line = line .. separator .. self[index]
    end
    index = index + 1
  end
  _lines[#_lines + 1] = line
  
  return _lines
end

function WriteChatToAll(message)
  Utilities.RawSayAll(Lang_GetString("ChatPrefix") .. " " .. message)
end

function Player:WriteChat(message)
  if message == nil then return end
  Utilities.RawSayTo(self, Lang_GetString("ChatPrefixPM") .. " " .. message)
end

function Player:WriteChatMultiline(messages, delay)
  if delay == nil then delay = 500 end

  for i, message in ipairs(messages) do
    callbacks.afterDelay.add((i - 1) * delay, 
      function() self:WriteChat(message) end
    )
  end
end

function Player:WriteChatCondensed(messages, delay, condenselevel, separator)
  if delay == nil then delay = 1000 end
  self:WriteChatMultiline(table.Condense(messages, condenselevel, separator), delay)
end

function Player:GetTeam()
  return self.sessionteam
end

function Player:IsSpectating()
  return self.sessionteam == "spectator"
end

function ChangeMap(devmapname)
  util.executeCommand("map " .. devmapname)
end

function FindPlayers(identifier)
  if identifier:sub(1,1) == '#'  then
    local entref = tonumber(identifier:sub(2, #identifier))
      if entref >= 0 and entref < 18 then
        for player in util.iterPlayers() do
          if player:getentitynumber() == entref then
            return { player }
          end
        end
      end
    return {}
  else
    local result = {}
    identifier = identifier:lower()
    for player in util.iterPlayers() do
      if player.name:lower():Contains(identifier) then
        result[#result + 1] = player
      end
    end
    return result
  end
end

function FindSinglePlayer(identifier)
  local players = FindPlayers(identifier)
  if #players ~= 1 then
    return nil
  end
  return players[1]
end

function FindMaps(identifier)
  local result = {}
  identifier = identifier:lower()
  for mapname, devmapname in pairs(Data.StandardMapNames) do
    if mapname:Contains(identifier) or devmapname:Contains(identifier) then
      result[#result + 1] = devmapname
    end
  end
  return result
end

function FindSingleMap(identifier)
  local maps = FindMaps(identifier)
  if #maps ~= 1 then
    return nil
  end
  return maps[1]
end

-- Simple timed messages function
function timedMessages()
	local msgArray = 
	{ 
		"^:Welcome to ^1Snek ^:iSnipe Server^0",
		"^:Check ^1!rules ^:for the server rules",
		"^:Join our discord: ^1https://discord.gg/SyF9vtF",
	}
	
	math.randomseed(os.time())
	local printIndex = math.random(1, 3)
	
	WriteChatToAll(msgArray[printIndex])
end