
---
-- Image widget.
--
-- @classmod Label

local image = require "SDL.image"

local Object = require "object"

local Widget = require "widgets.widget"

local fonts = require "fonts"

local _M = {}

function _M:update()
	if self.updateNeeded then
		local renderer = self:getRoot().renderer

		self.texture = renderer:createTextureFromSurface(self.surface)

		local _, _, width, height = self.texture:query()

		self.realWidth = width
		self.realHeight = height

		self.updateNeeded = false
	end

	Widget.update(self)

	if self.align == "left" then
		self.realX = self.parent.realX + self.x
	elseif self.align == "center" then
		self.realX = self.parent.realX + self.x +
			(self.parent.realWidth - self.realWidth) / 2
	elseif self.align == "right" then
		self.realX = self.parent.realX + self.x +
			self.parent.realWidth - self.realWidth
	end

	if self.vAlign == "top" then
		self.realY = self.parent.realY + self.y
	elseif self.vAlign == "middle" then
		self.realY = self.parent.realY + self.y +
			(self.parent.realHeight - self.realHeight) / 2
	elseif self.vAlign == "bottom" then
		self.realY = self.parent.realY + self.y + 
			self.parent.realHeight - self.realHeight
	end
end

function _M:draw(renderer)
	if not self.texture then
		return
	end

	self:drawTexture(renderer, self.texture)
end

---
-- Image constructor.
--
-- @param arg Table of options, given to `Widget:new`
-- @param arg.file File from which to import the image.
--
-- @see Widget:new
function _M:new(arg)
	if type(arg) == "string" then
		arg = {
			file = arg
		}
	end

	Widget.new(self, arg)

	self.surface = image.load(arg.file)

	self.updateNeeded = true

	self.align = arg.align or "left"
	self.vAlign = arg.vAlign or "top"
end

return Object(_M, Widget)

