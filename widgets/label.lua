
local Object = require "object"

local Widget = require "widgets.widget"

local fonts = require "fonts"

local _M = {}

function _M:update()
	Widget.update(self)

	if self.updateNeeded then
		if self.text and self.text ~= "" then
			local _

			local root = self:getRoot()
			local renderer = root.renderer

			local color = self.color or
				self:themeData("defaultFontColor") or 0xFFFFFF
			local font = self.font or
				self:themeData("defaultFont") or "default"

			self.surface =
				fonts[font]:renderUtf8(self.text, "solid", color)

			self.texture =
				renderer:createTextureFromSurface(self.surface)

			_, _, self.realWidth, self.realHeight =
				self.texture:query()
		else
			self.surface = nil
			self.texture = nil

			self.realWidth, self.realHeight = 0, 0
		end

		self.updateNeeded = false
	end

	if self.align == "left" then
		self.realX = self.parent.realX + self.x
	elseif self.align == "center" then
		self.realX = self.parent.realX + self.x +
			(self.parent.realWidth - self.realWidth) / 2
	elseif self.align == "right" then
		self.realX = self.parent.realX + self.parent.realWidth - self.realWidth
	end

	if self.vAlign == "top" then
		self.realY = self.parent.realY + self.y
	elseif self.vAlign == "middle" then
		self.realY = self.parent.realY + self.y +
			(self.parent.realHeight - self.realHeight) / 2
	elseif self.align == "bottom" then
		self.realY = self.parent.realY + self.parent.realHeight - self.realHeight
	end
end

function _M:draw(renderer)
	renderer:setDrawColor(0xFFFFFF)

	if not self.texture then
		return
	end

	local _, _, width, height = self.texture:query()

	if self.texture then
		renderer:copy(self.texture, nil, {
			x = self.realX,
			y = self.realY,
			w = width,
			h = height
		})
	end

	renderer:drawRect {
		x = self.realX,
		y = self.realY,
		w = self.realWidth,
		h = self.realHeight
	}
end

function _M:setText(text)
	self.text = text

	self.updateNeeded = true
end

function _M:new(arg)
	if type(arg) == "string" then
		print("String arg.")
		arg = {
			text = arg
		}
	end

	Widget.new(self, arg)

	self:setText(arg.text)

	-- Fallbacks are available in theme data.
	-- Secondary fallbacks are hardcoded and you shouldn’t rely on those.
	self.font = arg.font
	self.color = arg.color

	self.align = arg.align or "left"
	self.vAlign = arg.vAlign or "top"
end

return Object(_M, Widget)

