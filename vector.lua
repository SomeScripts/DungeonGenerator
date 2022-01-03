------------------
-- Class Vector --
------------------
Vector = {
    x = 0,
    y = 0,
}

function Vector:new(object) --> returns table
    object = object or {}
    setmetatable(object,self)
    self.__index = self
    return object
end

function Vector:get_x() --> returns nbr
    return self.x
end

function Vector:get_y() --> returns nbr
    return self.y
end