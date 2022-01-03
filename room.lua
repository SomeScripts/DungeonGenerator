----------------
-- Class Room --
----------------
Room = {
    center_pos = Vector:new{},
    ar_rect_points = {},
    is_in_main_road  = false,
}

function Room:new(object) --> return table
    object = object or {}
    setmetatable(object,self)
    self.__index = self    
    return object
end