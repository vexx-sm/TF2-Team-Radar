#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <tf2>
#include <tf2_stocks>

#pragma newdecls required


//╭──────────────────────────────────.★..─╮

// Core Settings
#define UPDATE_INTERVAL 0.1 // How often the radar updates (in seconds)
#define RADAR_SIZE 2560.0 // The in-game units the radar covers
#define RADAR_SCALE 0.225 // The size of the radar on the screen (0-1)

// Colors (RGBA format)
#define COLOR_SELF {255, 255, 0, 255} // Yellow
#define COLOR_TEAMMATE_HEALTHY {0, 255, 0, 255} // Green
#define COLOR_TEAMMATE_LOW {255, 0, 0, 255} // Red
#define COLOR_PING {255, 255, 0, 255} // Yellow

// Customizable radar position
#define RADAR_X 0.01 // X position of the radar (0-1)
#define RADAR_Y 0.01 // Y position of the radar (0-1)

// Ping system settings
#define MAX_PINGS 5			
#define PING_DURATION 5.0
#define PING_COOLDOWN 3.0

//╰─..★.───────────────────────────────────╯


public Plugin myinfo = {
    name = "TF2 Team Radar",
    author = "vexx-sm",
    description = "Adds a basic team-only radar to Team Fortress 2.",
    version = "1.2",
    url = "https://github.com/vexx-sm/tf2-team-radar"
};

Handle g_hUpdateTimer;
bool g_bRadarEnabled[MAXPLAYERS + 1] = {true, ...};
float g_PingPositions[MAXPLAYERS + 1][MAX_PINGS][3];
float g_PingTimes[MAXPLAYERS + 1][MAX_PINGS];
float g_LastPingTime[MAXPLAYERS + 1];

public void OnPluginStart() {
    g_hUpdateTimer = CreateTimer(UPDATE_INTERVAL, Timer_UpdateMiniMap, _, TIMER_REPEAT);
    RegConsoleCmd("sm_radar", Command_ToggleRadar, "Toggle the radar on/off");
    RegConsoleCmd("sm_mapping", Command_Ping, "Ping the location you're looking at.");
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

public Action Command_Ping(int client, int args)
{
    if (!IsValidClient(client) || !IsPlayerAlive(client))
        return Plugin_Handled;

    float currentTime = GetGameTime();
    if (currentTime - g_LastPingTime[client] < PING_COOLDOWN)
    {
        PrintToChat(client, "You must wait before pinging again.");
        return Plugin_Handled;
    }

    float eyePos[3], eyeAng[3], endPos[3];
    GetClientEyePosition(client, eyePos);
    GetClientEyeAngles(client, eyeAng);
    
    TR_TraceRayFilter(eyePos, eyeAng, MASK_SOLID, RayType_Infinite, TraceEntityFilterPlayer, client);
    
    if (TR_DidHit())
    {
        TR_GetEndPosition(endPos);
        
        // Find the oldest ping slot and replace it
        int oldestIndex = 0;
        float oldestTime = g_PingTimes[client][0];
        for (int i = 1; i < MAX_PINGS; i++)
        {
            if (g_PingTimes[client][i] < oldestTime)
            {
                oldestIndex = i;
                oldestTime = g_PingTimes[client][i];
            }
        }

        g_PingPositions[client][oldestIndex] = endPos;
        g_PingTimes[client][oldestIndex] = currentTime;
        g_LastPingTime[client] = currentTime;

        PrintToTeam(client, "Teammate has pinged a location!");
    }
    else
    {
        PrintToChat(client, "Couldn't find a valid position to ping.");
    }

    return Plugin_Handled;
}

public bool TraceEntityFilterPlayer(int entity, int contentsMask, any data)
{
    return entity != data;
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
    float centerX = x + (w / 2);
    float centerY = y + (h / 2);
    
    DrawPanel(client, x, y);
    
    int selfColor[4] = COLOR_SELF;
    DrawArrow(client, centerX, centerY, selfColor);

    float currentTime = GetGameTime();

    for (int i = 1; i <= MaxClients; i++) {
        if (i != client && IsValidClient(i) && IsClientInGame(i) && IsPlayerAlive(i) && GetClientTeam(i) == GetClientTeam(client)) {
            float targetPos[3], relativePos[3];
            GetClientAbsOrigin(i, targetPos);
            SubtractVectors(targetPos, playerPos, relativePos);

            float angle = ThisDegToRad(-playerAng[1] - 270);
            float rotatedX = relativePos[0] * Cosine(angle) - relativePos[1] * Sine(angle);
            float rotatedY = relativePos[0] * Sine(angle) + relativePos[1] * Cosine(angle);

            float dotX = centerX + (rotatedX / RADAR_SIZE) * w;
            float dotY = centerY - (rotatedY / RADAR_SIZE) * h;

            if (dotX >= x && dotX <= x + w && dotY >= y && dotY <= y + h) {
                int health = GetClientHealth(i);
                int maxHealth = GetEntProp(i, Prop_Data, "m_iMaxHealth");
                float healthPercentage = float(health) / float(maxHealth);
                
                int color[4];
                if (healthPercentage <= 0.5) {
                    color = COLOR_TEAMMATE_LOW;
                } else {
                    color = COLOR_TEAMMATE_HEALTHY;
                }
                DrawDot(client, dotX, dotY, color);
            }
        }
    }

    // Draw pings
    int pingColor[4] = COLOR_PING;
    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsValidClient(i) && IsClientInGame(i) && GetClientTeam(i) == GetClientTeam(client))
        {
            for (int j = 0; j < MAX_PINGS; j++)
            {
                if (currentTime - g_PingTimes[i][j] < PING_DURATION)
                {
                    float pingPos[3], relativePos[3];
                    pingPos = g_PingPositions[i][j];
                    SubtractVectors(pingPos, playerPos, relativePos);

                    float angle = ThisDegToRad(-playerAng[1] - 270);
                    float rotatedX = relativePos[0] * Cosine(angle) - relativePos[1] * Sine(angle);
                    float rotatedY = relativePos[0] * Sine(angle) + relativePos[1] * Cosine(angle);

                    float pingX = centerX + (rotatedX / RADAR_SIZE) * w;
                    float pingY = centerY - (rotatedY / RADAR_SIZE) * h;

                    if (pingX >= x && pingX <= x + w && pingY >= y && pingY <= y + h)
                    {
                        DrawPing(client, pingX, pingY, pingColor);
                    }
                }
            }
        }
    }
}


