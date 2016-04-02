# About YARP

__YARP__ (Yet Another RolePlay) is a Warcraft III map heavily inspired by sandbox maps like SotDRP and RoTRP.
These maps provided the players with many useful commands which exposed a lot of functionality of the WC3 engine directly to the players. Using these commands, the players are able to create rather impressive builds and environments for usage in their roleplay. YARP follows in this direction, seeking to improve upon what SotDRP and RoTRP had laid down before.

YARP does not use any of the code from SotDRP or RoTRP, nor any object data from these maps. It is written completely from scratch, using Zinc (an extension to vJass) for triggers and GMSI for object data generation.
### Disclaimer

Below is a comprehensive explanation of YARP's features and mechanisms. A simpler "tutorial" will be available afterwards. However, the material below should get you acquainted with how YARP works and give you a grasp on it's major features.

# Mission statement

If there are already sandbox maps out there, then why do we need another one?

While RoTRP does provide a plenty of tools, there is always room for improvement, and YARP in particular strives to bring better user experience to the players, by making the building process easier and more convenient. YARP also seeks to extend functionality by providing features that are absent from older sandbox maps.

# Improvements and new features

### Command handling

#### Aliases and Macros
Previous RP maps only allowed one command per chat message, and sometimes (like with tint), arguments were fixed to certain positions in the command, forcing people to use something like "tint 050050050". RoTRP 3.3 was the first map to introduce better parsing of commands, introducing command splitting using pipes (the | character) to allow more than one command per chat message, and also introduced aliases. This allowed players to type commands like "aa invulnerable | tint 50 50 50 | give neutral", which would execute all three commands in one go. Aliases allowed to create new commands out of old ones, although they were fairly limited in functionality. The way aliases worked was this (each line is a chat command):

* `alias bl tint 0 0 0 150` _<- this creates a new alias "bl", which resolves to "tint 0 0 0 150"_
* `'bl` _<- running this command is equal to running tint 0 0 0 150_

However, you could not put multiple commands into a single alias (at least I never found a way to). YARP improves on these concepts by allowing recursive aliases (aliases which use other aliases), as well as multiple commands per single alias. Aliases in YARP also do not need the apostrophe, they are used just like regular commands. Example:

* `alias graytint [tint 50 50 50]`
* `alias invul [ability add Avul]`
* `alias gn [give neutral]`
* `alias f [graytint | invul | gn]`
* `f` _<- this tints the units in your selection, makes them invulnerable and gives them to neutral, all in one command._
* `graytint | invul | gn` _<- this is equivalent to using the "f" alias_
* `tint 50 50 50 | ability add Avul | give neutral` _<- this is also the same, but takes much longer to type_

The brackets in the above example are used as quote symbols, and everything inside these ignores normal parsing rules. This is mostly useful in commands which require specifying another command. They are __optional__, and you can specify aliases without them just as well, but only as long as you only want one command inside of an alias.

* `alias f tint 50 50 50 | give neutral` <- _wrong, it will create an alias "f" which resolves to "tint 50 50 50" and then run the command "give neutral" on your current selection._
* `alias f [tint 50 50 50 | give neutral]` _<- correct, it will create an alias "f" which resolves to "tint 50 50 50 | give neutral"_
* `alias graytint tint 50 50 50` _<- also correct, it will create an alias "graytint" which resolves to "tint 50 50 50"_

Internally, aliases work by replacing the alias word with their expansion. So when you type

* `alias f tint 50 50`
* `f`

it expands "f" into "tint 50 50", so the command becomes

* `tint 50 50`

So if you type

* `f 50 100`

it will expand into

* `tint 50 50 50 100`

This can be useful to shorten commands. For example

* `alias aa ability add`
* `aa Avul`
* `alias ar ability remove`
* `ar Avul`

Another, new feature are macros. They are very similiar to aliases, with one notable exception - they do not require a space between the macro and it's arguments. Using macros, it is possible to replicate SotDRP/RoTRP style commands:

* `macro ' ability add`
* `macro @ ability remove`
* `'Avul` _<- this is equivalent to RoTRP's 'invulnerable_
* `@Avul` _<- this is equivalent to RoTRP's @invulnerable_

#### Command threads

Commands in SotDRP/RoTRP always run in an instant. You type in a command, and it gets executed at the same moment you typed it, and the result is immediately visible. YARP allows the commands to be delayed and automatically repeated over time. The best way to explain this is with an example:

You have 6 units selected, and you type the following:

* `size 100 | wait 5 | size 150`

All 6 units will have their size set to 100, and after 5 seconds, __even if you deselect them during that time__, these 6 units will have their size set to 150.

Internally, this works by keeping track of which units a player had selected when they ran the command, so even if you change your selection while the command is "waiting", it will run the command on the units you had selected before.

This may look like a rather pointless feature, but in combination with aliases and some other commands, it can be used to create some very interesting effects. Examples will be provided later.

### Regions

YARP improves and extends functionality of regions (or rects). To create a new region, use the command

* `region`

This will spawn a unit below your Spawner, called the Location Specifier. When you select the Location Specifier, the size of the region will be shown on your screen, and you can change the size using abilities on the Location Specifier.

There are five main features related to regions: weather control, lighting control, fog control, mass commands and save/load.

If you want to create weather in a region, select the Location Specifier and type the command

* `weather weathername`

A list of all suitable weather names will be provided in the wiki.

Lighting and Fog commands are used to change the appearance of the world when a player's camera is looking at the region. Lighting can be completely turned off by typing "lighting" while selecting the Location Specifier, or you can use one of the provided lighting models (also in the wiki). For example:

* `lighting` _<- this turns off lighting completely, and the world will be pitch black, except where illuminated by torches and alike_
* `lighting ashenvale` _<- uses the lighting model from the Ashenvale terrain tileset_
* `lighting dungeon` _<- uses the lighting model from the Dungeon terrain tileset_

The fog command is similiar, and the syntax for it is as follows:

* `fog start end red green blue`

Start is how far away from the camera the fog starts. End is how far away from the camera the fog is at 100% density. RGB is the fog color. Example:

* `fog 1000 3000 50 50 50`

Here's a screenshot example of what can be achieved using the lighting/fog commands:

![Example](http://i.imgur.com/nTdA801.jpg)

The Location Specifier has a "run command on units" ability, which runs a command on all units within the region. In order to set which command will be ran, use the "aux" command, for example:

* `aux [tint 50 50 50 | give neutral]`

After this, if you use the "run command on units" ability, all units within the region will have their tint set to 50 50 50. This essentially replaces your selection with that of the region contents when running the command.

Likely the most significant feature that can be used in conjuction with regions is the save/load system. More on it below.

### Save/Load support

YARP introduces a relatively simple Save/Load system. It can be used to save units, terrain and height modifications and load them later in another game. It works by saving all the unit, terrain and height data into a text file on your computer, then converting the data into an AHK (AutoHotkey) script which will paste it all back into the game through chat commands. The conversion script and a more detailed, step-by-step tutorial will be available later.

In order to save something, create a region, resize it, then select it and type

* `save filename`

This will save the data to a file named `filename.txt` inside a folder called `yarp` in your WC3 folder.

Using the conversion script, the .txt file can be converted into an .ahk file. In order to paste your build, start the script, select a Location Specifier, and press the hotkey (ctrl-q by default). The required commands will be pasted and it will replicate the build you had saved.

_Note: Saving is done relative to the Location Specifier, and will be pasted relative as well. If you want to paste the build into it's original position, do not select a Location Specifier before pasting._

