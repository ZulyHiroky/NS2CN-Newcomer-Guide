--It is the job of shared.lua to create the plugin table.
local Plugin = {}
Plugin.Version = "0.1"
Plugin.HasConfig = false
Plugin.DefaultState = false

Shine:RegisterExtension( "redir", Plugin )