void DrawPanel(int client, float x, float y) {
    Handle hud = CreateHudSynchronizer();
    SetHudTextParams(x, y, UPDATE_INTERVAL + 0.1, 255, 255, 255, 0);
    ShowSyncHudText(client, hud, "");
    delete hud;

    int clients[1];
    clients[0] = client;
    
    Handle message = StartMessageEx(GetUserMessageId("VGUIMenu"), clients, 1);
    BfWriteString(message, "radar_background");
    BfWriteByte(message, true);
    BfWriteByte(message, 0);
    EndMessage();
}

void DrawDot(int client, float x, float y, int color[4]) {
    Handle hud = CreateHudSynchronizer();
    SetHudTextParams(x, y, UPDATE_INTERVAL + 0.1, color[0], color[1], color[2], color[3]);
    ShowSyncHudText(client, hud, "•");
    delete hud;
}

void DrawArrow(int client, float x, float y, int color[4]) {
    Handle hud = CreateHudSynchronizer();
    SetHudTextParams(x, y, UPDATE_INTERVAL + 0.1, color[0], color[1], color[2], color[3]);
    ShowSyncHudText(client, hud, "▲");
    delete hud;
}

void DrawPing(int client, float x, float y, int color[4])
{
    Handle hud = CreateHudSynchronizer();
    SetHudTextParams(x, y, UPDATE_INTERVAL + 0.1, color[0], color[1], color[2], color[3]);
    ShowSyncHudText(client, hud, "!");
    delete hud;
}


void PrintToTeam(int client, const char[] message)
{
    int team = GetClientTeam(client);
    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsValidClient(i) && IsClientInGame(i) && GetClientTeam(i) == team)
        {
            PrintToChat(i, message);
        }
    }
}

bool IsValidClient(int client) {
    return (client > 0 && client <= MaxClients && IsClientConnected(client));
}

float ThisDegToRad(float degrees) {
    return degrees * 0.017453293;
}
