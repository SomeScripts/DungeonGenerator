-- Load scripts
require("utils")

-- Load classes
require("vector")  
require("rectangle")
require("room")
-------------------
-- Init variables--
-------------------
grid_text = {}
grid_info = {}
origin_pos_info = Vector:new{x = 1, y = 1}
origin_pos_text = Vector:new{x = 1, y = 1}
ar_main_path_rooms_pos = {}
str_space = " "

local str_skip = "skip"
local str_stop = "stop"
local str_create = "create"
local str_wall = "#"
local str_floor = "."

local str_door = "+"
local str_empty = "empty"
local str_right = "right"
local str_left = "left"
local str_up = "up"
local str_down = "down"
local str_boss = "B"
local str_horizontal = "horizontal"
local str_vertical = "vertical"

------------------------
-- Designer variables --
------------------------
-- Path --
main_path_length = 6 -- Number of rooms (cells) from start room to end room
is_secondary_path = true -- If it is false there is only the main path.

-- Secondary path digger action 
-- to do when encounter a type of room
-- can have three actions:
-- str_stop or str_skip or str_create
-- str_skip will not create a room but will either merge or create a corridor
local str_action_encounter_main_path = str_stop 
local str_action_encounter_secondary_path = str_stop 

-- Size of a cell containing a room --
local cell_h = 10 -- height (between 7 and 50)
local cell_w = 20 -- width (7 between and 50)

-- Percent of chance --
-- Must be an int between 0 and 100.
local nbr_percent_chance_of_secondary_path = 70 -- For each main room: % of chance of trying to create a secondary path
local nbr_percent_of_chance_of_corridor_instead_of_merge = 50

-- Random number between secondary_path_min_length and secondary_path_max_length
-- This random number will determine the maximum length of secondary path
local secondary_path_min_length = 40 -- between 0 and 200
local secondary_path_max_length = 80 -- between 0 and 200

-- Just here for initialisation
nbr_cells_horizontal = 10
nbr_cells_vertical = 10

grid_h = cell_h * nbr_cells_vertical 
grid_w = cell_w * nbr_cells_horizontal

--clamp(main_path_length,1, 100)
clamp(main_path_length, 6, 100)
clamp(cell_h, 7, 50)
clamp(cell_w, 7, 50)
clamp(nbr_percent_chance_of_secondary_path, 0, 100)
clamp(nbr_percent_of_chance_of_corridor_instead_of_merge, 0, 100)
clamp(secondary_path_min_length, 0, 200)
clamp(secondary_path_max_length, 0, 200)
------------------------------------------------------------------
function init_grid(grid, b, width, height)
    for i = 1, height do
        grid[i] = {}

        for j = 1, width do
            grid[i][j] = b
        end
    end  
end

function grid_print(grid)
    local str_total = ""

    local yy = origin_pos_text:get_y()

    for i = yy, grid_h do
        local str_line = ""
        local xx = origin_pos_text:get_x()

        for j = xx, grid_w do
            str_line = str_line .. grid[i][j]
        end

        str_total = str_total .. str_line .. "\n"
    end
    
    file = io.open("generated_map.txt", "w")
    file:write(str_total)
    file:close()
end

