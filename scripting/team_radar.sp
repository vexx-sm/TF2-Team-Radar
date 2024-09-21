#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <tf2>
#include <tf2_stocks>
#include <clientprefs>

#pragma newdecls required

#define CONFIG_FILE "configs/tf2_team_radar.cfg"

int g_ColorSelf[4] = {255, 255, 0, 255};
int g_ColorTeammateHealthy[4] = {0, 255, 0, 255};
int g_ColorTeammateLow[4] = {255, 0, 0, 255};
int g_ColorPing[4] = {255, 255, 0, 255};

// Will be moved to the cfg
#define MAX_PINGS 5			
#define PING_DURATION 5.0
#define PING_COOLDOWN 3.0

#define max(%1,%2) (((%1) > (%2)) ? (%1) : (%2))
#define min(%1,%2) (((%1) < (%2)) ? (%1) : (%2))
#define RADAR_X 0.01 // Default position of the radar
#define RADAR_Y 0.01 // Default position of the radar
#define ELEVATION_THRESHOLD 150.0  // Units to consider a significant elevation difference

char g_ElevationIcons[3][] = {"▽", "●", "△"};  // Below, Same, Above

public Plugin myinfo = {
    name = "TF2 Team Radar",
    author = "vexx-sm",
    description = "Adds a basic team-only radar to Team Fortress 2.",
    version = "1.4.0",
    url = "https://github.com/vexx-sm/tf2-team-radar"
};

ConVar g_cvUpdateInterval;
ConVar g_cvRadarSize;
ConVar g_cvRadarScale;
ConVar g_cvShowDisguisedSpies;

Handle g_hUpdateTimer;
Handle g_hRadarXCookie;
Handle g_hRadarYCookie;

bool g_bRadarEnabled[MAXPLAYERS + 1] = {true, ...};
float g_PingPositions[MAXPLAYERS + 1][MAX_PINGS][3];
float g_PingTimes[MAXPLAYERS + 1][MAX_PINGS];
float g_LastPingTime[MAXPLAYERS + 1];
float g_fRadarX[MAXPLAYERS + 1] = {RADAR_X, ...};
float g_fRadarY[MAXPLAYERS + 1] = {RADAR_Y, ...};
float g_fPositionStep = 0.01; // The amount to move the radar each time

public void OnPluginStart() {
    LoadConfig();

    g_hUpdateTimer = CreateTimer(g_cvUpdateInterval.FloatValue, Timer_UpdateMiniMap, _, TIMER_REPEAT);
    RegConsoleCmd("sm_radar", Command_RadarMenu, "Open the radar menu");
    RegConsoleCmd("sm_pingradar", Command_Ping, "Ping your current location on the radar");
    RegAdminCmd("sm_reloadradar", Command_ReloadConfig, ADMFLAG_CONFIG, "Reload the Radar config");
    g_hRadarXCookie = RegClientCookie("tf2_team_radar_x", "Radar X Position", CookieAccess_Protected);
    g_hRadarYCookie = RegClientCookie("tf2_team_radar_y", "Radar Y Position", CookieAccess_Protected);
	
}

bool g_bConfigLoaded = false;

