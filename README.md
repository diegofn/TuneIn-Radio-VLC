**Tunein-Radio-VLC**
====================

This is a Service Discovery LUA Script to TuneIn Radio for VLC 2.X.X and VLC 3.X.X

# Installation

1. Download the latest release from: https://github.com/diegofn/TuneIn-Radio-VLC/archive/master.zip and uncompress:

    curl -L https://github.com/diegofn/TuneIn-Radio-VLC/archive/master.zip > TuneinRadioVLC.zip
    unzip TuneinRadioVLC.zip

1.1. On Linux install copy to home directory 
    cp TuneIn-Radio-VLC-master/tunein.lua /usr/lib/vlc/lua/sd/
    cp TuneIn-Radio-VLC-master/playlist/* /usr/lib/vlc/lua/playlist/

1.2. On Windows copy to `C:\Program Files\VLC` or to `%AppData%/VLC/VideoLAN/lua/sd`

1.3. On MacOS copy to /Applications/VLC folder: 
    sudo cp TuneIn-Radio-VLC-master/tunein.lua /Applications/VLC.app/Contents/MacOS/share/lua/sd/
    sudo cp -R TuneIn-Radio-VLC-master/playlist/* /Applications/VLC.app/Contents/MacOS/share/lua/playlist/

Or you can copy to local `home` directory
    cp TuneIn-Radio-VLC-master/tunein.lua ~/Library/Application\ Support/org.videolan.vlc/lua/sd/
    cp -R TuneIn-Radio-VLC-master/playlist/* ~/Library/Application\ Support/org.videolan.vlc/lua/

2. If you have an TuneIn user, you can modify the tunein.lua file in the __username__ and __password__ variables

4. Start your VLC 

5. Enjoy!

Version 0.7
===========
* Update script for VLC 3.X.X.
* Minor fix on Title and Author columns thanks to @umpirsky
* Fix identation thanks to @hbkfabio

Version 0.6
===========
* Update image hosting
* "My presets" change for "Favorites" category
* Minor fix

Version 0.5
===========
* Change PartnerId to support flash based streaming
* Update image URL

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

# Project resources

- [Source code](https://github.com/diegofn/TuneIn-Radio-VLC)
- [Issue tracker](https://github.com/diegofn/TuneIn-Radio-VLC/issues>)

# Credits

- [Original author](https://github.com/diegofn)
- [Current maintainer](https://github.com/diegofn)
- [Contributors](https://github.com/diegofn/TuneIn-Radio-VLC/graphs/contributors)

# Wish List

- Read the username and password for the Preferences Dialog, In progress
- Be accepted in VLC git ;)