------------------------------------------------------------------
function generate_room(cell_pos, center_x, center_y)
    local rect_room = Rectangle:new{}
    local offset = 1
    local margin_w = 3
    local margin_h = 3

    -- Security: can't be bigger then the half of a cell
    margin_w = math.min( math.floor(cell_w / 2) , margin_w)
    margin_h = math.min( math.floor(cell_h / 2), margin_h)

    -- Add diferent size to rooms

    -- Left and right variations
    local rnd_nbr = math.random(2)

    local rnd_left_x = cell_w * (cell_pos.x - 1) -- default value
    local rnd_right_x = cell_w * cell_pos.x -- default value

    if rnd_nbr == 1 then
        rnd_left_x = math.random(rnd_left_x, center_x - margin_w)        
    elseif rnd_nbr == 2 then
        rnd_right_x = math.random(center_x + margin_w, rnd_right_x)        
    end

    -- Top and bottom variations
    local rnd_nbr_2 = math.random(2)

    local rnd_top_y = cell_h * (cell_pos.y - 1) -- default value
    local rnd_bottom_y = cell_h * cell_pos.y -- default value

    if rnd_nbr_2 == 1 then
        rnd_top_y = math.random(rnd_top_y, center_y - margin_h)
    elseif rnd_nbr == 2 then
        rnd_bottom_y = math.random(center_y + margin_h, rnd_bottom_y)
    end

    local top_l_pos = Vector:new{x = rnd_left_x  + offset, y =  rnd_top_y + offset}
    local top_r_pos = Vector:new{x =  rnd_right_x, y = rnd_top_y + offset}
    local bottom_r_pos = Vector:new{x = rnd_right_x, y = rnd_bottom_y}
    local bottom_l_pos = Vector:new{x = rnd_left_x + offset, y = rnd_bottom_y}

    rect_room:set_top_l(top_l_pos)
    rect_room:set_top_r(top_r_pos)
    rect_room:set_bottom_r(bottom_r_pos)
    rect_room:set_bottom_l(bottom_l_pos)

    local left_x = rect_room:get_top_l().x
    local right_x = rect_room:get_top_r().x
    local top_y = rect_room:get_top_l().y
    local bottom_y = rect_room:get_bottom_l().y

    -- Add room to grid_text
    local yy = origin_pos_text:get_y()
    local xx = origin_pos_text:get_x()

    for i = yy, grid_h do    
        for j = xx, grid_w do
            if (j > left_x) and (j < right_x) and (i > top_y) and (i < bottom_y) then
                if (i == (top_y + 1)) or (i == (bottom_y - 1)) or (j == (left_x + 1)) or  (j == (right_x - 1)) then
                    grid_text[i][j] = str_wall
                else
                    grid_text[i][j] = str_floor
                end
            end
        end
    end
    return rect_room:get_points()
end

function calculate_center(x, y)--> return vector
    local center_x = math.ceil( ( (x - 1) * cell_w) + cell_w / 2)
    local center_y = math.ceil( ( (y - 1) * cell_h) + cell_h / 2)
    local c_pos = Vector:new{x = center_x, y = center_y}
    return c_pos
end

function calculate_new_position(current_cell_pos, dir) --> return vector
    if dir == str_left then
        current_cell_pos.x = current_cell_pos.x - 1
    elseif dir == str_right then
        current_cell_pos.x = current_cell_pos.x + 1    
    elseif dir == str_down then
        current_cell_pos.y = current_cell_pos.y + 1    
    elseif dir == str_up then
        current_cell_pos.y = current_cell_pos.y - 1
    end
    return current_cell_pos
end

function add_row(grid, dir, origin_pos, height, width)
    local str

    if grid == grid_info then
        str = str_empty
    else
        str = str_space-- for debug = "@"
    end

    if dir == str_left then
        origin_pos.x = origin_pos.x - 1

        local yy = origin_pos:get_y()

        for i = yy, height do
            grid[i][origin_pos.x] = str       
        end

    elseif dir == str_right then
        width = width + 1
        local yy = origin_pos:get_y()

        for i = yy, height do
            grid[i][width] = str       
        end   

    elseif dir == str_up then
        origin_pos.y = origin_pos.y - 1
        grid[origin_pos.y] = {}  
        local xx = origin_pos:get_x()

        for i = xx, width do
            grid[origin_pos.y][i] = str        
        end     

    elseif dir == str_down then 

        height = height + 1

        grid[height] = {}    

        local xx = origin_pos:get_x()

        for i = xx, width do
            grid[height][i] = str       
        end 
    end

    if grid == grid_info then
        nbr_cells_horizontal = width
        nbr_cells_vertical = height    
    elseif grid == grid_text then
        grid_h = height
        grid_w = width    
    end
