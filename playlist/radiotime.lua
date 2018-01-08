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
        and string.match( vlc.path, "opml.radiotime.com" )
		and string.match( vlc.path, "Browse.ashx" )
		) or (
		vlc.access == "http"
	  	and string.match( vlc.path, "opml.radiotime.com" )
		and string.match( vlc.path, "Tune.ashx" )
		and string.match( vlc.path, "c=pbrowse" )
		)
end

-- Parse function.
function parse()
    local page = ""
    while true do
        local line = vlc.readline()
        if line == nil then break end
        page = page .. line
    end
    
	local tracks = {}
	local tree = simplexml.parse_string( page )
	
	for _, body in ipairs( tree.children ) do
		simplexml.add_name_maps( body )
			
		-- This has found an station
		if body.children_map["status"] == nil then
			if body.children_map["outline"] ~= nil then
				
				-- Browse all outline elements searching stations
				for _, station in ipairs( body.children_map["outline"] ) do
					if station ~= nil then
						
						-- Add Station
						-- Check if the station is a Radio Station
						if station.attributes["type"] == "audio" then
							-- Its a station
							table.insert( tracks, {path = station.attributes["URL"],
										title = station.attributes["subtext"],
										artist = station.attributes["text"],
										genre = station.attributes["genre_id"],
										arturl = vlc.strings.resolve_xml_special_chars ( station.attributes["image"] )
							} )
							
						elseif station.attributes["type"] == "link" then
							-- Its a Subnode (Link)
							table.insert( tracks, {path = station.attributes["URL"],
										title = station.attributes["text"],
										artist = station.attributes["text"],
										album = station.attributes["text"],
							} )
						
						else
							-- Its a Subnode only
							-- WISH. Can display the entire tree
						end
					end
				end
			end
		end
	end
	
	return tracks
end
