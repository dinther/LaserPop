## laserPop

LaserOS POP is a simple AutoHotKey script that allows the user to record a sequence of Laser pop coordinates from the Pop module in laserOS. This makes it possible to rapidly pop balloons at a precise interval.

The script records mouse coordinates relative to the laserOS client window. LaserOS needs to be set to a known size in order for those coordinates to be accurate. This is all handled by the script.

First unlock burn mode in laserOS. You do this by going to Settings - General. Click on DEBUG and type "burn" and click OK. Restart laserOS. You now have two new programs named Pop and Burn.

Right click on Pop and assign "P" as the hotkey in laserOS (This is optional but it ensures pop mode is activated by laserPop)

Run laserPop.exe which will start laserOS if it is not already running. Set laserOS to pop mode if not already set. Set the duration to minimum to start with and activate the laser.

Move the mouse to the desired position and press CTRL A to add the point to the list. Don't click the mouse or you balloon pops. Keep adding points as desired.

You can set the pop speed to match music. Say you have music with a beat of 126 BPM you can set this value in laserPOP which assures each pop coordinate is executed for each music beat.

You can either press CTRL P or click "Play coords" to make the laser pop at high power on each programmed coordinate with the defined waiting time in BPM. (Divide 60 by BPM to get the interval in seconds) The playback stops after the last coordinate unless loop is checked. In that case use CTRL L to uncheck the looping because you mouse keeps jerking back to the laserOS window.

Alternativly you can press CTRL S to step to the next coordinate manually.

laserPOP stores the coordinates and BPM values in a local text file "LaserOS_Coords.txt when it closes and retrieves this data when the program is loaded.

<img width="315" height="502" alt="image" src="https://github.com/user-attachments/assets/72316686-5e82-4e54-a9f4-1d8a64efcadb" />