end

function text_add_row(string_1, string_2, nbr_iterations, dir)
    if (dir == string_1) or (dir == string_2) then
        for h = 1, nbr_iterations do      
            add_row(grid_text, dir, origin_pos_text, grid_h, grid_w)
        end
    end
end

function get_cells_alignment(center_1, center_2) --> return string
    local dir = " "

    if center_1:get_x() == center_2:get_x() then
        dir = "vertical"        
        return dir
    elseif center_1:get_y() == center_2:get_y() then
        dir = "horizontal"        
        return dir
    else
        print("Error: the two cells should have either x or y in common")
    end
end

function create_corridors(current_cell_pos, previous_pos)
    local center_1 = grid_info[current_cell_pos.y][current_cell_pos.x].center_pos
    local center_2 = grid_info[previous_pos.y][previous_pos.x].center_pos

    local dir = get_cells_alignment(center_1, center_2)

    if dir == "horizontal" then    
        local x_1 = center_1:get_x()
        local x_2 = center_2:get_x()

        local begin_x = math.min(x_1, x_2)
        local end_x = math.max(x_1, x_2)

        local y = center_2:get_y()

        for x = begin_x, end_x do
            -- Corridor walls
            if grid_text[y - 1][x] == str_space then
                grid_text[y - 1][x] = str_wall
            end
            if grid_text[y + 1][x] == str_space then
                grid_text[y + 1][x] = str_wall
            end
            -- Floor and door
            if (grid_text[y][x] == str_wall) or (grid_text[y][x] == str_door) then
                grid_text[y][x] = str_door
            else
                grid_text[y][x] = str_floor
            end
        end

    elseif dir == "vertical" then

        local y_1 = center_1:get_y()
        local y_2 = center_2:get_y()

        local begin_y = math.min(y_1, y_2)
        local end_y = math.max(y_1, y_2)

        local x = center_2:get_x()

        for y = begin_y, end_y do
            -- Corridor walls
            if grid_text[y][x - 1] == str_space then
                grid_text[y][x - 1] = str_wall
            end
            if grid_text[y][x + 1] == str_space then
                grid_text[y][x + 1] = str_wall
            end

            -- Floor and door
            if (grid_text[y][x] == str_wall) or (grid_text[y][x] == str_door) then
                grid_text[y][x] = str_door
            else
                grid_text[y][x] = str_floor
            end
        end
    end  
end

