# [L4D2] Custom Survivor Models

A Sourcemod plugin that allows you to change your model in-game. You can choose from all 8 available survivors on campaigns that use the L4D2 survivor set, and the 4 original survivors on campaigns that use the L4D1 survivor set.  The plugin will keep track of which model you select, even if you leave and rejoin.

This is a fork of
 
https://github.com/zrmdsxa/L4D2ModelChanger-edit by zrmdsxa, which is a fork of 

https://forums.alliedmods.net/showthread.php?p=2399163#post2399163 by Merudo, which is a fork of 

https://forums.alliedmods.net/showthread.php?t=107121 mi123645's Character Select Menu.

This particular fork adds:

- Easily configurable custom models beyond the 8 stock survivors
- Restricting models based on admin flags
- Forcing models onto players (does not save cookies)
- Model precaching to prevent server crashes from loading invalid models

## COMMANDS

`sm_csm`- Opens the character select menu.

`sm_forcemodel`/`sm_fm` - Forces a model onto a player for the remainder of the map. Admin only. 

## CVARS

`l4d_csm_botschange [0/1]` - Should new bots spawn as the least prevalent survivor?

`l4d_csm_cookies [0/1]` - Toggles cookie storage

`l4d_csm_zoey [0/1/2]` - Which prop does Zoey get? 0 is Rochelle (for Windows servers), 1 is Zoey (for Linux servers), 2 is Nick (for Windows servers with FakeZoey)

`l4d_csm_forcenetprops [0/1]` - Do we want to change the actual survivor (netprop) or just their model? Setting this to 0 fixes scoring issues in Versus.

## CONFIGURATION

A custom survivor config should look like the following:

```
"CustomModelConfig"
{
	"AdminFlags"
	{
		"My Custom Admin Guy"						"z"
	}
	"Survivors"
	{
		"My Custom Guy"						"models/csm/guy_v1/m.mdl"
		"My Custom Admin Guy"				"models/csm/guyadmin_v1/m.mdl"
	}
}
```

In this case, there will be two survivors added to CSM. My Custom Guy will show up for everyone. My Custom Admin Guy will only shown up for admins that have the "z" flag.

It is recommended to keep filenames as short as possible.  I would also recommend [Stringtable Cleanup](https://github.com/sappykun/stringtable-cleanup) if you plan on adding a lot of downloadables.

## TODO

- Implement configurable viewmodels for models that have them
- Find a way to implement custom HUDs for models that have them
- General code optimization and cleanup

## FAQ

Q) Can I add any model from the workshop?

A) No. Almost every L4D2 player model from the workshop will need to be recompiled for this plugin to use them correctly. Models from the workshop replace stock survivors, which overwrite existing game files. The model name must be unique for this plugin to detect them. Also, depending on the model, you should ask for permission to use it.


Q) I changed to Nick/Rochelle/Coach/Ellis, but got Bill/Zoey/Francis/Louis instead. What gives?

A) L4D2 survivors are only usable on campaigns that use the L4D2 survivors. If you're on a L4D1 campaign, only props 4-7 (the original survivors) are available.


Q) How do I send out the custom assets for my models?

A) This plugin doesn't handle that. You will need a fastdl server and something like [Easy Downloader](https://forums.alliedmods.net/showthread.php?t=292207) to send out custom files to clients.

