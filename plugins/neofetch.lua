local function neofetch(args)
    print([[
           =        =     @@@@    root@localhost
       =                 @@@@@@@  --------------
           @@@@@@@@@@    @@@@@@@  OS: LuaLinux
   =    @@@@@@@@@@@@@@@@  @@@@    Kernel: Lua
      @@@@@@@@@@@@      @@        Uptime: ?
     @@@@@@@@@@@@@       @@       Packages: ?
=   @@@@@@@@@@@@@@      @@@@   =  Shell: lualnx
    @@@@@@@@@@@@@@@   @@@@@@      Resolution: ?
    @@@@ @@@@@@@@@@@@@@ @@@@      DE: ?
    @@@@ @@@@@ @@ @@    @@@@      WM: ?
=   @@@@ @@@@@ @@ @@ @@ @@@@   =  WM Theme: ?
     @@@     @    @@     @@       Theme: ?
      @@@@@@@@@@@@@@@@@@@@        Icons: ?
   =    @@@@@@@@@@@@@@@@    =     Terminal: lualnx
           @@@@@@@@@@             CPU: ?
                                  GPU: ?
                        =         Memory: ?
           =        =           ]])
end

local commands = { --Table/Dict type
    ["neofetch"] = neofetch
}

local idle_cmd = { -- List type
}
local aliases = { -- Table/Dict type
    ["fastfetch"] = {"neofetch"}
}

return {
    commands = commands,
    idle_cmd = idle_cmd,
    aliases = aliases
}