function merge_rooms(current_cell_pos, previous_pos)
    local center_1 = grid_info[current_cell_pos.y][current_cell_pos.x].center_pos
    local center_2 = grid_info[previous_pos.y][previous_pos.x].center_pos
    local rect_points_1 =  grid_info[current_cell_pos.y][current_cell_pos.x].ar_rect_points
    local rect_points_2 = grid_info[previous_pos.y][previous_pos.x].ar_rect_points

    local dir = get_cells_alignment(center_1, center_2)  

    -- For more clarity there is no function to synthesize the horizontal and vertical
    if dir == "horizontal" then    
        local begin_x, end_x, begin_y, end_y, pt_top_l_y_r, pt_bottom_y_r
        local offset = 1

        -- Start to connect with the left rectangle to the right rectangle
        -- In code represented by _l and _r at the end of variable
        -- Example: pt_top_l_y_r = point_top_left_y_right 
        -- top_left = position of the point in the rectangle, _right = right rectangle

        local function calculate(rect_pt_l, rect_pt_r)
            begin_x = rect_pt_l[2]:get_x() - offset
            end_x = rect_pt_r[1]:get_x() + offset       
            pt_top_l_y_r = rect_pt_r[1]:get_y()
            pt_bottom_y_r = rect_pt_r[4]:get_y()            
            begin_y = rect_pt_l[1]:get_y() + offset
            end_y = rect_pt_l[4]:get_y() - offset
        end

        if center_1:get_x() < center_2:get_x() then
            -- Rect 1 left and rect 2 right
            calculate(rect_points_1, rect_points_2)
        else
            -- Rect 2 left and rect 1 right
            calculate(rect_points_2, rect_points_1)
        end

        -- Merge
        for x = begin_x, end_x do
            for y = begin_y, end_y do
                if (y > begin_y) and (y < end_y) then   
                    grid_text[y][x] = str_floor 
                else
                    grid_text[y][x] = str_wall
                end
            end
        end   

        -- Connect missing walls
        for y = begin_y + offset, end_y do
            if y <= (pt_top_l_y_r + 1)then
                grid_text[y][end_x] = str_wall
            end
            if y >= (pt_bottom_y_r - 1) then
                grid_text[y][end_x] = str_wall
            end
        end

    elseif dir == "vertical" then
        local begin_y, end_y, begin_x, end_x, pt_top_l_x_d, pt_top_r_x_d
        local offset = 1

        -- Start to connect with the up rectangle to the down rectangle
        -- In code represented by _u and _d at the end of variable
        -- Example: pt_top_r_x_d = point_top_right_x_down
        -- top_right = position of the point in the rectangle, _down = down rectangle

        local function calculate(rect_pt_u, rect_pt_d)
            begin_y = rect_pt_u[4]:get_y() - offset -- offset
            end_y = rect_pt_d[1]:get_y() + offset       
            pt_top_l_x_d = rect_pt_d[1]:get_x()
            pt_top_r_x_d = rect_pt_d[2]:get_x()            
            begin_x = rect_pt_u[1]:get_x() + offset
            end_x = rect_pt_u[2]:get_x() - offset      
        end

        if center_1:get_y() < center_2:get_y() then
            -- Rect 1 up and rect 2 down
            calculate(rect_points_1, rect_points_2)
        else
            -- Rect 2 up and rect 1 down
            calculate(rect_points_2, rect_points_1)
        end

        -- Merge
        for x = begin_x, end_x do
            for y = begin_y, end_y do

                if (x > begin_x) and (x < end_x) then   
                    grid_text[y][x] = str_floor 
                else
                    grid_text[y][x] = str_wall
                end
            end
        end   

        -- Connect missing walls
        for x = begin_x + offset, end_x do
            if x <= (pt_top_l_x_d + 1)then
                grid_text[end_y][x] = str_wall
            end
            if x >= (pt_top_r_x_d - 1) then
                grid_text[end_y][x] = str_wall
            end
        end
    end
end

function extend_world_map(cell_pos, _direction)
    -- Extend world map if new cell is out of bounds --
    local test_1 = cell_pos.x < origin_pos_info.x
    local test_2 = cell_pos.x > nbr_cells_horizontal
    local test_3 = cell_pos.y < origin_pos_info.y
    local test_4 = cell_pos.y > nbr_cells_vertical    

    if test_1 or test_2 or test_3 or test_4 then
        -- Add new rows --
        add_row(grid_info, _direction, origin_pos_info, nbr_cells_vertical, nbr_cells_horizontal)
        text_add_row(str_left, str_right, cell_w, _direction)
        text_add_row(str_up, str_down, cell_h, _direction)
    end   
end

