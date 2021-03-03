enum struct Survivor {
  char name[32];
  char model[PLATFORM_MAX_PATH];
  int prop;
  int custom;
  char adminflags[16];
}

Survivor g_Survivors[64];
int g_iSurvivorsCount = 0;

void browseKeyValues(KeyValues kv, Survivor[] survivors)
{
	kv.GotoFirstSubKey();

	do
	{
		Survivor s;
		kv.GetSectionName(s.name, sizeof(s.name));
		kv.GetString("model", s.model, sizeof(s.model));
		s.prop = kv.GetNum("prop");
		s.custom = kv.GetNum("custom");
		kv.GetString("adminflags", s.adminflags, sizeof(s.adminflags));
			
		survivors[g_iSurvivorsCount] = s;
	
		g_iSurvivorsCount++;

	} while (kv.GotoNextKey(false));
}

	
void loadSurvivorsFromConfigFile(const char[] filepath)
{
	char path[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, path, sizeof(path), filepath);
	KeyValues kv = new KeyValues("Survivors");

	if (kv.ImportFromFile(path))
	{
		browseKeyValues(kv, g_Survivors);
	}
	else
	{
		LogError("Unable to read %s as KV file. Make sure it's properly formatted.", path);
	}

	delete kv;
}

void precacheModels()  
{
	SetConVarInt(FindConVar("precache_all_survivors"), 1);

	for (int i = 0; i < g_iSurvivorsCount; i++) {
		if (!IsModelPrecached(g_Survivors[i].model))    
			PrecacheModel(g_Survivors[i].model, false);
	}
}

void debugPrintLoadedModels()  
{
	for (int i = 0; i < g_iSurvivorsCount; i++) {
		PrintToServer("%s %s %i", g_Survivors[i].name, g_Survivors[i].model, g_Survivors[i].prop);
	}
}
