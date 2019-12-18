
local component = require("component")
local robot = require("robot")
local event = require("event")
local fs = require("filesystem")
local port = 512
local keyWord = "ECSGrief"
local modem
local toolUsingMode = false
local toolUsingSide = 1

if component.isAvailable("modem") then
	modem = component.modem
else
	error("Ýòîé ïðîãðàììå òðåáóåòñÿ áåñïðîâîäíîé ìîäåì äëÿ ðàáîòû!")
end

modem.open(port)

-------------------------------------------------------------------------------------

local commands = {
	forward = robot.forward,
	back = robot.back,
	turnRight = robot.turnRight,
	turnLeft = robot.turnLeft,
	up = robot.up,
	down = robot.down,
	swing = robot.swing,
	drop = robot.drop
}


local function receive()
	while true do
		local eventData = { event.pull() }
		if eventData[1] == "modem_message" and eventData[4] == port and eventData[6] == keyWord then
			local message = eventData[7]
			local message2 = eventData[8]

			if commands[message] then
				commands[message]()
			else
				if message == "selfDestroy" then
					local fs = require("filesystem")
					for file in fs.list("") do
						print("Óíè÷òîæàþ \"" .. file .. "\"")
						fs.remove(file)
					end
					require("term").clear()
					require("computer").shutdown()
				elseif message == "use" then
					if toolUsingMode then
						if toolUsingSide == 1 then
							print("Èñïîëüçóþ ýêèïèðîâàííûé ïðåäìåò â ðåæèìå ïðàâîãî êëèêà ïåðåä ðîáîòîì")
							robot.use()
						elseif toolUsingSide == 0 then
							print("Èñïîëüçóþ ýêèïèðîâàííûé ïðåäìåò â ðåæèìå ïðàâîãî êëèêà ïîä ðîáîòîì")
							robot.useDown()
						elseif toolUsingSide == 2 then
							print("Èñïîëüçóþ ýêèïèðîâàííûé ïðåäìåò â ðåæèìå ïðàâîãî êëèêà íàä ðîáîòîì")
							robot.useUp()
						end
					else
						if toolUsingSide == 1 then
							print("Èñïîëüçóþ ýêèïèðîâàííûé ïðåäìåò â ðåæèìå ëåâîãî êëèêà ïåðåä ðîáîòîì")
							robot.swing()
						elseif toolUsingSide == 0 then
							print("Èñïîëüçóþ ýêèïèðîâàííûé ïðåäìåò â ðåæèìå ëåâîãî êëèêà ïîä ðîáîòîì")
							robot.swingDown()
						elseif toolUsingSide == 2 then
							print("Èñïîëüçóþ ýêèïèðîâàííûé ïðåäìåò â ðåæèìå ëåâîãî êëèêà íàä ðîáîòîì")
							robot.swingUp()
						end
					end
				elseif message == "exit" then
					return
				elseif message == "redstone" then
					redstoneControl()
				elseif message == "changeToolUsingMode" then
					toolUsingMode = not toolUsingMode
				elseif message == "increaseToolUsingSide" then
					print("Èçìåíÿþ ðåæèì èñïîëüçîâàíèÿ âåùè")
					toolUsingSide = toolUsingSide + 1
					if toolUsingSide > 2 then toolUsingSide = 2 end
				elseif message == "decreaseToolUsingSide" then
					print("Èçìåíÿþ ðåæèì èñïîëüçîâàíèÿ âåùè")
					toolUsingSide = toolUsingSide - 1
					if toolUsingSide < 0 then toolUsingSide = 0 end
				end
			end
		end
	end
end

local function main()
	print(" ")
	print("Äîáðî ïîæàëîâàòü â ïðîãðàììó ECSGrief Receiver v1.0 alpha early access! Èäåò îæèäàíèå êîìàíä ñ áåñïðîâîäíîãî óñòðîéñòâà.")
	print(" ")
	receive()
	print(" ")
	print("Ïðîãðàììà ïðèåìà ñîîáùåíèé çàâåðøåíà!")
end

-------------------------------------------------------------------------------------

main()

-------------------------------------------------------------------------------------
