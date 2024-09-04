<h1 align="center">TF2 Team Radar</h1>

The TF2 Team Radar plugin creates a simple, real-time radar display for each player, showing the positions of their teammates relative to their own position. 

The radar uses SourceMod's HUD text functionality to render the dots, making it a lightweight solution that doesn't require any client-side modifications.

Note: This radar only shows teammates and is designed for team coordination and awareness in a practicing environment (Comp coaching/scrims). It does not provide any information about enemy positions.

<details>
<summary>‎Here's a breakdown of its functionality:</summary>

1. **Initialization**: When a player connects, the radar is automatically enabled for them.

2. **Regular Updates**: The plugin updates the radar display at regular intervals (default: every 0.1 seconds).

3. **Player Position Calculation**: For each update, the plugin:
   - Gets the position and angle of the player
   - Calculates the relative positions of all teammates

4. **Radar Display**: The plugin then:
   - Creates a radar background in the top-left corner of the screen
   - Represents each teammate as a dot on this radar

5. **Rotation**: The radar rotates based on the player's view angle, ensuring that "up" on the radar always corresponds to the direction the player is facing.

6. **Range Limitation**: Only teammates within a certain range (default: 2560 game units) are displayed on the radar.

</details>

## Features

- Displays teammates on a radar in the top-left corner of the screen
- Toggle radar on/off with `!radar` command
- Automatically enabled for players upon connection

## Requirements

- The latest [SourceMod](https://www.sourcemod.net/downloads.php) release.

## Installation

1. Download the latest plugin release from the [Releases](https://github.com/vexx-sm/tf2-team-radar/releases) page.
2. Place `team_radar.smx` in your plugins `addons/sourcemod/plugins` folder.
3. Reload the plugin or restart your server.

## Usage

- Use `!radar` or `sm_radar` to toggle the radar on/off.

## Customization

1. Download the latest `team_radar.sp` from the [Releases](https://github.com/vexx-sm/tf2-team-radar/releases) page.

2. Edit these commented lines:

```
#pragma newdecls required

// Core settings
#define UPDATE_INTERVAL 0.1	// How often the radar updates (in seconds)
#define RADAR_SIZE 2560.0	// The in-game units the radar covers
#define RADAR_SCALE 0.225	// The size of the radar on the screen (0-1)

// Colors (RGBA format)
#define COLOR_SELF {255, 255, 0, 255}		// Player Color
#define COLOR_TEAMMATE {0, 255, 0, 255}		// Teammates color

// Radar position
#define RADAR_X 0.01	// X position of the radar (0-1)
#define RADAR_Y 0.01	// Y position of the radar (0-1)
```


3. Compile.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
