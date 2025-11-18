# Gameflattener

Utility for initializing 2D projects on Roblox.

## How to use
<img width="328" height="256" alt="image" src="https://github.com/user-attachments/assets/aebbbcd0-e1a8-41f6-8e83-a1c3b6e84285" />

There are two settings that can be tweaked before running:
* '''Clear Workspace''': Sets whether or not Workspace and Lighting should be cleared. Since they can't be removed, they will instead be made to do as little work as possible, based on [this DevForum thread](https://devforum.roblox.com/t/creating-the-most-optimized-roblox-game-runs-at-6000-fps/1736424).
* '''Single Player''': Many of the CoreGui elements, such as health or the emotes menu, are not relevant to a 2D experience. If set to false, then a script that disables these elements, as well as the topbar, is added to the game. If set to true, then a script that disables all CoreGui elements except the Captures menu is added instead.

Regardless of configuration, the following will always occur:
* `Players.CharacterAutoLoads` is set to false.
* Default player scripts are replaced with empty folders.
* `ScreenshotHud.HidePlayerGuiForCaptures` is set to `false`.
* A script removing the Freecam is added to ServerScriptService.

## Acknowledgements
This plugin was built using the [Nevermore Engine](https://github.com/Quenty/NevermoreEngine).
