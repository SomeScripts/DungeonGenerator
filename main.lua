-----------------------
-- Dungeon Generator --
-----------------------

-----------------
-- How it works--
-----------------
-- enter "y" on the terminal and press enter to generate/play
-- enter "n" to quit

-- On Eclipse IDE maps is generated on the projects folder
-- On ZeroBrane Studio maps are created at \ZeroBraneStudio\myprograms
-- The name of the rendered file is generated_map.txt

------------------------------------------------------------------

require("generator")

local nbr_seed = 1
local is_first_play = true
local str_separator = "_________________________________________________"
local can_play = true

function new_seed()
    nbr_seed = nbr_seed + 1
    math.randomseed(nbr_seed)
    print(str_separator)
    print(" ")

    -- Reset variables --
    grid_text = {}
    grid_info = {}
    origin_pos_info = Vector:new{x = 1, y = 1}
    origin_pos_text = Vector:new{x = 1, y = 1}
    ar_main_path_rooms_pos = {}  

    init_grid(grid_text, str_space, grid_w, grid_h)
    init_grid(grid_info, str_empty, nbr_cells_horizontal, nbr_cells_vertical)

    main_path_digger(main_path_length)

    if is_secondary_path then
        secondary_path_digger(ar_main_path_rooms_pos) 
    end

    create_bosses()
    grid_print(grid_text)

    -- Validation --
    print(str_separator)
    print(" ")
    print("Validation: Map was created at generated_map.txt!")
    print("Zoom out on the text file to see the whole dungeon!")
    print(" ")
    print("On Eclipse IDE maps is generated on the projects folder --> generated_map.txt")
    print("In Zerobrane the path is ZeroBraneStudio --> myprograms --> generated_map.txt")  
end

-- Game loop --
while can_play ~= false do
    print(str_separator)

    if is_first_play then
        print ("New game: [y|n]")
    else
        print ("Continue: [y|n]")
    end

    local result = io.read()  

    if result == "y" then
        new_seed()
        is_first_play = false
    elseif result == "n" then
        print(str_separator)
        print("End of game")
        print(str_separator)
        can_play = false
    else
        print(str_separator)
        print("Only 'y' or 'n' is a valid input.")
    end
end



