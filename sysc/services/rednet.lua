local service = {
    description = "RedNet Service for sysc",
}

local running = false
local function start()
    running = true
end

local function stop()
    running = false
end

local function status()

end



return service