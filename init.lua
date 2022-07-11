local osRun = os.run
local osShutdown = os.shutdown

function os.run() -- avoid calling at line 988 bios.lua
    os.run = osRun
end

-- at the end of bios.lua this function is executed
function os.shutdown()
    os.shutdown = osShutdown
    local ok, err = pcall(parallel.waitForAny, function()
        local sShell
        if term.isColour() and settings.get("bios.use_multishell") then
            sShell = "rom/programs/advanced/multishell.lua"
        else
            sShell = "rom/programs/shell.lua"
        end
        os.run({ shell = shell }, sShell)
        os.run({}, "rom/programs/shutdown.lua")
    end, function()
        if fs.exists("sysc/sysc.lua") then
            os.run({}, "sysc/sysc.lua")
        else
            while true do
                coroutine.yield("-")
            end
        end
    end)
    -- If the shell errored, let the user read it.
    term.redirect(term.native())
    if not ok then
        printError(err)
        pcall(function()
            term.setCursorBlink(false)
            print("Press any key to continue")
            os.pullEvent("key")
        end)
    end

    -- End
    os.shutdown()
end

debug.setupvalue(rednet.run, 1, false) -- set "started" to off
shell.exit() -- exit shell at line 987 bios.lua
