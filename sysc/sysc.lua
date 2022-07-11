local lip = require("libs.lip")

local services = {}

local function resolveName(name)
    return (name:match("^(%w+)[.service]?$"))
end

local function resolvePathName(name)
    return resolveName(name) .. ".service"
end

local function getService(name)
    if fs.exists("sysc/services/" + name) then
        return lip.load("sysc/services/" + name)
    end
    return nil
end

local function start(name)

end

local function stop(name)

end

local function kill(name)

end

local function status(name)

end

local function enable(name)
    if services[name] then
        
    end
end

local function disable(name)

end

while true do
    local _, id, command, name = os.pullEventRaw("sysc")
end