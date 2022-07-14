local services = {}

local function resolveName(name)
    return (name:match("^(%w+)[.service]?$"))
end

local function resolvePathName(name)
    return resolveName(name) .. ".service"
end

local function getService(name)
    if fs.exists("sysc/services/" + name) then
        local func, err = loadfile("sysc/services/" + name)
        if not func then
            return nil, err
        end

        local ok, par = pcall(func)
        if not ok then
            return nil, par
        end

        return par
    end
    return nil, "service not found"
end

local function start(name)

end

local function stop(name)

end

local function kill(name)

end

local function reload(name)

end

local function status(name)

end

local function enable(name)
    if not services[name] then
        return
    end
end

local function disable(name)
    if services[name] then
        return
    end
end

local function daemonReload()
    local enabledServices = {}
    if fs.exists("sysc/enabled") then
        local f = fs.open("sysc/enabled", "r")
        enabledServices = textutils.unserialise(f.readAll())
        f.close()
    end

    for k, v in ipairs(enabledServices) do
        local name = resolveName(v)
        local path = resolvePathName(name)
        local service, err = getService(name)
        if service then
            if not services[name] then
                services[name] = service
            end
        end
    end
end

daemonReload()

while true do
    local _, id, command, name = os.pullEventRaw("sysc")
end
