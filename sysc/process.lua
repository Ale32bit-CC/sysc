local expect = require("cc.expect").expect

local process = {}
local threads = {}

function process.spawn(path, env)
    expect(1, path, "string")
    expect(2, env, "table", "nil")

    if not fs.exists(path) then
        return false, "file not found"
    end

    local pid = #threads + 1
    env = env or _ENV
    setmetatable({
        pid = pid,
    }, {
        __index = env
    })
    local func, err = loadfile(path, env)
    if not func then
        return nil, err
    end

    local thread = coroutine.create(func)

    threads[pid] = {
        filter = nil,
        thread = thread,
        pendingKill = false,
        queue = {},
        parent = _ENV.pid or 1
    }

    return pid
end

function process.terminate(pid)
    expect(1, pid, "number")

    if not threads[pid] then
        return false, "process not found"
    end

    table.insert(threads[pid].queue, { "terminate" })

    return true
end

function process.kill(pid)
    expect(1, pid, "number")

    if not threads[pid] then
        return false, "process not found"
    end

    threads[pid].pendingKill = true

    return true
end

function process.emit(pid, event, ...)
    expect(1, pid, "number")
    expect(2, event, "string")

    if not threads[pid] then
        return false, "process not found"
    end

    table.insert(threads[pid].queue, table.pack(event, ...))

    return true
end

local running = false
function process.init()
    if running then
        error("Event loop already running", 2)
    end
    running = true

    local ev = {}
    while true do
        -- add event to queue
        for pid, proc in pairs(threads) do
            table.insert(proc.queue, ev)
        end

        for pid, proc in pairs(threads) do
            local event = table.remove(proc.queue, 1) or { n = 0 }
            if not proc.error and proc.filter == nil or proc.filter == event[1] or event[1] == "terminate" then
                local ok, par = coroutine.resume(proc.thread, table.unpack(event))

                if ok then
                    proc.filter = par
                else
                    proc.pendingKill = true
                    os.queueEvent("sysc_process_failure", pid, par, proc)
                end
            end

            if proc.pendingKill then
                os.queueEvent("sysc_process_exit", pid, threads[pid])
                threads[pid] = nil
            end
        end

        ev = table.pack(coroutine.yield())
    end
end

return process