function main_path_digger(main_path_length)

    local function main_choose_direction(direction) --> return string
        -- choose a direction by never going up
        -- and never go backwards
        if (direction == str_left) or (direction == str_right) then
            local nbr_rnd = math.random(2)

            if nbr_rnd == 1 then
                if direction == str_left then
                    return str_left
                else
                    return str_right
                end
            elseif nbr_rnd == 2 then
                return str_down
            end    
    
        else -- direction = down
            local nbr_rnd = math.random(6)
    
            if nbr_rnd <= 3 then
                return str_left
            elseif nbr_rnd <= 5 then
                return str_right
            else
                return str_down
            end
        end
    end  
    
    local direction = str_down
    local current_cell_pos = Vector:new{x = 1, y = 1}
    local previous_pos = Vector:new{x = 0, y = 0}
    local c_pos = calculate_center(current_cell_pos.x, current_cell_pos.y) 

    -- First Room
    -- Add main path rooms positions to an array to get them later for creating secondary paths
    local current_pos = Vector:new{x = current_cell_pos:get_x(), y = current_cell_pos:get_y()}    
    table.insert(ar_main_path_rooms_pos, current_pos)    

    local points = generate_room(current_cell_pos, c_pos:get_x(), c_pos:get_y())
    local copy_points = table_duplicate(points)

    grid_info[current_cell_pos.y][current_cell_pos.x] = Room:new{
        center_pos = c_pos,
        is_in_main_road = true,
        ar_rect_points = copy_points,
    }  

    for i = 2, main_path_length do    
        -- Stock variables --
        previous_pos.x = current_cell_pos:get_x()
        previous_pos.y = current_cell_pos:get_y()

        direction = main_choose_direction(direction)

        current_cell_pos = calculate_new_position(current_cell_pos, direction)

        c_pos = calculate_center(current_cell_pos.x, current_cell_pos.y) 

        extend_world_map(current_cell_pos, direction)

        points = generate_room(current_cell_pos, c_pos:get_x(), c_pos:get_y())
        local copy_points = table_duplicate(points)

        -- Add main path rooms positions to an array to get them later for creating secondary paths
        local current_pos = Vector:new{x = current_cell_pos:get_x(), y = current_cell_pos:get_y()}    
        table.insert(ar_main_path_rooms_pos, current_pos)

        grid_info[current_cell_pos.y][current_cell_pos.x] = Room:new{
            center_pos = c_pos,
            is_in_main_road = true,
            ar_rect_points = copy_points,
        }                      
        local rnd_nbr = math.random(100)

        if rnd_nbr <= nbr_percent_of_chance_of_corridor_instead_of_merge then
            create_corridors(current_cell_pos, previous_pos)
        else
            merge_rooms(current_cell_pos, previous_pos)      
        end
    end
end

