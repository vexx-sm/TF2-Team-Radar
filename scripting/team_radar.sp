#include <sourcemod>
#include <sdktools>
#include <tf2>
#include <tf2_stocks>

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

public Plugin myinfo = {
    name = "TF2 Team Radar",
    author = "vexx-sm",
    description = "Adds a basic team-only radar to Team Fortress 2 servers running SourceMod",
    version = "1.0",
    url = "https://github.com/vexx-sm/tf2-team-radar"
};

Handle g_hUpdateTimer;
bool g_bRadarEnabled[MAXPLAYERS + 1] = {true, ...};

public void OnPluginStart() {
    g_hUpdateTimer = CreateTimer(UPDATE_INTERVAL, Timer_UpdateMiniMap, _, TIMER_REPEAT);
    RegConsoleCmd("sm_radar", Command_ToggleRadar, "Toggle the radar on/off");
}

public void OnPluginEnd() {
    delete g_hUpdateTimer;
}

public void OnClientConnected(int client) {
    g_bRadarEnabled[client] = true;
}

public Action Command_ToggleRadar(int client, int args) {
    if (client == 0) {
        ReplyToCommand(client, "This command can only be used in-game.");
        return Plugin_Handled;
    }

    g_bRadarEnabled[client] = !g_bRadarEnabled[client];
    ReplyToCommand(client, "Radar has been %s.", g_bRadarEnabled[client] ? "enabled" : "disabled");
    return Plugin_Handled;
}

public Action Timer_UpdateMiniMap(Handle timer) {
    for (int i = 1; i <= MaxClients; i++) {
        if (IsValidClient(i) && IsClientInGame(i) && g_bRadarEnabled[i]) {
            UpdateMiniMap(i);
        }
    }
    return Plugin_Continue;
}

void UpdateMiniMap(int client) {
    if (!IsPlayerAlive(client)) return;

    float playerPos[3], playerAng[3];
    GetClientAbsOrigin(client, playerPos);
    GetClientAbsAngles(client, playerAng);

    float x = RADAR_X;
    float y = RADAR_Y;
    float w = RADAR_SCALE;
    float h = RADAR_SCALE;
    
    DrawPanel(client, x, y);

    for (int i = 1; i <= MaxClients; i++) {
        if (IsValidClient(i) && IsClientInGame(i) && IsPlayerAlive(i) && GetClientTeam(i) == GetClientTeam(client)) {
            float targetPos[3], relativePos[3];
            GetClientAbsOrigin(i, targetPos);
            SubtractVectors(targetPos, playerPos, relativePos);

            // Adjust this value to change radar rotation
            float angle = ThisDegToRad(-playerAng[1] - 270);
            float rotatedX = relativePos[0] * Cosine(angle) - relativePos[1] * Sine(angle);
            float rotatedY = relativePos[0] * Sine(angle) + relativePos[1] * Cosine(angle);

            float dotX = x + (w / 2) + (rotatedX / RADAR_SIZE) * w;
            float dotY = y + (h / 2) - (rotatedY / RADAR_SIZE) * h;

            if (dotX >= x && dotX <= x + w && dotY >= y && dotY <= y + h) {
                int color[4];
                if (i == client) {
                    color = COLOR_SELF;
                } else {
                    color = COLOR_TEAMMATE;
                }
                DrawDot(client, dotX, dotY, color);
            }
        }
    }
}

void DrawPanel(int client, float x, float y) {
    Handle hud = CreateHudSynchronizer();
    
    SetHudTextParams(x, y, UPDATE_INTERVAL + 0.1, 255, 255, 255, 0);	// Customize the color and alpha of the radar background here
    ShowSyncHudText(client, hud, "⠀");	// Invisable character "⠀" 
    delete hud;

    int clients[1];
    clients[0] = client;
    
    Handle message = StartMessageEx(GetUserMessageId("VGUIMenu"), clients, 1);
    BfWriteString(message, "radar_background");							// Customize the radar background material here
    BfWriteByte(message, true);
    BfWriteByte(message, 0);
    EndMessage();
}

void DrawDot(int client, float x, float y, int color[4]) {
    Handle hud = CreateHudSynchronizer();
    SetHudTextParams(x, y, UPDATE_INTERVAL + 0.1, color[0], color[1], color[2], color[3]);
    ShowSyncHudText(client, hud, "•");									// Customize the dot character here
    delete hud;
}

bool IsValidClient(int client) {
    return (client > 0 && client <= MaxClients && IsClientConnected(client));
}

float ThisDegToRad(float degrees) {
    return degrees * 0.017453293;
}
