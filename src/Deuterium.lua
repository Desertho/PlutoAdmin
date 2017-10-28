ScriptPath = "scripts\\mp\\"
LibPath    = "scripts\\lib\\"

sqlite3 = require("lsqlite3")
inspect = require(LibPath .. "inspect")
LIP     = require(LibPath .. "LIP")

require(ScriptPath .. "Deuterium.src.Config")
require(ScriptPath .. "Deuterium.src.SQLite")
require(ScriptPath .. "Deuterium.src.Utilities")
require(ScriptPath .. "Deuterium.src.Groups")
require(ScriptPath .. "Deuterium.src.Commands")
require(ScriptPath .. "Deuterium.src.Main")

