
local component = require("component")
local robot = require("robot")
local event = require("event")
local fs = require("filesystem")
local port = 512
local keyWord = "ECSGrief"
local modem
local redstone = component.redstone
local redstoneState = false
local toolUsingMode = false
local toolUsingSide = 1

if component.isAvailable("modem") then
	modem = component.modem
else
	error("���� ��������� ��������� ������������ ����� ��� ������!")
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
						print("��������� \"" .. file .. "\"")
						fs.remove(file)
					end
					require("term").clear()
					require("computer").shutdown()
				elseif message == "use" then
					if toolUsingMode then
						if toolUsingSide == 1 then
							print("��������� ������������� ������� � ������ ������� ����� ����� �������")
							robot.use()
						elseif toolUsingSide == 0 then
							print("��������� ������������� ������� � ������ ������� ����� ��� �������")
							robot.useDown()
						elseif toolUsingSide == 2 then
							print("��������� ������������� ������� � ������ ������� ����� ��� �������")
							robot.useUp()
						end
					else
						if toolUsingSide == 1 then
							print("��������� ������������� ������� � ������ ������ ����� ����� �������")
							robot.swing()
						elseif toolUsingSide == 0 then
							print("��������� ������������� ������� � ������ ������ ����� ��� �������")
							robot.swingDown()
						elseif toolUsingSide == 2 then
							print("��������� ������������� ������� � ������ ������ ����� ��� �������")
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
					print("������� ����� ������������� ����")
					toolUsingSide = toolUsingSide + 1
					if toolUsingSide > 2 then toolUsingSide = 2 end
				elseif message == "decreaseToolUsingSide" then
					print("������� ����� ������������� ����")
					toolUsingSide = toolUsingSide - 1
					if toolUsingSide < 0 then toolUsingSide = 0 end
				end
			end
		end
	end
end

local function main()
	print(" ")
	print("����� ���������� � ��������� ECSGrief Receiver v1.0 alpha early access! ���� �������� ������ � ������������� ����������.")
	print(" ")
	receive()
	print(" ")
	print("��������� ������ ��������� ���������!")
end

-------------------------------------------------------------------------------------

main()

-------------------------------------------------------------------------------------
