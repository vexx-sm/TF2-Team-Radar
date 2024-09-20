<h1 align="center">Team Fortress 2 Team Radar</h1>

The TF2 Team Radar plugin creates a simple, real-time radar display for each player, showing the positions of their teammates relative to their own position. 

The radar uses SourceMod's HUD text functionality for rendering, making it a lightweight solution that doesn't require any client-side modifications.

> [!NOTE]
> **This plugin primarily shows teammates** and was originally designed for team coordination and awareness in a practicing environment (Comp coaching/scrims). **It does not provide information about enemy positions, except for disguised Spies when enabled by admins.**

## Features

1. **Radar Display**:
   - Shows teammates as colored dots on a customizable radar display
   - Represents the player as a yellow up-facing arrow (▲) in the center
   - Radar position is adjustable and settings are saved per player
   - Toggle the radar on/off with `!radar` or `sm_radar` command

2. **Health Indication**:
   - Teammate dots change color based on health:
     - Green: Above 50% health
     - Red: 50% health or below

3. **Dynamic Updates**:
   - Radar updates at regular intervals (customizable through config file)
   - Calculates and displays relative positions of all teammates
   - Rotates based on player's view angle, keeping "up" aligned with player's facing direction

4. **Range Limitation**:
   - Only teammates within a certain range are displayed (customizable through config file)

5. **Pinging System**:
   - Players can mark locations on the radar for their teammates
   - Use `!mapping` or `sm_mapping` to ping (tip: `bind <key> "say /mapping"`)
   - Pings appear as yellow exclamation marks (!) on the radar
   - Pings last for 5 seconds with a 3-second cooldown

6. **Admin Features**:
   - Toggle visibility of disguised enemy Spies globally on the radar
   - Reload radar configuration on-the-fly with `!reloadradar` or through the radar menu

7. **Initialization**:
   - Radar is automatically enabled for players upon connecting

## Requirements

- The latest [SourceMod](https://www.sourcemod.net/downloads.php) release.

## Installation

1. Download the latest `team_radar.smx` from the [Releases](https://github.com/vexx-sm/tf2-team-radar/releases) page.

2. Place it in your plugins folder `addons/sourcemod/plugins`.

3. Reload the plugin or restart your server.

## Configuration

Edit the config file `tf2_team_radar.cfg` in your `addons/sourcemod/configs/` directory.
You can reload the configuration in-game using the `!reloadradar` command or in the `!radar` menu (admin only).

## License & Contributing

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

**Requests** & Contributions are welcome! Feel free to submit a Pull Request.