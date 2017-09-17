local stringy = require 'stringy'
local lfs = require 'lfs'

local template = [[
#NoEnv
; #Warn
SendMode Input
SetWorkingDir %A_ScriptDir%
#IfWinActive ahk_class Warcraft III

Msg(str)
{
	Send, {Enter}
	Send, %str%
	Send, {Enter}
	Sleep, 25
}

^q::
	Msg("_cq")
]]

function process(filename)
	local output = template

	local i = 1
	local version = "-1"
	local x = "0"
	local y = "0"

	local commands = {}

	for line in io.lines(filename .. ".txt") do
		line = string.match(line, "#%[%[([-%w|%.:]+)%]%]#")

		if (line) then
			local t = string.match(line, "([%w]+)::")
			line = string.match(line, "::([-%w|%.]+)")

			print(t)

			if (t == "ox") then
				x = line
			elseif (t == "oy") then
				y = line
			elseif (t == "tile") then
				table.insert(commands, "_at " .. table.concat(stringy.split(line, "|"), " "))
			elseif (t == "deform") then
				table.insert(commands, "_ad " .. table.concat(stringy.split(line, "|"), " "))
			elseif (t == "unit") then
				table.insert(commands, "_au " .. table.concat(stringy.split(line, "|"), " "))
			end

			i = i + 1
		end
	end

	output = output .. "\n\tMsg(\"_so " .. x .. " " .. y .. "\")"

	for k, v in pairs(commands) do
		output = output .. "\n\t" .. "Msg(\"" .. v .. "\")"
	end

	output = output .. "\n\tMsg(\"_sp\")\nReturn\n"

	local file = io.open(filename .. ".ahk", "w")

	file:write(output)
end

for filename in lfs.dir("./") do
	local name = filename:match("([-%w ]+)%.txt")

	if (name) then
		process(name)
	end
end
