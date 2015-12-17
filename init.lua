
local sdl = require "SDL"

local Object = require "object"

local Widget    = require "widget"
local Window    = require "window"

local _M = {
	Widget    = Widget,
	Window    = Window,
}

local lastTime

function _M:run(elements)
	local time
	local timeDiff

	for e in sdl.pollEvent() do
		local i = 1
		while i <= #elements do
			local element = elements[i]

			--print("Unhandled event:", e, e.type)
			if true then
				i = #elements + 1
			else
				i = i + 1
			end
		end
	end

	-- Time differential. Required before updates.
	time = sdl.getTicks()
	if lastTime then
		timeDiff = time - lastTime
	else
		timeDiff = 0
		lastTime = time
	end

	if timeDiff < 1000/60 then
		sdl.delay(1000/60 - timeDiff)

		time = sdl.getTicks()
		timeDiff = time - lastTime

		--print("Too fast, delaying", timeDiff, 1000 / timeDiff)
	end

	lastTime = time

	-- Update
	for i = 1, #elements do
		local element = elements[i]

		if element.update then
			element:update(timeDiff)
		end
	end

	-- Drawing
	for i = 1, #elements do
		local element = elements[i]

		element.renderer:setDrawColor(element.backgroundColor)
		element.renderer:clear()

		if element.draw then
			element:draw(element.renderer)
		end

		element.renderer:present()
	end

	return true
end

return _M

