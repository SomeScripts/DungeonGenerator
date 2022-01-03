------------
-- Utilis --
------------
function print_vec(string, vector)
    print(string .. " = {" .. tostring(vector["x"]) .. ", " .. tostring(vector["y"]) .. "}")
end

function table_duplicate(original)
    local copy = {}

    for key, value in pairs(original) do
        copy[key] = value
    end
    return copy
end

function clamp(value, min, max) --> return nbr
    value = math.max(min, value)
    value = math.min(value, max)
    return value
end