Tunein-Radio-VLC
================

This is a Service Discovery LUA Script to TuneIn Radio for VLC 2.X.X

How to Install
==============

1. Copy the tunein.lua in the share/lua/sd directory. In Linux the directory is ~/.local/share/vlc/lua/sd/ in Windows the directory is C:/program files (x86)/VLC/VideoLAN/lua/sd 
2. If you have an TuneIn user, you can modify the script in the __username__ and __password__ variables
3. Copy the playlist/radiotime.lua and playlist/streamtheworld.lua to share/lua/playlist directory, with this playlist you can browse the Podcast, news or sports directory since VLC
4. Start your VLC 
5. Enjoy!

Version 0.4
===========
* Added Trending category

Version 0.3
===========
* Bug fixed about TuneIn Password
* Added StreamTheWorld Support
* Added radiotime.com playlist support to navigate podcast, sports, etc tree.

Version 0.2
===========
* Add music menu
* Add custom icon for main categories
* Run plugin as a LUA Object

Version 0.1
===========
* This is the first version, My Presets and Local Radio working
* The LUA Script mapping the Categories and Location nodes

Wish list
=========
* Read the username and password for the Preferences Dialog, In progress
* Be accepted in VLC git ;)
