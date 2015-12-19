
---
-- Primitive object/class implementation.
--
-- Does simple inheritance, makes constructors easy to define, and that’s about
-- it. Basically, it’s an automated metatables generator.
--
-- Inheritance is implemented through metatables and is done at run-time.
--
-- Calling classes actually calls their `new` method. Any field not found in
-- an object is looked up in its class, and then in its parent class, and so
-- on.

--- 
-- @param parent Parent which properties’ are to be inherited.
-- @param class  The properties of the future class.
--
-- @return class, which has been assigned a new metatable.
--
-- @class function
-- @name Object
return function(class, parent)
	setmetatable(class, {
		__call = function(self, ...)
			local instance = {
				objectType = self
			}

			setmetatable(instance, {
				__index = class
			})
			
			local r = class.new(instance, ...)

			return r or instance
		end,

		__index = parent
	})

	return class
end

