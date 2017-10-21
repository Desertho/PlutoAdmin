require("scripts\\mp\\Deuterium.src.Config")
require("scripts\\mp\\Deuterium.src.Utilities")
require("scripts\\mp\\Deuterium.src.Commands")


function onPlayerConnecting(args)
	print("[onPlayerConnecting]: " .. args.player.name .. " is connecting.")
end

function onPlayerConnected(player)
	WriteChatToAll("^5" .. player.name .. " ^7has connected.")
	print("[onPlayerConnected]: " .. player.name .. " : " .. tostring(player.steamId) .. " : " .. tostring(player.ip))
end

function onPlayerRequestingConnection(args)
	print("[onPlayerRequestingConnection]: Connection request from IP " .. tostring(args.ip))
end

function onPlayerSay(args)
  if string.sub(args.message, 1, 1) ~= "!" then
    Utilities.RawSayAll(args.sender.name .. ": " .. args.message)
  else
    xpcall(
      function() return ProcessCommand(args.sender, args.message) end, 
      function(E) WriteChatToPlayer(args.sender, E:gsub("Z:\\home\\musta\\Desktop\\Finally\\scripts\\mp\\", "" )) end
    )
  end
  return true  
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

callbacks.playerSay.add(onPlayerSay)
callbacks.playerConnecting.add(onPlayerConnecting)
callbacks.playerConnected.add(onPlayerConnected)
callbacks.playerRequestingConnection.add(onPlayerRequestingConnection)

callbacks.onInterval.add(40000, timedMessages)
print("Callbacks installed")
