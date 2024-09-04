<h1 align="center">TF2 Team Radar

A lightweight SourceMod plugin that adds a basic team-only radar to Team Fortress 2.

Note: This used to be an addon for competitive coaching and can be used in controlled scrims for practice.

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

2. Customization is commented:

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
