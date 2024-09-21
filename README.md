<h1 align="center">Team Fortress 2 Team Radar</h1>

This plugin creates a simple, real-time radar for each player, showing the positions of their teammates relative to their own position. 

The radar uses SourceMod's HUD text functionality for rendering, making it a lightweight solution that doesn't require any client-side modifications.

> [!NOTE]
> **This plugin primarily shows teammates** and was originally designed for certain practicing environments. **It does not provide information about enemy positions.**

## Features

1. **Radar Display**:
   - Shows teammates as colored dots (●) or arrows (▽ / △) based on elevation relative to the player
     - Green: Above 50% health
     - Red: 50% health or below
   - Represents the player as a yellow up-facing arrow (⮝) in the center
   - Radar is toggleable and it's position is adjustable, settings are saved per player
   - Everything neatly packed under the `!radar` menu

2. **Pinging System**:
   - Players can mark where they're looking at on the radar for their teammates
   - Use `!pingradar` to ping (ideally: `bind <key> "say /pingradar"`)
   - Pings appear as yellow exclamation marks (!) on the radar

3. **Admin Features**:
   - Toggle visibility of disguised enemy Spies globally
   - Reload the cfg on-the-fly with `!reloadradar` or through the radar menu
     
4. **Customizable**: (through the config file)
   - How many in game units the radar covers
   - How often the radar updates in seconds
   - The size of the radar on the screen
   - All colors can be changed (RGBA)
   
## Requirements

- The latest [SourceMod](https://www.sourcemod.net/downloads.php) release.

## Installation

1. Download the latest `team_radar.smx` from the [Releases](https://github.com/vexx-sm/tf2-team-radar/releases) page and place it in your `sourcemod\plugins` folder.
	
2. Download the latest `tf2_team_radar.cfg` from the [Releases](https://github.com/vexx-sm/tf2-team-radar/releases) page and place it in your `sourcemod\configs` folder.
	
3. Reload the plugin or restart your server.

## License & Contributing

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

**Requests** & Contributions are welcome! Feel free to submit a Pull Request.
