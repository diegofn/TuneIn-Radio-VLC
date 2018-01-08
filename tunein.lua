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

function descriptor()
    return { title="TuneIn Radio" }
end

--
-- Main Function
--
function main()
    --
    -- Check is the username was defined
    -- WISH: Dialog to change this params because vlc.config object doesn't work
    --
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
        tunein_radio.add_radio_tracks ( "category", "presets", "Favorites" )
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
        __partner_id__ = "k2YHnXyS",
        __protocol__ = "https://",
        __BASE_URL__ = "opml.radiotime.com",
        __formats__ = "aac,html,mp3,wma,wmpro,wmvideo,wmvoice"
    }

    --
    -- Load the genre array in a cache
    --
    local load_genre_cache = function ()

        --
        -- Local Variables
        --
        local params = ""
        local method = "/Describe.ashx"
        params = "?c=genres" .. "&partnerId=" .. self.__partner_id__

        --
        -- Create the URL and add the first node
        --
        local url = self.__protocol__ .. self.__BASE_URL__ .. method .. params
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

        --
        -- Local Variables
        --
        local params = ""
        local method = "/Browse.ashx"

        --
        -- Create the params string using track_type
        --
        if track_type == "category" then
            params = "?c=" .. category
        elseif track_type == "region" then
            params = "?id=" .. category
        elseif track_type == "id" then
            params = "?id=" .. category
        end
        params = params .. "&formats=" .. self.__formats__ .. "&partnerId=" .. self.__partner_id__ .. "&username=" .. self.__username__ .. "&password=" .. self.__password__

        --
        -- Create the URL and add the first element
        --
        local url = self.__protocol__ .. self.__BASE_URL__ .. method .. params
        local node = vlc.sd.add_node( {	title = category_name,
                arturl = "https://raw.githubusercontent.com/diegofn/TuneIn-Radio-VLC/master/resources/" .. category .. ".png"
            } )
        
        response = '<?xml version="1.0" encoding="UTF-8"?>        <opml version="1">            <head>            <title>user&apos;s Favorites</title>            <status>200</status>                        </head>            <body>        <outline type="audio" text="89.7 | Ria FM (Top 40 and Pop Music)" URL="http://opml.radiotime.com/Tune.ashx?id=s16407&amp;formats=aac,html,mp3,wma,wmpro,wmvideo,wmvoice&amp;partnerId=k2YHnXyS&amp;username=user" bitrate="48" reliability="97" guide_id="s16407" subtext="Ekamatra - Hanya Suatu Persinggahan" genre_id="g61" formats="aac" playing="Ekamatra - Hanya Suatu Persinggahan" item="station" image="http://cdn-radiotime-logos.tunein.com/s16407q.png" now_playing_id="s16407" preset_number="1" preset_id="s16407" is_preset="true"/>        <outline type="audio" text="95.8 | Capital 95.8FM 城市频道 (Chinese Talk)" URL="http://opml.radiotime.com/Tune.ashx?id=s24959&amp;formats=aac,html,mp3,wma,wmpro,wmvideo,wmvoice&amp;partnerId=k2YHnXyS&amp;username=user" bitrate="48" reliability="95" guide_id="s24959" subtext="资讯第一台" genre_id="g337" formats="aac" item="station" image="http://cdn-radiotime-logos.tunein.com/s24959q.png" now_playing_id="s24959" preset_number="2" preset_id="s24959" is_preset="true"/>            </body>        </opml>'
        vlc.msg.info("URL: " .. url)
        local tree = simplexml.parse_url(url)
        for _, body in ipairs( tree.children ) do
            simplexml.add_name_maps( body )

            --
            -- It has found an station
            --
            if body.children_map["status"] == nil then
                if body.children_map["outline"] ~= nil then

                    --
                    -- Browse all outline elements searching stations
                    --
                    for _, station in ipairs( body.children_map["outline"] ) do
                        if station ~= nil then

                            --
                            -- Add Station
                            -- Check if the station is a Radio Station
                            --
                            if station.attributes["type"] == "audio" then
                                -- Its a station
                                node:add_subitem( {path = station.attributes["URL"],
                                        title = station.attributes["text"],
                                        artist = station.attributes["subtext"],
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


