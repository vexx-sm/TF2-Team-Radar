<h1 align="center">Team Fortress 2 Team Radar</h1>

The TF2 Team Radar plugin creates a simple, real-time radar display for each player, showing the positions of their teammates relative to their own position. 

The radar uses SourceMod's HUD text functionality for rendering, making it a lightweight solution that doesn't require any client-side modifications.

>[!NOTE]

> **This plugin primarily shows teammates** and was originally designed for team coordination and awareness in a practicing environment (Comp coaching/scrims). **It does not provide information about enemy positions, except for disguised Spies when enabled by admins.**

<details>

<summary>‎ <ins>Here's a breakdown of its functionality;</ins> </summary>

1. **Initialization**: When a player connects, the radar is automatically enabled for them.

2. **Regular Updates**: The plugin updates the radar display at regular intervals (Customizable through config file).

3. **Player Position Calculation**: For each update, the plugin:

   - Gets the position and angle of the player

   - Calculates the relative positions/health of all teammates

4. **Radar Display**: The plugin then:

   - Creates a radar background in a customizable position on the screen

   - Represents the player as a yellow up-facing arrow (▲) in the center of the radar

   - Shows teammates as dots on the radar

   - Teammate dots are green when above 50% health, and red when at or below 50% health

5. **Rotation**: The radar rotates based on the player's view angle, ensuring that "up" on the radar always corresponds to the direction the player is facing.

6. **Range Limitation**: Only teammates within a certain range are displayed on the radar. (Customizable through config file)

</details>

## Features

- Displays teammates on a radar in a customizable position on the screen

- Customize the radar's position and Toggle with `!radar` or `sm_radar` command, Settings are per player and are saved between sessions.

- Teammate dots change color based on health:

  - Green: Above 50% health

  - Red: 50% health or below

- Pinging system where players can mark locations on the radar for their teammates

  - Use `!mapping` or `sm_mapping` to ping the location you're looking at, ideally use `bind <key> "say /mapping"`.

  - Pings appear as yellow exclamation marks (!) on the radar

  - Pings last for 5 seconds and have a 3-second cooldown

- Admin-only features:

  - Toggle showing disguised enemy Spies globally on the radar 

  - Reload radar configuration on-the-fly with `!reloadradar` or through the radar menu

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