enum struct Survivor {
  char name[MAX_NAME_LENGTH];
  char model[PLATFORM_MAX_PATH];
  int prop;
  char adminflags[16];
}

ArrayList g_Survivors;

void SCS_BrowseKeyValues(KeyValues kv)
{
	kv.GotoFirstSubKey();

	do
	{
		Survivor s;
		kv.GetSectionName(s.name, sizeof(s.name));
		kv.GetString("model", s.model, sizeof(s.model));
		s.prop = kv.GetNum("prop");
		kv.GetString("adminflags", s.adminflags, sizeof(s.adminflags));
			
		g_Survivors.PushArray(s);

	} while (kv.GotoNextKey(false));
}

	
void LoadSurvivorsFromConfigFile(const char[] filepath)
{
	char path[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, path, sizeof(path), filepath);
	KeyValues kv = new KeyValues("Survivors");

	if (kv.ImportFromFile(path))
	{
		SCS_BrowseKeyValues(kv);
	}
	else
	{
		LogError("Unable to read %s as KV file. Make sure it's properly formatted.", path);
	}

	delete kv;
}

void PrecacheModels()
{
	SetConVarInt(FindConVar("precache_all_survivors"), 1);

	for (int i = 0; i < g_Survivors.Length; i++) {
		Survivor s; g_Survivors.GetArray(i, s);
		if (!IsModelPrecached(s.model))
			PrecacheModel(s.model, false);
	}
}

void __DebugPrintLoadedModels()
{
	for (int i = 0; i < g_Survivors.Length; i++) {
		Survivor s; g_Survivors.GetArray(i, s);
		PrintToServer("%s %s %i", s.name, s.model, s.prop);
	}
}
