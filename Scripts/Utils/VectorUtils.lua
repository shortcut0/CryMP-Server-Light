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
Vector = {
    __type = { "vector" }
}

-- ======================================
Vector.New = function(x, y, z)
    error("implementation missing. for raw vectors, use NewVec()")
end

-- ======================================
Vector.NewVec = function(x, y, z)
    return { x = (x or 0), y = (y or 0), z = (z or 0) }
end

-- ======================================
Vector.Empty = function()
    return Vector.NewVec() -- ?? Que paso aqui
end

-- ======================================
Vector.ToString = function(vec, pretty_print)
    local t = ("{x=%f,y=%f,z=%f}")
    if (pretty_print) then
        t = ("{ x = %0.6f, y = %0.6f, z = %0.6f }")
    end
    return t:format(vec.x, vec.y, vec.z)
end

-- ======================================
Vector.Up = function()
    return { x = 0, y = 0, z = 1}
end

-- ======================================
Vector.Down = function()
    return { x = 0, y = 0, z = -1}
end

-- ======================================
Vector.Copy = function(vec_a)
    return { x = vec_a.x, y = vec_a.y, z = vec_a.z }
end

-- ======================================
Vector.IsVecAny = function(vec)
    return (Vector.Is3D(vec) or Vector.Is2D(vec) or Vector.Is1D(vec))
end

-- ======================================
Vector.Is3D = function(vec)
    return (table.Size(vec) == 3 and vec.x and vec.y and vec.z)
end

-- ======================================
Vector.Is2D = function(vec)
    return (table.Size(vec) == 2 and vec.x and vec.y)
end

-- ======================================
Vector.Is1D = function(vec)
    return (table.Size(vec) == 1 and vec.x)
end

-- ======================================
Vector.Direction = function(source, target, normalize, scale)
    if (normalize == nil) then normalize = 1 end
    if (scale == nil) then scale = 1 end

    -- for direction from source to target, we need to subtract source from target
    local direction = Vector.Sub(target, source)
    local in_place = true
    if (normalize) then
        Vector.Normalize(direction, in_place)
    end
    if (scale) then
        Vector.Scale(direction, scale, in_place)
    end
    return direction
end

-- ======================================
Vector.Normalize = function(vec, in_place)
    local len = Vector.Length(vec)
    if (len == 0) then
        return vec
    end

    if (in_place) then
        vec.x, vec.y, vec.z =
        vec.x / len, vec.y / len, vec.z / len
        return vec
    end

    return {
        x = vec.x / len,
        y = vec.y / len,
        z = vec.z / len
    }
end


-- ======================================
Vector.Length = function(vec)
    local x = (vec.x)
    local y = (vec.y)
    local z = (vec.z)
    return math.sqrt(x * x + y * y + z * z)
end

-- ======================================
Vector.Length2D = function(vec)
    local x = (vec.x)
    local y = (vec.y)
    return math.sqrt(x * x + y * y)
end

-- ======================================
Vector.Length1D = function(vec)
    local x = (vec.x)
    local y = (vec.y)
    return math.sqrt(x * x)
end

-- ======================================
Vector.LengthZ = function(vec)
    local z = (vec.z)
    return math.sqrt(z * z)
end

-- ======================================
Vector.Distance3d = function(vec_a, vec_b)
    local x = (vec_a.x - vec_b.x)
    local y = (vec_a.y - vec_b.y)
    local z = (vec_a.z - vec_b.z)
    return math.sqrt(x * x + y * y + z * z)
end

-- ======================================
Vector.Distance2d = function(vec_a, vec_b)
    local x = (vec_a.x - vec_b.x)
    local y = (vec_a.y - vec_b.y)
    return math.sqrt(x * x + y * y)
end

-- ======================================
Vector.Distance1d = function(vec_a, vec_b)
    local x = (vec_a.x - vec_b.x)
    return math.sqrt(x * x)
end

-- ======================================
Vector.DistanceZ = function(vec_a, vec_b)
    local z = (vec_a.z - vec_b.z)
    return math.sqrt(z * z)
end

-- ======================================
Vector.Align3D_100 = function(vec_a, vec_b)
    -- 0<=>100
    return (Vector.Align3D(vec_a, vec_b) + 1) / 2
end

-- ======================================
Vector.Align3D = function(vec_a, vec_b)
    -- Compute lengths (magnitudes)
    local a_len = Vector.Length(vec_a)
    local b_len = Vector.Length(vec_b)

    -- Avoid division by zero
    if (a_len == 0 or b_len == 0) then
        return 0
    end

    -- Normalize vectors
    local ax, ay, az = vec_a.x, vec_a.y, vec_a.z
    local bx, by, bz = vec_b.x, vec_b.y, vec_b.z
    local nax, nay, naz = ax / a_len, ay / a_len, az / a_len
    local nbx, nby, nbz = bx / b_len, by / b_len, bz / b_len

    local dot = nax * nbx + nay * nby + naz * nbz

    if dot > 1 then dot = 1 end
    if dot < -1 then dot = -1 end

    -- -1<=>1
    return dot
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
Vector.Negative = function(vec_a, in_place)
    return Vector.Scale(vec_a, -1, in_place)
end

-- ======================================
Vector.NegativeInPlace = function(vec_a)
    return Vector.Scale(vec_a, -1, true)
end

-- ======================================
Vector.Add = function(vec_a, vec_b, in_place)
    if (in_place) then
        vec_a.x = vec_a.x + vec_b.x
        vec_a.y = vec_a.y + vec_b.y
        vec_a.z = vec_a.z + vec_b.z
        return vec_a
    end

    local vec_new = {}
    vec_new.x = vec_a.x + vec_b.x
    vec_new.y = vec_a.y + vec_b.y
    vec_new.z = vec_a.z + vec_b.z
    return vec_new
end

-- ======================================
Vector.Sub = function(vec_a, vec_b, in_place)
    if (in_place) then
        vec_a.x = vec_a.x - vec_b.x
        vec_a.y = vec_a.y - vec_b.y
        vec_a.z = vec_a.z - vec_b.z
        return vec_a
    end

    local vec_new = {}
    vec_new.x = vec_a.x - vec_b.x
    vec_new.y = vec_a.y - vec_b.y
    vec_new.z = vec_a.z - vec_b.z
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