void LoadConfig() {
    g_bConfigLoaded = false;  // Reset the flag
    
    char configPath[PLATFORM_MAX_PATH];
    BuildPath(Path_SM, configPath, sizeof(configPath), CONFIG_FILE);

    if (!FileExists(configPath)) {
        LogError("Configuration file %s not found", configPath);
        return;
    }

    KeyValues kv = new KeyValues("TF2TeamRadar");
    if (!kv.ImportFromFile(configPath)) {
        LogError("Error loading configuration file %s", configPath);
        delete kv;
        return;
    }

    g_cvUpdateInterval = CreateConVar("sm_radar_update_interval", "0.1", "How often the radar updates (in seconds)");
    g_cvRadarSize = CreateConVar("sm_radar_size", "2560.0", "The in-game units the radar covers");
    g_cvRadarScale = CreateConVar("sm_radar_scale", "0.225", "The size of the radar on the screen (0-1)");

    g_cvUpdateInterval.SetFloat(kv.GetFloat("update_interval", 0.1));
    g_cvRadarSize.SetFloat(kv.GetFloat("radar_size", 2560.0));
    g_cvRadarScale.SetFloat(kv.GetFloat("radar_scale", 0.225));
	
    g_cvShowDisguisedSpies = CreateConVar("sm_radar_show_disguised_spies", "1", "Show disguised enemy spies on the radar (0 = No, 1 = Yes)");
    g_cvShowDisguisedSpies.SetBool(view_as<bool>(kv.GetNum("show_disguised_spies", 1)));


    char colorBuffer[16];

    kv.GetString("color_self", colorBuffer, sizeof(colorBuffer), "255 255 0 255");
    ParseColor(colorBuffer, g_ColorSelf);

    kv.GetString("color_teammate_healthy", colorBuffer, sizeof(colorBuffer), "0 255 0 255");
    ParseColor(colorBuffer, g_ColorTeammateHealthy);

    kv.GetString("color_teammate_low", colorBuffer, sizeof(colorBuffer), "255 0 0 255");
    ParseColor(colorBuffer, g_ColorTeammateLow);

    kv.GetString("color_ping", colorBuffer, sizeof(colorBuffer), "255 255 0 255");
    ParseColor(colorBuffer, g_ColorPing);

    delete kv;
    g_bConfigLoaded = true;  // Set the flag to indicate successful load
    LogMessage("Radar configuration loaded successfully.");
}

void ParseColor(const char[] colorString, int color[4]) {
    char parts[4][4];
    ExplodeString(colorString, " ", parts, sizeof(parts), sizeof(parts[]));
    
    for (int i = 0; i < 4; i++) {
        color[i] = StringToInt(parts[i]);
    }
}

public void OnPluginEnd() {
    delete g_hUpdateTimer;
}

public void OnClientConnected(int client) {
    g_bRadarEnabled[client] = true;
}

public void OnClientCookiesCached(int client)
{
    LoadRadarPosition(client);
}

void LoadRadarPosition(int client)
{
    char sValue[16];
    
    GetClientCookie(client, g_hRadarXCookie, sValue, sizeof(sValue));
    if (sValue[0] != '\0')
        g_fRadarX[client] = StringToFloat(sValue);
    else
        g_fRadarX[client] = RADAR_X;
    
    GetClientCookie(client, g_hRadarYCookie, sValue, sizeof(sValue));
    if (sValue[0] != '\0')
        g_fRadarY[client] = StringToFloat(sValue);
    else
        g_fRadarY[client] = RADAR_Y;
}

void SaveRadarPosition(int client)
{
    char sValue[16];
    
    FloatToString(g_fRadarX[client], sValue, sizeof(sValue));
    SetClientCookie(client, g_hRadarXCookie, sValue);
    
    FloatToString(g_fRadarY[client], sValue, sizeof(sValue));
    SetClientCookie(client, g_hRadarYCookie, sValue);
}

public Action Command_RadarMenu(int client, int args) {
    if (client == 0) {
        ReplyToCommand(client, "This command can only be used in-game.");
        return Plugin_Handled;
    }
    
    ShowRadarMenu(client);
    return Plugin_Handled;
}

void ShowRadarMenu(int client)
{
    Menu menu = new Menu(RadarMenuHandler);
    menu.SetTitle("Radar Menu");
    menu.AddItem("toggle", g_bRadarEnabled[client] ? "Disable Radar" : "Enable Radar");
    menu.AddItem("position", "Adjust Position");
    if (CheckCommandAccess(client, "sm_reloadradar", ADMFLAG_CONFIG))
    {
        menu.AddItem("reload", "Reload Configuration");
        char spiesInfo[64];
        FormatEx(spiesInfo, sizeof(spiesInfo), "Show Disguised Spies: %s", g_cvShowDisguisedSpies.BoolValue ? "On" : "Off");
        menu.AddItem("spies", spiesInfo);
    }
    menu.ExitButton = true;
    menu.Display(client, MENU_TIME_FOREVER);
}

