
local Object = require "object"

local Widget = require "widgets.widget"

local _M = {}

function _M:draw(renderer)
	if self.hovered then
		renderer:setDrawColor(0x00FFFF)
	else
		renderer:setDrawColor(0x008888)
	end

	renderer:drawRect {
		x = self.realX, y = self.realY,
		w = self.realWidth, h = self.realHeight
	}

	self:drawChildren(renderer)
end

function _M:new(arg)
	Widget.new(self, arg)

	self.clickable = true
end

return Object(_M, Widget)

