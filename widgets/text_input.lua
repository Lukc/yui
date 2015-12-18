
local sdl = require "SDL"

local utf8 = require "utf8"

local Object = require "object"

local Widget = require "widgets.widget"
local Label  = require "widgets.label"

local fonts = require "fonts"

local _M = {}

function _M:handleKeyboardEvent(eventName, event)
	local r

	if eventName == "textInput" then
		self.label:setText(self.label.text .. event.text)

		r = true
	elseif eventName == "keyDown" then
		if event.keysym.sym == sdl.key.Backspace then
			self.label:setText(
				utf8.sub(self.label.text, 1, utf8.len(self.label.text) - 1))

			r = true
		elseif event.keysym.sym == sdl.key.Enter then
			self:triggerEvent("newValue", self.label.text)

			r = true
		end
	end

	r = self:triggerEvent(eventName, event)	or r

	if r then
		return r
	end
end

function _M:update(dt)
	Widget.update(self, dt)

	Label.update(self.label, dt)
end

function _M:draw(renderer)
	if self.hovered then
		renderer:setDrawColor(0x00FFFF)
	elseif self.focused then
		renderer:setDrawColor(0x0088FF)
	else
		renderer:setDrawColor(0x008888)
	end

	renderer:fillRect {
		x = self.realX,
		y = self.realY,
		w = self.realWidth,
		h = self.realHeight
	}

	self.label:draw(renderer)
end

function _M:new(arg)
	Widget.new(self, arg)

	self.label = Label ""

	self.label.parent = self
	
	self.clickable = true
end

return Object(_M, Label)

