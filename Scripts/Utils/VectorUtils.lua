-- ===================================================================================
--          ____            __  __ ____            ____                             --
--         / ___|_ __ _   _|  \/  |  _ \          / ___|  ___ _ ____   _____ _ __   --
--        | |   | '__| | | | |\/| | |_) |  _____  \___ \ / _ \ '__\ \ / / _ \ '__|  --
--        | |___| |  | |_| | |  | |  __/  |_____|  ___) |  __/ |   \ V /  __/ |     --
--         \____|_|   \__, |_|  |_|_|             |____/ \___|_|    \_/ \___|_|     --
--                    |___/          by: shortcut0                                  --
--                             Contains Vector utilities
-- ===================================================================================

---@class Vector
Vector = {}

-- ======================================
Vector.Empty = function()
    return { x = 0, y = 0, z = 0 }
end

-- ======================================
Vector.Up = function()
    return { x = 0, y = 0, z = 1}
end

-- ======================================
Vector.Copy = function(vec_a)
    return { x = vec_a.x, y = vec_a.y, z = vec_a.z }
end

-- ======================================
Vector.FastSum = function(vec_dest, vec_a, vec_b)
    vec_dest.x = vec_a.x + vec_b.x
    vec_dest.y = vec_a.y + vec_b.y
    vec_dest.z = vec_a.z + vec_b.z
end

-- ======================================
Vector.ScaleInPlace = function(vec_a, scale)
    return Vector.Scale(vec_a, scale, true)
end

-- ======================================
Vector.Scale = function(vec_a, scale, in_place)

    if (in_place) then
        vec_a.x = vec_a.x * scale
        vec_a.y = vec_a.y * scale
        vec_a.z = vec_a.z * scale
        return vec_a
    end

    local vec_new = {}
    vec_new.x = vec_a.x * scale
    vec_new.y = vec_a.y * scale
    vec_new.z = vec_a.z * scale
    return vec_new
end

-- ======================================
Vector.Modify = function(vec_a, key, value, set, in_place)

    if (in_place) then
        vec_a[key] = (set and 0 or vec_a[key]) + value
        return vec_a
    end

    local vec_new = Vector.Copy(vec_a)
    vec_new[key] = (set and 0 or vec_new[key]) + value
    return vec_new
end

-- ======================================
Vector.ModifyX = function(vec_a, value, set, in_place)
    return Vector.Modify(vec_a, "x", value, set, in_place)
end

-- ======================================
Vector.ModifyY = function(vec_a, value, set, in_place)
    return Vector.Modify(vec_a, "y", value, set, in_place)
end

-- ======================================
Vector.ModifyZ = function(vec_a, value, set, in_place)
    return Vector.Modify(vec_a, "z", value, set, in_place)
end