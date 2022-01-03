---------------------
-- Class Rectangle --
---------------------
Rectangle = {
    ar_points = {
        Vector:new{}, -- point top left
        Vector:new{}, -- point top right
        Vector:new{}, -- point bottom right
        Vector:new{}  -- point bottom left
    }
}

function Rectangle:new(object) --> return table
    object = object or {}
    setmetatable(object,self)
    self.__index = self
    return object
end

function Rectangle:get_points() --> return array
    return self.ar_points
end

function Rectangle:set_top_l(value)
    self.ar_points[1] = value
end

function Rectangle:get_top_l() --> return vector
    return self.ar_points[1]
end

function Rectangle:set_top_r(value)
    self.ar_points[2] = value
end

function Rectangle:get_top_r() --> return vector
    return self.ar_points[2]
end

function Rectangle:set_bottom_r(value)
    self.ar_points[3] = value
end

function Rectangle:get_bottom_r() --> return vector
    return self.ar_points[3]
end

function Rectangle:set_bottom_l(value)
    self.ar_points[4] = value
end

function Rectangle:get_bottom_l() --> return vector
    return self.ar_points[4]
end
