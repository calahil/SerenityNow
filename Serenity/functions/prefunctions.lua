--[[

	General functions that need to be defined before variables / defaults.
	
]]

if not Serenity then return end

--[[
	This function returns a deep copy of a given table.
	The function below also copies the metatable to the new table if there is one,
	so the behaviour of the copied table is the same as the original.
	*** But the 2 tables share the same metatable, you can avoid this by setting the
	"deepcopymeta" option to true to make a copy of the metatable, as well.
]]
function Serenity.DeepCopy(object, deepcopymeta)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local new_table = {}
        lookup_table[object] = new_table
        for index, value in pairs(object) do
            new_table[_copy(index)] = _copy(value)
        end
        return setmetatable(new_table, deepcopymeta and _copy(getmetatable(object)) or getmetatable(object))
    end
    return _copy(object)
end
