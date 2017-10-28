util.printf("Welcome to Deuterium %s!", ConfigValues.Version)



print("Ininializing Settings...")
Settings.init()

print("Ininializing logs database...")
SLOG.init()

print("Ininializing main database...")
SMAN.init()

print("Ininializing groups...")
GroupsDatabase.init()




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
    SLOG.logTo(SLOG.Type.chat, args.sender, {message = args.message})
  else
    xpcall(
      function() return ProcessCommand(args.sender, args.message) end, 
      function(E) print(Utilities.DefaultError(E)) end
    )
  end
  return true  
end

callbacks.playerSay.add(onPlayerSay)
callbacks.playerConnecting.add(onPlayerConnecting)
callbacks.playerConnected.add(onPlayerConnected)
callbacks.playerRequestingConnection.add(onPlayerRequestingConnection)

callbacks.onInterval.add(40000, timedMessages)

print("Deuterium successfully loaded.")