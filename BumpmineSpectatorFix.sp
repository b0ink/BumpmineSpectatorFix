#include <cstrike>
#include <multicolors>
#include <sdkhooks>
#include <sdktools>
#include <sourcemod>

#pragma newdecls required
#pragma semicolon 1

#define PREFIX "[SM]"

public Plugin myinfo =
{
	name = "Bumpmine Spectator Fix",
	author = "BOINK",
	description = "Diverts spectators from getting too close to a bumpmine and forces them to spectate the closest player",
	version = "1.0.0",
	url = "https://github.com/b0ink/BumpmineSpectatorFix"
};

float bumpmineLoc[3];
float clientLoc[3];
float playerLoc[3];

char classname[64];


float DistanceToNearestBumpmine(int client)
{

	GetClientAbsOrigin(client, clientLoc);

	float distanceToBeat = 999999.0;
	for(int i = MaxClients; i < GetMaxEntities(); i++)
	{
		if(
			IsValidEntity(i) &&
			IsValidEdict(i) &&
			GetEdictClassname(i, classname, sizeof(classname)) &&
			StrContains(classname, "bumpmine", false) != -1)
		{
			GetEntPropVector(i, Prop_Send, "m_vecOrigin", bumpmineLoc);
			if(GetVectorDistance(clientLoc, bumpmineLoc) < distanceToBeat)
			{
				distanceToBeat = GetVectorDistance(clientLoc, bumpmineLoc);
			}
		}
	}
	return distanceToBeat;
}


int GetClosestPlayer(int client)
{
	float dist = 999999.0;

	GetClientAbsOrigin(client, clientLoc);
	
	int target = -1;
	for(int i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i) && IsPlayerAlive(i))
		{
			GetClientAbsOrigin(i, playerLoc);
			if(GetVectorDistance(playerLoc, clientLoc) < dist)
			{
				dist = GetVectorDistance(playerLoc, clientLoc);
				target = i;
			}
		}
	}
	return target;
}

public void OnGameFrame()
{
	for(int i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i))
		{
			if(GetClientTeam(i) == CS_TEAM_SPECTATOR || !IsPlayerAlive(i))
			{
				if(DistanceToNearestBumpmine(i) <= 200 && GetEntProp(i, Prop_Send, "m_iObserverMode") == 6)
				{
					FakeClientCommand(i, "spec_player %N", GetClosestPlayer(i));
					CPrintToChat(i, "%s You can not go into freecam because you are too close to a bumpmine!", PREFIX);
				}
			}
		}	
	}
}