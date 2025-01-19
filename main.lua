print("Loading")
local util = require("api\\utils")
local cfg = require("config")
-- CMDS -------------------------------------------------------------------------------------
local function clear(args)
    util.clear()
end
local function ls(args)
    local lst = util.getkeys(util.getNestValue(util.files, util.curdir))
    if util.has_value(args, "-l") then
        print("total " .. #lst)
        for n=1,#lst do
            print("-rw-r--r--    1 root     root           114 Jul  5  2020 " .. lst[n])
        end
    else
        print(table.concat(lst, " "))
    end
end
local function cd(args)
    if #args < 2 then
        print("sh: cd: missing argument")
        return
    end

    local target_dir = args[2]

    if target_dir == ".." then
        if #util.curdir > 0 then
            table.remove(util.curdir)  -- Remove the last directory in the path
        else
            print("sh: cd: already at root")
        end
        return
    end

    local lst = util.getkeys(util.getNestValue(util.files, util.curdir))
    if util.has_value(lst, target_dir) then
        table.insert(util.curdir, target_dir)  -- Add the target directory to the current path
    else
        print("sh: cd: can't cd to " .. target_dir .. ": No such file or directory")
    end
end
local function shutdown(args)
    if args[2] == "now" then
        util.clear()
        print("Broadcast message from root@wks01 (pts/0) (Sat Apr 21 02:26:30 2012):\n\n\nDevelopment server is going down for maintenance. Please save your work ASAP. \nThe system is going DOWN for system halt now!\n")
        os.exit()
    end
    print("System has not been booted with systemd as init system (PID 1). Can't operate.")
end
-- DATA -------------------------------------------------------------------------------------
local commands = {{["clear"] = clear, ["ls"] = ls, ["cd"] = cd, ["shutdown"] = shutdown}}
local idle_cmd = {"touch", "bg", "break", "continue", "return"}
local aliases = {["poweroff"] = {"shutdown", "now"}, ["compgen"] = {"help"}}
local function alias(args)
    if #args < 2 then
        print("Invalid alias format. Use: alias name=value")
        return
    end

    local alias_name = args[1]
    local alias_value = table.concat(args, " ", 2)  -- Join the rest of the args starting from index 2
    local zxx = util.mysplit(alias_value, "=")

    if #zxx == 2 then  -- Ensure there are two parts for alias
        aliases[alias_name] = util.mysplit(zxx[2]:gsub("'", ""), " ")  -- Store the alias directly in the aliases table
    else
        print("Invalid alias format. Use: alias name=value")
    end
end




commands = util.TableConcat(commands, {{["alias"] = alias}})
local plugins = util.rawScandir(cfg.basedir .. "plugins")
for i=1,#plugins do
    local plugin = require(cfg.basedir .. "plugins\\" .. util.mysplit(plugins[i], ".")[1])
    commands = util.TableConcat(commands, {plugin.commands})
    idle_cmd = util.TableConcat(idle_cmd, plugin.idle_cmd)
    aliases = util.TableConcat(aliases, {plugin.aliases})
end
local function dummy()
    return
end

local function find_cmd(args)
    if args[1] == "lualnx" then
        if args[2] == "package" then
            if args[3] == "list" then
                print(table.concat(plugins, ", "))
            end
        elseif args[2] == "help" then
            print("  LuaLnx info app\n\n- lualnx package list\n    List installed packages\n- lualnx debug\n    Debug the current LuaLinux state\n- lualnx compatibility\n    LuaLinux % of supported cmds")
        elseif args[2] == "debug" then
            print("-- aliases: " .. util.serializeTable(aliases))
            print("-- commands: " .. util.serializeTable(commands))
            print("-- idle_cmd: " .. util.serializeTable(idle_cmd))
        elseif args[2] == "compatibility" then
            print("Testing the compatibility...")
            local total = 0
            local success = 0
            local reqcmds = {"alias", "bg", "bind", "break", "cd", "compgen", "complete", "continue", "declare", "dirs", "echo", "enable", "eval", "exec", "exit", "export", "fc", "fg", "getopts", "hash", "help", "history", "jobs", "kill", "let", "local", "logout", "ls", "mapfile", "popd", "pushd", "pwd", "read", "readonly", "return", "set", "shift", "shopt", "source", "suspend", "test", "times", "trap", "type", "typeset", "ulimit", "umask", "unalias", "unset", "wait"}
            for i=1,#reqcmds do
                total = total + 1
                if util.has_value_l(commands, reqcmds[i]) or util.has_value_l(idle_cmd, reqcmds[i]) or util.has_value_l(aliases, reqcmds[i]) then
                    success = success + 1
                    print(reqcmds[i] .. ": SUCCESS")
                else
                    print(reqcmds[i] .. ": FAILED")
                end
            end
            print("Succesed: " .. tostring(success))
            print("Failed: " .. tostring(total - success))
            print("Total: " .. tostring(util.percentage(success, total, 100)) .. "%")
        end
        return dummy
    end
    -- Check if the command exists in the commands table
    for i=1,#commands do
        local cmdlst = commands[i]
        local cmd = cmdlst[args[1]]
        if cmd ~= nil then
            return cmd(args)  -- Execute the command with the original args
        end
    end

    -- Check if the command exists in the aliases table
    local alias_cmd = aliases[args[1]]
    if alias_cmd then
        local artmp = util.TableConcat({}, args)
        table.remove(artmp, 1)  -- Remove the alias name from args
        local rargs = util.TableConcat(alias_cmd, artmp)  -- Concatenate alias args with remaining args
        return find_cmd(rargs)  -- Recursively find and execute the command
    end



    -- Handle the help command
    if args[1] == "help" then
        local cmds = {}
        for i=1,#commands do
            cmds = util.TableConcat(cmds, util.getkeys(commands[i]))
        end
        table.sort(cmds, function(a, b) return a:lower() < b:lower() end)
        print(table.concat(cmds, " "))
        return dummy
    end

    -- If command is not found, print an error message
    if not util.has_value(idle_cmd, args[1]) then
        print("sh: " .. args[1] .. ": not found")
    end
    return dummy
end

-- ENDD -------------------------------------------------------------------------------------

util.clear()
print("Welcome to LuaLinux")
print("To read what you can do, write 'lualnx help'\n")

while true do
    io.write("localhost:" .. util.genpath(util.curdir) .. "# ")
    local input = io.read()
    if input ~= "" then
        local args = util.mysplit(input, " ")
        local cmd = commands[args[1]]  -- Changed args[0] to args[1] for correct indexing
        find_cmd(args)
    end
end
