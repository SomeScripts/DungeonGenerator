-----------------
-- Description --
-----------------
-- The algorithm will create a main path of a given length,
-- this main path will never intersect
-- it always goes down, left or right and never backwards.

-- On this path, rooms of different size will be created.
-- These rooms are always smaller than their container (cell).
-- In addition, the center of the cell containing the room is always
-- inside the room (it is useful to connect rooms with corridors).

-- Then there is a chance to create a corridor between 
-- the current room and the previous one or merge with it.

-- A second algorithm will try to dig a secondary path
-- starting with a room on the main path.

-- This secondary path can go in any direction
-- but can't directly connect to the main path
-- and can't intersect with another secondary room.

-- The result is that the main path is the shortest path
-- to finish the game from the start room to the end room.

-- There are also at least two bosses in the main path.
-- Player should be free to explore the dungeon but has
-- to meet at least two bosses.
-----------------------------------------------
-- prefixes

-- ar_ --> table only used as an 1D array
-- grid_ --> table only used as an 2D array
-- dict_ --> table only used as a dictionary
-- str_ --> variable only used as a string
-- nbr_ --> variable only used as a number 
-- tbl --> variable only used as a table
-- is_ --> variable only used as a bool
-- can_ --> variable only used as a bool

-- suffix

-- _h --> means _height
-- _w --> means _width
-- _u --> means _up
-- _d --> means _down
-- _l --> means _left
-- _r --> means _right
-- _pos --> means _position (2d vector)
-- _rnd --> means _random

-- other
-- pt --> point

------------------------------------------------------------------

-----------
-- Notes --
-----------
-- Sometimes there is no prefixes or suffix if it is obvious (e.g: grid_w (grid_width) holds a number) 

-- The first table of grid is the height the second is the width
-- grid[height][width]

-- If the map is too big the software opening the map text
-- can create an offset (window is too small to show all the map), but the content is still generated correctly.