
local Object = require "object"

local Widget = require "widgets.widget"

local _M = {}

function _M:draw(renderer)
	if not self:themeDraw("Frame", renderer) then
		if self.clicked then
			renderer:setDrawColor(0xFF0088)
		elseif self.hovered then
			renderer:setDrawColor(0xFF00FF)
		elseif self.focused then
			renderer:setDrawColor(0x0088FF)
		else
			renderer:setDrawColor(0x880088)
		end

		renderer:drawRect {
			x = self.realX, y = self.realY,
			w = self.realWidth, h = self.realHeight
		}

		renderer:drawLine {
			x1 = self.realX + 1,
			y1 = self.realY + self.titleHeight,
			x2 = self.realX + self.realWidth - 1,
			y2 = self.realY + self.titleHeight
		}
	end

	self:drawChildren(renderer)
end

function _M:update(dt)
	self:triggerEvent("update")

	for i = 1, #self.children do
		local child = self.children[i]

		child.realX = child.x + self.realX
		child.realY = child.y + self.realY
	end

	self:updateChildren(dt)
end

function _M:new(arg)
	Widget.new(self, arg)

	self.titleHeight = arg.titleHeight or 30

	self.clickable = true
end

return Object(_M, Widget)

