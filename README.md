<h1 align="center">Team Fortress 2 Team Radar</h1>
$${\color{red}Red}$$
This plugin creates a simple, real-time radar display for each player, showing the positions of their teammates relative to their own position. 

The radar uses SourceMod's HUD text functionality for rendering, making it a lightweight solution that doesn't require any client-side modifications.

> [!NOTE]
> The plugin primarily shows teammates and was originally designed for certain practicing environments. It does not provide information about enemy positions.

## Features

1. **Radar Display**:
   - Shows the player as a yellow up-facing arrow (⮝).
   - Shows teammates as colored dots (●) or arrows (▽ / △) based on elevation relative to the player.

2. **Health Indication**:
   - Teammate markers change color based on health:
     - Green: Above 50% health
     - Red: 50% health or below

3. **Pinging System**:
   - Players can mark where they're looking at on the radar.
   - Pings appear as yellow exclamation marks (!) for 5 seconds, with a 3-second cooldown between pings.

4. **Extras**:
   - The radar's position can be changed per player or toggled on/off through `!radar`. (Saved between sessions)
   - Config file to adjust the plugin's core settings. (colors, update interval, area covered, radar scale)
   - Admins can toggle the visibility of disguised enemy Spies.
   - Admins can reload the configuration on-the-fly with `!reloadradar` or through the radar menu.

## Commands

- `!radar` Opens a menu to toggle the radar or change its position. Settings are saved per player and persist between sessions (cookies).
- `!pingradar` Ping a location on the radar. Ideally, use `bind <key> "say /pingradar"`
- `!reloadradar` Admin command to reload the config file.

## Requirements

- The latest [SourceMod](https://www.sourcemod.net/downloads.php) release.

## Installation

1. Download the latest `team_radar.smx` from the [Releases](https://github.com/vexx-sm/tf2-team-radar/releases) page and place it in your `sourcemod\plugins` folder.
	
2. Download the latest `tf2_team_radar.cfg` from the [Releases](https://github.com/vexx-sm/tf2-team-radar/releases) page and place it in your `sourcemod\configs` folder.
	
3. Reload the plugin or restart your server.

## License & Contributing

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

**Requests** & Contributions are welcome! Feel free to submit a Pull Request.