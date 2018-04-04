# About YARP

__YARP__ (Yet Another RolePlay) is a freeform roleplay sandbox, in the vein of RoTRP and SotDRP. It provides various facilities for players to build and roleplay effectively in the WC3 engine.
# Maintenance

This project is no longer maintained. However, you are free to develop and improve the map if you wish to do so.
The map isn't set up like a conventional WC3 map. Instead:

- Object data is generated with the use of GMSI scripts and data lists,
- Triggers are externalized through the use of vJASS imports.

This means that you only use the editor to change terrain. Everything else is done externally.
If you wish to develop:

- Download and install WEX - https://www.hiveworkshop.com/threads/sharpcraft-world-editor-extended-bundle.292127/
- Use Git to checkout into the repo (or download it as a zip), put it into a folder, e.g. `C:/yarp`
- Download GMSI - http://www.wc3c.net/showthread.php?t=103939 and put it into a folder, e.g. `C:/gmsi`
- If you don't have Java installed, install it too
- Navigate to where you installed WEX, and find this folder: `<WEX Location>/profiles/Warcraft III - World Editor (WEX)/plugins/JassHelper`
- Open the file `jasshelper.conf`, and under the section `[lookupfolders]` add the path of the yarp repository. In this example, `c:\yarp`
- Open the directory where you extracted GMSI, and create a file called `start.bat`, and insert the following:
```
SET JPATH="C:\Program Files (x86)\Java\jre1.8.0_131\bin\java.exe"

%JPATH% -Xmx512m -jar "GMSI.jar"
```
IMPORTANT: REPLACE THE PATH TO `java.exe` WITH THE PATH WHERE YOUR JAVA IS INSTALLED (it will be different)

If you like, you can also set up a quick script to build object data for YARP. Name it something like `yarpbuild.bat`:
```SET JPATH=C:\Program Files (x86)\Java\jre1.8.0_131\bin\java.exe
SET GMSIBASE=C:\Users\moriarty\Documents\Warcraft III\Tools\GMSI
SET WC3BASE=C:\Users\moriarty\Documents\Warcraft III
SET DOWNLOADPATH=Maps\YARP
SET YARPNAME=DummyData.w3x

"%JPATH%" -Xmx512m -jar "GMSI.jar" "%WC3BASE%\%DOWNLOADPATH%\%YARPNAME%"
COPY "%GMSIBASE%\output\%YARPNAME%" "%WC3BASE%\%DOWNLOADPATH%\%YARPNAME%"
PAUSE
```
`GMSIBASE` is the path to GMSI itself, `WC3BASE` is the path to your WC3 Documents folder, `DOWNLOADPATH` is the path where the YARP map file is located within WC3 Documents folder, and `YARPNAME` is the name of the map file itself.

- Now go to the GMSI folder, and find a folder called `script`. Open a command window as admin there. (If you don't know how to do that, google it)
- Type `mklink /D yarp <path to yarp gmsi folder>`, e.g. `mklink /D yarp C:\yarp\gmsi`

Now, when you want to build object data you can either:
- Go to the GMSI folder, copy the yarp map to the "input" folder, open GMSI, select the map in the menu, double click it, ensure that the script runs without errors, and then copy the map from the "output" folder.
- Or, just run the `yarpbuild.bat` script if you've made it.

If you want to edit object data, you can look at the GMSI scripts. All buildings and builders are generated using the scripts in the `objects` folder. Follow the format there and you should be fine. **If you add new files, make sure to include them in `init.gsl` just like the rest of the files.**

If you want to generate triggers, just open the map in WEX, and save it. If you've set up everything correctly, it should save without errors. If it complains about missing imports, double check everything. If you wish to edit them, just fire up your favourite editor, and edit the triggers in the `yarp` subfolder of the repo. Most of them are written using Zinc, some external dependencies are in plain vJASS.

The latest unprotected version of the map is provided in the root of this repository, and you should use it as a template.

If you wish to:
- Add new commands, you'll have to edit the Zinc/vJASS triggers. You don't have to touch GMSI at all.
- Add new models, you'll have to edit the GMSI generator lists and re-generate the object data in the template. You still have to setup WEX if you wish for triggers to work.
- Edit the terrain, you'll still need to setup WEX, because without it, triggers won't get installed.

If you can't follow these steps and get confused - please don't bother me. I'm not going to digest it for you.

If you feel like you're doing everything right, but it doesn't work for some reason - you can ask me a question in the YARP discord. You can find a link to it on the wiki.

If you don't know how to edit Zinc, vJASS, or GMSI - use Google. Hiveworkshop.com is also a great website for learning WC3 modding, and was my primary source of info when making this. If I could learn everything using available resources - so can you.

If you want minor help with the triggers, GMSI, or an explanation of some of the map's systems, you can ask me in the discord.

Good luck and have fun.
# Information

For information about YARP-specific features and commands, consult the wiki.