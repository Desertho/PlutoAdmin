function onPlayerConnecting(args)
	print("[onPlayerConnecting]: " .. args.player.name .. " is connecting.")
end

function onPlayerConnected(player)
	sayAll("^5" .. player.name .. " ^7has connected.")
	print("[onPlayerConnected]: " .. player.name .. " : " .. tostring(player.steamId) .. " : " .. tostring(player.ip))
end

function onPlayerRequestingConnection(args)
	print("[onPlayerRequestingConnection]: Connection request from IP " .. tostring(args.ip))
end

function RawSayAll(message)
  util.chatPrint(message)
end

function sayAll(message)
	local consoleName = "^0[^:Snek^0]^7: "
	util.chatPrint(consoleName .. message)
end

function onPlayerSay(args)
  RawSayAll(args.sender.name .. ": " .. args.message)
  
  local msg = args.message:lower()
  if msg == "!ping" then
    sayAll("^1pong, sucker!")
  end
  return true  
end

-- Simple timed messages function
function timedMessages()
	local msgArray = 
	{ 
		"^:Welcome to ^1Snek ^:iSnipe Server^0.",
		"^:Don't break iSnipe Rules.",
		"^:Join our discord: ^1https://discord.gg/SyF9vtF",
	}
	
	math.randomseed(os.time())
	local printIndex = math.random(1, 3)
	
	sayAll(msgArray[printIndex])
end

callbacks.playerSay.add(onPlayerSay)
callbacks.playerConnecting.add(onPlayerConnecting)
callbacks.playerConnected.add(onPlayerConnected)
callbacks.playerRequestingConnection.add(onPlayerRequestingConnection)

callbacks.onInterval.add(40000, timedMessages)
print("Callbacks installed")
