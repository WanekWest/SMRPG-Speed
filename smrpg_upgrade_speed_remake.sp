#pragma semicolon 1
#pragma newdecls required
#include <sdktools>
#include <dhooks>
#include <smrpg>

#define UPGRADE_SHORTNAME "speed"

public Plugin myinfo = 
{
	name = "SM:RPG Upgrade > Speed+ Remake",
	author = "WanekWest",
	description = "Speed+ upgrade for SM:RPG. Increase your default moving speed.",
	version = SMRPG_VERSION,
	url = "http://www.wcfan.de/"
}

ConVar g_hCVPercent;

float g_hSpeedValue;

int m_flLaggedMovementValue;

public void OnPluginStart()
{
	m_flLaggedMovementValue = FindSendPropInfo("CCSPlayer", "m_flLaggedMovementValue");
	LoadTranslations("smrpg_stock_upgrades.phrases");
}

public void OnPluginEnd()
{
	if (SMRPG_UpgradeExists(UPGRADE_SHORTNAME))
		SMRPG_UnregisterUpgradeType(UPGRADE_SHORTNAME);
}

public void OnAllPluginsLoaded()
{
	OnLibraryAdded("smrpg");
}

public void OnLibraryAdded(const char[] name)
{
	if (StrEqual(name, "smrpg"))
	{
		SMRPG_RegisterUpgradeType("Speed+", UPGRADE_SHORTNAME, "Increase your average movement speed.", 0, true, 10, 2700, 1600);
		SMRPG_SetUpgradeTranslationCallback(UPGRADE_SHORTNAME, SMRPG_TranslateUpgrade);
		g_hCVPercent = SMRPG_CreateUpgradeConVar(UPGRADE_SHORTNAME, "smrpg_speed_percent", "0.9", "Value which will be add(Value*Level)", _, true, 0.0, true, 1.0);
		g_hCVPercent.AddChangeHook(OnSpeedValueChange);
		g_hSpeedValue = g_hCVPercent.FloatValue;
	}
}

public void OnSpeedValueChange(ConVar hCvar, const char[] szOldValue, const char[] szNewValue)
{
	g_hSpeedValue = hCvar.FloatValue;
}

public void SMRPG_TranslateUpgrade(int client, const char[] shortname, TranslationType type, char[] translation, int maxlen)
{
	if (type == TranslationType_Name)
		Format(translation, maxlen, "%T", UPGRADE_SHORTNAME, client);
	else if (type == TranslationType_Description)
	{
		char sDescriptionKey[MAX_UPGRADE_SHORTNAME_LENGTH+12] = UPGRADE_SHORTNAME;
		StrCat(sDescriptionKey, sizeof(sDescriptionKey), " description");
		Format(translation, maxlen, "%T", sDescriptionKey, client);
	}
}

public void VIP_OnPlayerSpawn(int iClient, int iTeam, bool bIsVIP)
{
	int iLevel = SMRPG_GetClientUpgradeLevel(iClient, UPGRADE_SHORTNAME);
	if (iLevel > 0)
		SetClientSpeed(iClient, iLevel);
}

void SetClientSpeed(int iClient, int iLevel)
{
	if (iClient && IsClientInGame(iClient) && !IsClientObserver(iClient) && !IsClientSourceTV(iClient) && IsPlayerAlive(iClient))
	{
		SetEntPropFloat(iClient, Prop_Data, "m_flLaggedMovementValue", GetEntDataFloat(iClient, m_flLaggedMovementValue) + iLevel * g_hSpeedValue);
		PrintToChat(iClient, "Вы одели ботинки ФЛЕША!");
	}
}
