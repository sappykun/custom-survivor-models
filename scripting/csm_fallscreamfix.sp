#include <sourcemod>
#include <sdktools>
#include <regex>

ConVar gCvarBuffer;
Handle g_hFallVoiceRegex;
int g_iSurvivorSet;
char g_sSurvivorVoicePaths[8][] = {	"gambler", "producer", "coach", "mechanic",
									"namvet", "teengirl", "biker", "manager" };

public Plugin myinfo =
{
	name = "CSM Fall Scream Fix",
	author = "Sappykun",
	description = "Quick and dirty hack for falling survivor screams in CSM",
	version = "1.0.0",
	url = ""
}

public void OnPluginStart()
{
	g_hFallVoiceRegex = CompileRegex("player/survivor/voice/\\w+/fall(\\d+).wav", PCRE_CASELESS);
	gCvarBuffer = CreateConVar("sm_vscript_return", "", "Buffer used to return vscript values. Do not use.");
	AddNormalSoundHook(SoundScreamFix);
}

public void OnMapStart()
{
	g_iSurvivorSet = GetSurvivorSet();
}

// quick hack for bug where falling screams are randomized when
// a player's model doesn't match the netprop
// adapted from https://forums.alliedmods.net/showthread.php?p=2677958 by Edison1318
// TODO: Why does this happen? Can it be fixed?

public Action SoundScreamFix(int clients[MAXPLAYERS], int &numClients, char sample[PLATFORM_MAX_PATH], int &entity, int &channel, float &volume, int &level, int &pitch, int &flags, char soundEntry[PLATFORM_MAX_PATH], int &seed)
{
	if (entity <= 0 || entity > 4096 || entity > MaxClients) {
		return Plugin_Continue;
	}

	if (MatchRegex(g_hFallVoiceRegex, sample) > 0) {
		int prop = GetEntProp(entity, Prop_Send, "m_survivorCharacter", 0);

		if (g_iSurvivorSet == 1) {
			switch (prop) {
				case 0: prop = 4; // Nick to Bill
				case 1: prop = 5; // Rochelle to Zoey
				case 2: prop = 7; // Coach to Louis
				case 3: prop = 6; // Ellis to Francis
			}
		}

		char number[PLATFORM_MAX_PATH]; GetRegexSubString(g_hFallVoiceRegex, 1, number, PLATFORM_MAX_PATH);
		Format(sample, sizeof(sample), "player/survivor/voice/%s/fall%s.wav", g_sSurvivorVoicePaths[prop], number);

		return Plugin_Changed;
	}

	return Plugin_Continue;
}

// Adapted from https://forums.alliedmods.net/showthread.php?t=317145
// Credit to Silvers
// Why is there no easy way to do this?

public int GetSurvivorSet()
{
	char buffer[128] = "Director.GetSurvivorSet()";
	GetVScriptOutput(buffer, buffer, sizeof buffer);
	return StringToInt(buffer);
}

public bool GetVScriptOutput(char[] code, char[] buffer, int maxlength)
{
	static int logic = INVALID_ENT_REFERENCE;
	if( logic == INVALID_ENT_REFERENCE || !IsValidEntity(logic) )
	{
		logic = EntIndexToEntRef(CreateEntityByName("logic_script"));
		if( logic == INVALID_ENT_REFERENCE || !IsValidEntity(logic) )
			SetFailState("Could not create 'logic_script'");

		DispatchSpawn(logic);
	}

	// Return values between <RETURN> </RETURN>
	int pos = StrContains(code, "<RETURN>");
	if( pos != -1 )
	{
		strcopy(buffer, maxlength, code);
		// If wrapping in quotes is required, use these two lines instead.
		// ReplaceString(buffer, maxlength, "</RETURN>", " + \"\");");
		// ReplaceString(buffer, maxlength, "<RETURN>", "Convars.SetValue(\"sm_vscript_return\", \"\" + ");
		ReplaceString(buffer, maxlength, "</RETURN>", ");");
		ReplaceString(buffer, maxlength, "<RETURN>", "Convars.SetValue(\"sm_vscript_return\", ");
	}
	else
	{
		Format(buffer, maxlength, "Convars.SetValue(\"sm_vscript_return\", \"\" + %s + \"\");", code);
	}

	// Run code
	SetVariantString(buffer);
	AcceptEntityInput(logic, "RunScriptCode");
	AcceptEntityInput(logic, "Kill");

	// Retrieve value and return to buffer
	gCvarBuffer.GetString(buffer, maxlength);
	gCvarBuffer.SetString("");

	if( buffer[0] == '\x0')
		return false;
	return true;
}
