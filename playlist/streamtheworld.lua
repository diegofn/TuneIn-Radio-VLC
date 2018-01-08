--[[
 Streamtheworld lua script

 Copyleft 2013-2018 Diego Fernando Nieto <diegofn at me dot com>

 This program is free software; you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation; either version 2 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program; if not, write to the Free Software
 Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston MA 02110-1301, USA.
--]]

require "simplexml"

-- Probe function.
function probe()
    return (vlc.access == "http"
        and string.match( vlc.path, "player.streamtheworld.com" )
		and string.match( vlc.path, "liveplayer.php" )
		)
end

-- Parse function.
function parse()
	
	-- Local variables
	local host = "http://playerservices.streamtheworld.com/api/"
	local mount = string.match (vlc.path, "callsign\=(.*)$")
	local options = "livestream?version=1.4&mount=" .. mount .. "AAC&lang=EN"
	local page = ""

	-- Stream the results
	local fd, msg = vlc.stream (host .. options)
	if not fd then
		vlc.msg.warn(msg)
        -- not fatal
	else
		while true do
	        local line = fd:readline()
    	    if line == nil then break end
        	page = page .. line
    	end
	end
    
	local tracks = {}
	local tree = simplexml.parse_string( page )
	for _, body in ipairs( tree.children ) do
		simplexml.add_name_maps( body )
		--This has found a valid URL

		if body.children_map["mountpoint"] ~= nil then
			
			-- Define the mountpoint name
			local mp = body.children_map["mountpoint"][1].children_map["mount"][1].children[1]
			
			-- Browse all servers elements searching a valid server
			for _, server in ipairs( body.children_map["mountpoint"] ) do
				if server ~= nil then
					
					-- Define the server IP Address
					local serverip =  server.children_map["servers"][1].children_map["server"][1].children_map["ip"][1].children[1]
									
					-- Define the server IP Port
					local serverport =  server.children_map["servers"][1].children_map["server"][1].children_map["ports"][1].children_map["port"][1].children[1]
					
					--  Add the first server
					serverurl = "http://" .. serverip .. ":" .. serverport .. "/" .. mp
					table.insert( tracks, {path = serverurl, 
								  title = mp
								 } )
				end
			end
		end
	end

	
	return tracks
end
