#include <sourcemod>
#include <sdktools>
#include <regex>

Handle g_hFallVoiceRegex;
char g_sSurvivorVoicePaths[8][] = {	"gambler", "producer", "coach", "mechanic",
									"namvet", "teengirl", "biker", "manager" };

public Plugin myinfo =
{
	name = "SCS2 Fall Scream Fix",
	author = "Sappykun",
	description = "Quick and dirty hack for falling survivor screams in SCS2",
	version = "1.0.0",
	url = ""
}

public void OnPluginStart()
{
	g_hFallVoiceRegex = CompileRegex("player/survivor/voice/\\w+/fall(\\d+).wav", PCRE_CASELESS);
	AddNormalSoundHook(SoundScreamFix);
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
		char number[PLATFORM_MAX_PATH]; GetRegexSubString(g_hFallVoiceRegex, 1, number, PLATFORM_MAX_PATH);
		Format(sample, sizeof(sample), "player/survivor/voice/%s/fall%s.wav", g_sSurvivorVoicePaths[prop], number);

		return Plugin_Changed;
	}

	return Plugin_Continue;
}