void ShowPositionMenu(int client)
{
    Menu menu = new Menu(PositionMenuHandler);
    menu.SetTitle("Adjust Radar Position");
    menu.AddItem("up", "Move Up");
    menu.AddItem("down", "Move Down");
    menu.AddItem("left", "Move Left");
    menu.AddItem("right", "Move Right");
    menu.AddItem("reset", "Reset to Default");
    menu.ExitBackButton = true;
    menu.Display(client, MENU_TIME_FOREVER);
}

public int RadarMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
    switch (action)
    {
        case MenuAction_Select:
        {
            char info[32];
            menu.GetItem(param2, info, sizeof(info));
            
            if (StrEqual(info, "toggle"))
            {
                g_bRadarEnabled[param1] = !g_bRadarEnabled[param1];
                PrintToChat(param1, "Radar has been %s.", g_bRadarEnabled[param1] ? "enabled" : "disabled");
            }
            else if (StrEqual(info, "position"))
            {
                ShowPositionMenu(param1);
                return 0;
            }
            else if (StrEqual(info, "reload"))
            {
                FakeClientCommand(param1, "sm_reloadradar");
            }
            else if (StrEqual(info, "spies"))
            {
                g_cvShowDisguisedSpies.SetBool(!g_cvShowDisguisedSpies.BoolValue);
                PrintToChat(param1, "Show Disguised Spies: %s", g_cvShowDisguisedSpies.BoolValue ? "On" : "Off");
            }
            ShowRadarMenu(param1); // Show the menu again after any action
        }
        case MenuAction_End:
        {
            delete menu;
        }
    }
    return 0;
}


public int PositionMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
    switch (action)
    {
        case MenuAction_Select:
        {
            char info[32];
            menu.GetItem(param2, info, sizeof(info));
            
            if (StrEqual(info, "up"))
            {
                g_fRadarY[param1] = max(0.0, g_fRadarY[param1] - g_fPositionStep);
            }
            else if (StrEqual(info, "down"))
            {
                g_fRadarY[param1] = min(1.0 - g_cvRadarScale.FloatValue, g_fRadarY[param1] + g_fPositionStep);
            }
            else if (StrEqual(info, "left"))
            {
                g_fRadarX[param1] = max(0.0, g_fRadarX[param1] - g_fPositionStep);
            }
            else if (StrEqual(info, "right"))
            {
                g_fRadarX[param1] = min(1.0 - g_cvRadarScale.FloatValue, g_fRadarX[param1] + g_fPositionStep);
            }
            else if (StrEqual(info, "reset"))
            {
                g_fRadarX[param1] = RADAR_X;
                g_fRadarY[param1] = RADAR_Y;
            }
            
            SaveRadarPosition(param1);
            ShowPositionMenu(param1);
        }
        case MenuAction_Cancel:
        {
            if (param2 == MenuCancel_ExitBack || param2 == MenuCancel_Exit)
            {
                PrintToChat(param1, "Radar position updated and saved.");
                if (param2 == MenuCancel_ExitBack)
                {
                    ShowRadarMenu(param1);
                }
            }
        }
        case MenuAction_End:
        {
            delete menu;
        }
    }
    return 0;
}

