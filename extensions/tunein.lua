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
   
function descriptor()
	return { title = "TuneIn Radio VLC Extension";
		version = "0.1";
		author = "diegofn";
		shortdesc = "TuneIn";
		description = "<center><b>TuneIn Radio VLC Extension</b></center>";
		capabilities = {"menu"};
	}
end

input_table = {} -- Variables interfaces

function activate()
	vlc.msg.dbg("[TuneIn] Starting...")
	
    check_config()
	close_dlg()
	dlg = vlc.dialog(tunein_radio.useragent)
	interface_main()

	collectgarbage()
end

function menu()
	  return { "Config" }
end

function interface_main()
	dlg:add_label('Username:', 1, 1, 1, 1)
	input_table['username'] = dlg:add_text_input(tunein_radio.option.username or "", 2, 1, 1, 1)

	dlg:add_label('Password:', 1, 2, 1, 1)
	input_table['password'] = dlg:add_text_input(tunein_radio.option.password or "", 2, 2, 1, 1)

	input_table['message'] = dlg:add_label(' ', 1, 3, 2, 1)
	dlg:add_button('Save', apply_config, 1, 4, 1, 1)
	dlg:add_button('Cancel', deactivate, 2, 4, 1, 1) 
end

function close_dlg()
	vlc.msg.dbg("[TuneIn] Closing dialog")

	if dlg ~= nil then 
		dlg:delete() 
	end
	
	dlg = nil
	input_table = nil
	input_table = {}
end

function check_config()
	--local path = vlc.config.userdatadir()
	--local slash = "/"
	--if is_window_path(path) then
	--	slash = "\\"
	--end

	tunein_radio.configfile = "tunein_radio.xml"
	
	if file_exist(tunein_radio.configfile) then
		vlc.msg.dbg("[TuneIn] Loading config file:  " .. tunein_radio.configfile)
		load_config()
	end
end

function load_config()
	local tmpFile = assert(io.open(tunein_radio.configfile, "rb"))
	local resp = tmpFile:read("*all")
	tmpFile:flush()
	tmpFile:close()
	local option = parse_xml(resp)
	for key, value in pairs(option) do
		tunein_radio.option[key] = value
	end
end

function save_config()
	vlc.msg.dbg("[TuneIn] Saving file:  " .. tunein_radio.configfile)
	local tmpFile = assert(io.open(tunein_radio.configfile, "wb"))
	local resp = dump_xml(tunein_radio.option)
	tmpFile:write(resp)
	tmpFile:flush()
	tmpFile:close()
end

function is_window_path(path)
	return string.match(path, "^(%a:\).+$")
end

function file_exist(name) -- test readability
	local f=io.open(name ,"r")
	if f~=nil then 
		io.close(f) 
		return true 
	else 
		return false 
	end
end

function dump_xml(data)
	local level = 0
	local stack = {}
	local dump = ""
	
	local function parse(data, stack)
		for k,v in pairs(data) do
			if type(k)=="string" then
				dump = dump.."\r\n"..string.rep (" ", level).."<"..k..">"	
				table.insert(stack, k)
				level = level + 1
			elseif type(k)=="number" and k ~= 1 then
				dump = dump.."\r\n"..string.rep (" ", level-1).."<"..stack[level]..">"
			end
			
			if type(v)=="table" then
				parse(v, stack)
			elseif type(v)=="string" then
				dump = dump..vlc.strings.convert_xml_special_chars(v)
			elseif type(v)=="number" then
				dump = dump..v
			else
				dump = dump..tostring(v)
			end
			
			if type(k)=="string" then
				if type(v)=="table" then
					dump = dump.."\r\n"..string.rep (" ", level-1).."</"..k..">"
				else
					dump = dump.."</"..k..">"
				end
				table.remove(stack)
				level = level - 1
				
			elseif type(k)=="number" and k ~= #data then
				if type(v)=="table" then
					dump = dump.."\r\n"..string.rep (" ", level-1).."</"..stack[level]..">"
				else
					dump = dump.."</"..stack[level]..">"
				end
			end
		end
	end
	parse(data, stack)
	return dump
end

function parse_xml(data)
	local tree = {}
	local stack = {}
	local tmp = {}
	local level = 0
	
	table.insert(stack, tree)

	for op, tag, p, empty, val in string.gmatch(data, "<(%/?)([%w:]+)(.-)(%/?)>[%s\r\n\t]*([^<]*)") do
		if op=="/" then
			if level>0 then
				level = level - 1
				table.remove(stack)
			end
		else
			level = level + 1
			if val == "" then
				if type(stack[level][tag]) == "nil" then
					stack[level][tag] = {}
					table.insert(stack, stack[level][tag])
				else
					if type(stack[level][tag][1]) == "nil" then
						tmp = nil
						tmp = stack[level][tag]
						stack[level][tag] = nil
						stack[level][tag] = {}
						table.insert(stack[level][tag], tmp)
					end
					tmp = nil
					tmp = {}
					table.insert(stack[level][tag], tmp)
					table.insert(stack, tmp)
				end
			else
				if type(stack[level][tag]) == "nil" then
					stack[level][tag] = {}
				end
				stack[level][tag] = vlc.strings.resolve_xml_special_chars(val)
				table.insert(stack,  {})
			end
			if empty ~= "" then
				stack[level][tag] = ""
				level = level - 1
				table.remove(stack)
			end
		end
	end
	return tree
end

function apply_config()
	tunein_radio.option.username = input_table["username"]:get_text()
	tunein_radio.option.password = input_table["password"]:get_text()
	
	save_config()
end

function deactivate()
    vlc.msg.dbg("[TuneIn] deactivate!")
	vlc.deactivate()
end

tunein_radio = {
	useragent = "TuneIn Radio",
	configfile = "",
	
	option = {
		username = nil,
		password = nil
	}
}
	
