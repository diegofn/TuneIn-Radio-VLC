--[[
 $Id$

 Copyright © 2013 VideoLAN and AUTHORS

 Authors: Diego Fernando Nieto <diegofn at me dot com>

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

function descriptor()
    return { title="TuneIn Radio" }
end

--
-- Main Function
--
function main()

	-- Add the main categories to browse TuneIn
	
	-- Check is the username was defined
	-- WISH: Dialog to change this params because vlc.config object doesn't work
	local __username__ = "user"
	local __password__ = "password"
	
	tunein_radio = NewTuneInRadio (__username__, __password__)

	--
	-- Create a new TuneinRadio object
	--
	tunein_radio.load_genre_cache( )

	--
	-- Use the add_radio_tracks to load categories in the playlist
	-- track_type is category, region, id
	--
	if __username__ ~= nil then
		tunein_radio.add_radio_tracks ( "category", "presets", "My presets" )
	end
	
	tunein_radio.add_radio_tracks ( "category", "local", "Local Radio")
	tunein_radio.add_radio_tracks ( "category", "trending", "Trending")
	tunein_radio.add_radio_tracks ( "category", "music", "Music")
	tunein_radio.add_radio_tracks ( "id", "c57922", "News")
	tunein_radio.add_radio_tracks ( "category", "talk", "Talk")
	tunein_radio.add_radio_tracks ( "category", "sports", "Sports")
	tunein_radio.add_radio_tracks ( "region", "r0", "By Location")
	tunein_radio.add_radio_tracks ( "category", "lang", "By Language")
	tunein_radio.add_radio_tracks ( "category", "podcast", "Podcasts")
end

--
-- Class TuneInRadio
--
function NewTuneInRadio (username, password)
	--
	-- TuneIn Radio private members
	--
	local self = {	__username__ = username,
					__password__ = password,
					__genres_cache__ = {},
					__partner_id__ = "yvcOjvJP",
					__protocol__ = "http://",
					__BASE_URL__ = "opml.radiotime.com",
					__formats__ = "aac,html,mp3,wma,wmpro,wmvideo,wmvoice"
	}
    
	--
	-- Load the genre array in a cache
	--
	local load_genre_cache = function ()
			
		-- Local Variables
		local params = ""
		local method = "/Describe.ashx"
		params = "?c=genres" .. "&partnerId=" .. self.__partner_id__

		-- Create the URL
		local url = self.__protocol__ .. self.__BASE_URL__ .. method .. params

		-- Add the first node
		local tree = simplexml.parse_url(url)

		for _, body in ipairs( tree.children ) do
			simplexml.add_name_maps( body )

			-- This has found an genre
			if body.children_map["status"] == nil then
				if body.children_map["outline"] ~= nil then
					-- Browse all outline elements searching genres
					self.__genres_cache__ = (body.children_map["outline"])
				end
			end
		end
	end

	--
	-- Return the Genre name based in its genre_id
	--
	local get_genre_name = function ( genre_id )
		for _, genres in ipairs (self.__genres_cache__) do
			if ( genres.attributes["guide_id"] == genre_id ) then
				return  genres.attributes["text"]
			end
		end
	end
    
	--
	-- Add Radio Tracks Functions
	--
	local add_radio_tracks = function ( track_type, category, category_name, username, password )
		
		-- Local Variables
		local params = ""
		local method = "/Browse.ashx"
	
		-- Create the params string using track_type
		if track_type == "category" then
			params = "?c=" .. category
		elseif track_type == "region" then
			params = "?id=" .. category
		elseif track_type == "id" then
			params = "?id=" .. category
		end
		params = params .. "&formats=" .. self.__formats__ .. "&partnerId=" .. self.__partner_id__ .. "&username=" .. self.__username__ .. "&password=" .. self.__password__
	
		-- Create the URL
		local url = self.__protocol__ .. self.__BASE_URL__ .. method .. params
	
		-- Add the first node
		local node = vlc.sd.add_node( {	title = category_name,
									 	arturl = "http://www.avrilcolombia.org/VideoLAN/VLC/resources/" .. category .. ".png"
									 } )
		local tree = simplexml.parse_url(url)
			
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
								node:add_subitem( {path = station.attributes["URL"],
												title = station.attributes["subtext"],
												artist = station.attributes["text"],
												genre = get_genre_name ( station.attributes["genre_id"] ),
												arturl = vlc.strings.resolve_xml_special_chars ( station.attributes["image"] )
								} )
							
							elseif station.attributes["type"] == "link" then
								-- Its a Subnode (Link)
								node:add_subitem( {path = station.attributes["URL"],
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
	end

	return {
		load_genre_cache = load_genre_cache,
		get_genre_name = get_genre_name,
		add_radio_tracks = add_radio_tracks
	}
end