public Action Command_ReloadConfig(int client, int args)
{
    LogMessage("Reloading radar configuration...");
    LoadConfig();
    if (g_bConfigLoaded)
    {
        ReplyToCommand(client, "[Radar] Configuration reloaded successfully.");
        
        // Recreate the timer with the new update interval
        delete g_hUpdateTimer;
        g_hUpdateTimer = CreateTimer(g_cvUpdateInterval.FloatValue, Timer_UpdateMiniMap, _, TIMER_REPEAT);
    }
    else
    {
        ReplyToCommand(client, "[Radar] Failed to reload configuration. Check server logs for details.");
    }
    
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

void DrawElevationIcon(int client, float x, float y, int color[4], const char[] icon) {
    Handle hud = CreateHudSynchronizer();
    SetHudTextParams(x, y, g_cvUpdateInterval.FloatValue + 0.1, color[0], color[1], color[2], color[3]);
    ShowSyncHudText(client, hud, icon);
    delete hud;
}

void UpdateMiniMap(int client) {
    if (!IsPlayerAlive(client)) return;

    float playerPos[3], playerAng[3];
    GetClientAbsOrigin(client, playerPos);
    GetClientAbsAngles(client, playerAng);

    float x = g_fRadarX[client];
    float y = g_fRadarY[client];
    float w = g_cvRadarScale.FloatValue;
    float h = g_cvRadarScale.FloatValue;
    float centerX = x + (w / 2);
    float centerY = y + (h / 2);
    
    DrawPanel(client, x, y);
    
    DrawArrow(client, centerX, centerY, g_ColorSelf);
        
    float currentTime = GetGameTime();
    for (int i = 1; i <= MaxClients; i++) {
        if (i != client && IsValidClient(i) && IsClientInGame(i) && IsPlayerAlive(i)) {
            int clientTeam = GetClientTeam(client);
            int targetTeam = GetClientTeam(i);
            bool shouldShow = false;

            // Check if the player is a teammate
            if (targetTeam == clientTeam) {
                shouldShow = true;
            }
            // Check if the player is an enemy Spy disguised as a teammate
            else if (g_cvShowDisguisedSpies.BoolValue && TF2_GetPlayerClass(i) == TFClass_Spy && TF2_IsPlayerInCondition(i, TFCond_Disguised)) {
                int disguiseTeam = GetEntProp(i, Prop_Send, "m_nDisguiseTeam");
                if (disguiseTeam == clientTeam) {
                    shouldShow = true;
                }
            }

            if (shouldShow) {
                float targetPos[3], relativePos[3];
                GetClientAbsOrigin(i, targetPos);
                SubtractVectors(targetPos, playerPos, relativePos);

                float angle = ThisDegToRad(-playerAng[1] - 270);
                float rotatedX = relativePos[0] * Cosine(angle) - relativePos[1] * Sine(angle);
                float rotatedY = relativePos[0] * Sine(angle) + relativePos[1] * Cosine(angle);

                float dotX = centerX + (rotatedX / g_cvRadarSize.FloatValue) * w;
                float dotY = centerY - (rotatedY / g_cvRadarSize.FloatValue) * h;

                if (dotX >= x && dotX <= x + w && dotY >= y && dotY <= y + h) {
                    int health = GetClientHealth(i);
                    int maxHealth = GetEntProp(i, Prop_Data, "m_iMaxHealth");
                    float healthPercentage = float(health) / float(maxHealth);
                    
                    int color[4];
                    if (healthPercentage <= 0.5) {
                        color = g_ColorTeammateLow;
                    } else {
                        color = g_ColorTeammateHealthy;
                    }

                    // Calculate elevation difference
                    float elevationDiff = targetPos[2] - playerPos[2];
                    int elevationIndex = 1;  // Default to same level
                    if (elevationDiff > ELEVATION_THRESHOLD) {
                        elevationIndex = 2;  // Above
                    } else if (elevationDiff < -ELEVATION_THRESHOLD) {
                        elevationIndex = 0;  // Below
                    }

                    DrawElevationIcon(client, dotX, dotY, color, g_ElevationIcons[elevationIndex]);
                }
            }
        }
    }

    // Draw pings
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
                    float pingX = centerX + (rotatedX / g_cvRadarSize.FloatValue) * w;
                    float pingY = centerY - (rotatedY / g_cvRadarSize.FloatValue) * h;
                    if (pingX >= x && pingX <= x + w && pingY >= y && pingY <= y + h)
                    {
                        DrawPing(client, pingX, pingY, g_ColorPing);
                    }
                }
            }
        }
    }
}

void DrawPanel(int client, float x, float y) {
    Handle hud = CreateHudSynchronizer();
    SetHudTextParams(x, y, g_cvUpdateInterval.FloatValue + 0.1, 255, 255, 255, 0);
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



void DrawArrow(int client, float x, float y, int color[4]) {
    Handle hud = CreateHudSynchronizer();
    SetHudTextParams(x, y, g_cvUpdateInterval.FloatValue + 0.1, color[0], color[1], color[2], color[3]);
    ShowSyncHudText(client, hud, "⮝");
    delete hud;
}

void DrawPing(int client, float x, float y, int color[4])
{
    Handle hud = CreateHudSynchronizer();
    SetHudTextParams(x, y, g_cvUpdateInterval.FloatValue + 0.1, color[0], color[1], color[2], color[3]);
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