function secondary_path_digger(array)
    local function secondary_choose_direction(dir) --> return string
        local function choose_dir(ar_dir) --> return string
            local rnd_nbr = math.random(1, #ar_dir)
            local rnd_dir = ar_dir[rnd_nbr]      
            return rnd_dir
        end  
        -- Choose a direction by never going backwards
        local ar_dir = {str_left, str_right, str_up, str_down}
        local rnd_dir = choose_dir(ar_dir)

        while rnd_dir == dir do
            rnd_dir = choose_dir(ar_dir)
        end

        return rnd_dir
    end

    local function check_if_can_digg_secondary_path(cell_x, cell_y) --> return bool
        if (grid_info[cell_y] ~= nil) and (grid_info[cell_y][cell_x] ~= nil) then 
            local cell_info = grid_info[cell_y][cell_x]  

            if cell_info == str_empty then
                return str_create
            else
                if cell_info.is_in_main_road == true then
                    return str_action_encounter_main_path
                else
                    return str_action_encounter_secondary_path
                end
            end
    else
        return str_create
    end
    end  

    local function create_secondary_path(main_path_start_pos, cell_pos, dir)
        local can_dig = check_if_can_digg_secondary_path(cell_pos.x, cell_pos.y)

        if can_dig == str_stop then 
            return
        end  

        local nbr_rnd_secondary_length = math.random(secondary_path_min_length, secondary_path_max_length)

        if secondary_path_min_length > secondary_path_max_length then
            print("Error: Secondary path min length is bigger than max length")
        end

        local current_cell_pos = cell_pos
        local previous_pos = Vector:new{x = main_path_start_pos:get_x(), y = main_path_start_pos:get_y()}  

        if can_dig ~= str_skip then
            local c_pos = calculate_center(current_cell_pos.x, current_cell_pos.y) 

            -- First Room
            extend_world_map(current_cell_pos, dir)

            local points = generate_room(current_cell_pos, c_pos:get_x(), c_pos:get_y())
            local copy_points = table_duplicate(points)    

            grid_info[current_cell_pos.y][current_cell_pos.x] = Room:new{
                center_pos = c_pos,
                is_in_main_road = false,
                ar_rect_points = copy_points,
            }    

            create_corridors(current_cell_pos, previous_pos)
        end

        for w = 2, nbr_rnd_secondary_length do    
            -- Stock variables --
            previous_pos.x = current_cell_pos:get_x()
            previous_pos.y = current_cell_pos:get_y()   

            dir = secondary_choose_direction(dir)

            current_cell_pos = calculate_new_position(current_cell_pos, dir)  

            can_dig = check_if_can_digg_secondary_path(current_cell_pos.x, current_cell_pos.y)

            if can_dig == str_stop then
                math.randomseed(w)
            elseif can_dig ~= str_skip then
                c_pos = calculate_center(current_cell_pos.x, current_cell_pos.y)

                extend_world_map(current_cell_pos, dir)

                points = generate_room(current_cell_pos, c_pos:get_x(), c_pos:get_y())
                local copy_points = table_duplicate(points)   

                grid_info[current_cell_pos.y][current_cell_pos.x] = Room:new{
                    center_pos = c_pos,
                    is_in_main_road = false,
                    ar_rect_points = copy_points,      
                }                            
            end

            if can_dig ~= str_stop then

                local rnd_nbr = math.random(100)

                if rnd_nbr <= nbr_percent_of_chance_of_corridor_instead_of_merge then
                    create_corridors(current_cell_pos, previous_pos)
                else
                    merge_rooms(current_cell_pos, previous_pos)      
                end 
            end
        end   
    end

    -- Create or connect secondary path 
    for i = 1, #array do
        local rnd_nbr = math.random(100)
        if rnd_nbr <= nbr_percent_chance_of_secondary_path  then

            local room_pos = array[i]

            local cell_l = Vector:new{x = room_pos:get_x() - 1, y = room_pos:get_y()}
            local cell_r = Vector:new{x = room_pos:get_x() + 1, y = room_pos:get_y()}
            local cell_u = Vector:new{x = room_pos:get_x(), y = room_pos:get_y() - 1}
            local cell_d = Vector:new{x = room_pos:get_x(), y = room_pos:get_y() + 1}

            local dict_cells = {
                {cell = cell_l, dir = str_left},
                {cell = cell_r, dir = str_right},
                {cell = cell_u, dir = str_up},
                {cell = cell_d, dir = str_down}
            }

            for z = 1, #dict_cells do
                local dir = dict_cells[z]["dir"]
                local cell_pos = dict_cells[z]["cell"]
                local cell_x = cell_pos:get_x()
                local cell_y = cell_pos:get_y()

                create_secondary_path(room_pos, cell_pos, dir) 
            end
        end
    end
end

function create_bosses(info)
    -- Create at least 2 boss
    math.randomseed(1)
    local nbr_boss = math.random(2,4)
    local nbr_step = math.floor((main_path_length - 1) / 5)
    local step_count = nbr_step 

    for i = 1, nbr_boss do
        local room_pos = ar_main_path_rooms_pos[step_count]
        local rect_points = grid_info[room_pos.y][room_pos.x].ar_rect_points

        local x_l = rect_points[1]:get_x()
        local x_r = rect_points[2]:get_x() 
        local y_u = rect_points[1]:get_y()
        local y_d = rect_points[4]:get_y()

        new_center_x = math.floor(x_l + ((x_r- x_l) / 2) )
        new_center_y = math.floor(y_u + ((y_d -y_u) / 2) )

        grid_text[new_center_y][new_center_x] = str_boss

        step_count = step_count + nbr_step
    end
end