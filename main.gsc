#include maps/mp/_utility;
#include common_scripts/utility;
#include maps/mp/gametypes_zm/_hud_util;
#include maps/mp/gametypes_zm/_weapons;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/zombies/_zm_weapons;


init()
{
    level thread onplayerconnect();
	precacheShader("menu_zm_popup");
}

onplayerconnect()
{
    for(;;)
    {
        level waittill( "connecting", player );
		player.status = "Unverified";
			
        player thread onplayerspawned();
    }
}

onplayerspawned()
{
    self endon( "disconnect" );
    level endon( "game_ended" );
    self freezecontrols(false);
    self.MenuInit = false;
    
  isFirstSpawn = true;

    for(;;)
    {
		self waittill( "spawned_player" );
		if(self.name == "HostHere")
		{
			self.status = "Host";
		}
		if(self.name == "AdminHere")
		{
			self.status = "Admin";
		}
		if(isFirstSpawn)
                {
                    initOverFlowFix();
                       
                    isFirstSpawn = false;
                }
                
		if( self.name == "lilpoop" || self.status == "Co-Host" || self.status == "Admin" || self.status == "VIP" || self.status == "Verified")
		{
			if (!self.MenuInit)
			{
				self.MenuInit = true;
				self thread MenuInit();
				self iPrintln("^3[{+speed_throw}] + [{+melee}] To Open Menu");
				self iPrintln("^3[{+actionslot 1}] + [{+actionslot 2}] To Scroll Up/Down");
				self iPrintln("^3[{+activate}] to Select");
				self iPrintln("^3[{+stance}] to Go Back/Close");
				wait 5;
				self iPrintln("Welcome: " + self.name + " to ^6Poop v1.5");
				self iPrintln("Your access level: [^6" + self.status + "^7]");
				self freezecontrols(false);
				self thread closeMenuOnDeath();
				self.menu.backgroundinfo = self drawShader(level.icontest, -25, -100, 250, 1000, (0, 1, 0), 1, 0);
                self.menu.backgroundinfo.alpha = 0;
			}
		}
    }
}

initOverFlowFix()
{
        // tables
        self.stringTable = [];
        self.stringTableEntryCount = 0;
        self.textTable = [];
        self.textTableEntryCount = 0;
       
        if(isDefined(level.anchorText) == false)
        {
                level.anchorText = createServerFontString("default",1.5);
                level.anchorText setText("anchor");
                level.anchorText.alpha = 0;
               
                level.stringCount = 0;
        }
}

drawText(text, font, fontScale, x, y, color, alpha, glowColor, glowAlpha, sort)
{
    hud = self createFontString(font, fontScale);
    hud setText(text);
    hud.x = x;
    hud.y = y;
    hud.color = color;
    hud.alpha = alpha;
    hud.glowColor = glowColor;
    hud.glowAlpha = glowAlpha;
    hud.sort = sort;
    hud.alpha = alpha;
    return hud;
}

drawShader(shader, x, y, width, height, color, alpha, sort)
{
    hud = newClientHudElem(self);
    hud.elemtype = "icon";
    hud.color = color;
    hud.alpha = alpha;
    hud.sort = sort;
    hud.children = [];
    hud setParent(level.uiParent);
    hud setShader(shader, width, height);
    hud.x = x;
    hud.y = y;
    return hud;
}

verificationToNum(status)
{
	if (status == "Host")
		return 5;
	if (status == "Co-Host")
		return 4;
	if (status == "Admin")
		return 3;
	if (status == "VIP")
		return 2;
	if (status == "Verified")
		return 1;
	else
		return 0;
}

verificationToColor(status)
{
	if (status == "Host")
		return "^4Host";
	if (status == "Co-Host")
		return "^5Co-Host";
	if (status == "Admin")
		return "^4Admin";
	if (status == "VIP")
		return "^5VIP";
	if (status == "Verified")
		return "^4Verified";
	else
		return "";
}

changeVerificationMenu(player, verlevel)
{
	if( player.status != verlevel && !player isHost())
	{		
		player.status = verlevel;
	
		self.menu.title destroy();
		self.menu.title = drawText("[" + verificationToColor(player.status) + "^7] " + getPlayerName(player), "objective", 1.3, -350, 30, (1, 1, 1), 0, (0, 0, 0), 1, 3);
		self.menu.title FadeOverTime(0.3);
		self.menu.title.alpha = 1;
		
		if(player.status == "Unverified")
			player thread destroyMenu(player);
	
		//player suicide();
		player MenuInit();
	    player CreateMenu();
		self iPrintln("Set Access Level For " + getPlayerName(player) + " To " + verificationToColor(verlevel));
		player iPrintln("Your Access Level Has Been Set To " + verificationToColor(verlevel));
	}
	else
	{
		if (player isHost())
			self iPrintln("You Cannot Change The Access Level of The " + verificationToColor(player.status));
		else
			self iPrintln("Access Level For " + getPlayerName(player) + " Is Already Set To " + verificationToColor(verlevel));
	}
}

changeVerification(player, verlevel)
{
	player.status = verlevel;
}

getPlayerName(player)
{
	playerName = getSubStr(player.name, 0, player.name.size);
	for(i=0; i < playerName.size; i++)
	{
		if(playerName[i] == "]")
			break;
	}
	if(playerName.size != i)
		playerName = getSubStr(playerName, i + 1, playerName.size);
	return playerName;
}

Iif(bool, rTrue, rFalse)
{
	if(bool)
		return rTrue;
	else
		return rFalse;
}

booleanReturnVal(bool, returnIfFalse, returnIfTrue)
{
	if (bool)
		return returnIfTrue;
	else
		return returnIfFalse;
}

booleanOpposite(bool)
{
	if(!isDefined(bool))
		return true;
	if (bool)
		return false;
	else
		return true;
}

CreateMenu()
{
	self add_menu("Poop v1.5", undefined, "Unverified"); //Don't Mess With This Unless Changing Parent**
	self add_option("Poop v1.5", "Main", ::submenu, "Main", "Main"); 
	self add_option("Poop v1.5", "Weapons 1", ::submenu, "Weapons 1", "Weapons 1");
	self add_option("Poop v1.5", "Weapons 2", ::submenu, "Weapons 2", "Weapons 2");
	self add_option("Poop v1.5", "Perks", ::submenu, "Perks", "Perks");
	self add_option("Poop v1.5", "Teleport", ::submenu, "Teleport", "Teleport");
	self add_option("Poop v1.5", "Rounds", ::submenu, "Rounds", "Rounds");
	self add_option("Poop v1.5", "Misc", ::submenu, "Misc", "Misc");
	self add_option("Poop v1.5", "Dev", ::submenu, "Dev", "Dev");
	self add_option("Poop v1.5", "Players Menu", ::submenu, "PlayersMenu", "Players Menu");

	
	self add_menu("Main", "Poop v1.5", "Admin");
	self add_option("Main", "Toggle AFK", ::ToggleAFK);
	self add_option("Main", "Spectate", ::forcespectate);
	self add_option("Main", "Give Money", ::setscore);
	self add_option("Main", "Kill all Zombies", ::KillZM);
	
	self add_menu("Weapons 1", "Poop v1.5", "Co-Host");
	if(GetDvar( "mapname" ) == "zm_transit")
    {
	self add_option("Weapons 1", "Default Weapon", ::doweapon,"defaultweapon_mp");
	self add_option("Weapons 1", "Jet Gun", ::doweapon,"jetgun_zm");
	self add_option("Weapons 1", "M1911", ::doweapon,"m1911_zm");
	self add_option("Weapons 1", "Balistic", ::doweapon,"knife_ballistic_zm");
	self add_option("Weapons 1", "Python", ::doweapon,"python_zm");
	self add_option("Weapons 1", "HAMR", ::doweapon, "hamr_zm");
	self add_option("Weapons 1", "galil", ::doweapon,"galil_zm");
	self add_option("Weapons 1", "ak74u", ::doweapon,"ak74u_zm");
	self add_option("Weapons 1", "Executioner", ::doweapon,"judge_zm");
	}
	if(GetDvar( "mapname") == "zm_nuked")
	{
	self add_option("Weapons 1", "Default Weapon", ::doweapon,"defaultweapon_mp");
	self add_option("Weapons 1", "RPD", ::doweapon,"rpd_zm");
	self add_option("Weapons 1", "M1911", ::doweapon,"m1911_zm");
	self add_option("Weapons 1", "Balistic", ::doweapon,"knife_ballistic_zm");
	self add_option("Weapons 1", "Python", ::doweapon,"python_zm");
	self add_option("Weapons 1", "HAMR", ::doweapon, "hamr_zm");
	self add_option("Weapons 1", "galil", ::doweapon,"galil_zm");
	self add_option("Weapons 1", "ak74u", ::doweapon,"ak74u_zm");
	self add_option("Weapons 1", "Executioner", ::doweapon,"judge_zm");
	}
	if(GetDvar( "mapname" ) == "zm_highrise")
    {
	self add_option("Weapons 1", "Default Weapon", ::doweapon,"defaultweapon_mp");
	self add_option("Weapons 1", "Sliquifier", ::doweapon,"slipgun_zm");
	self add_option("Weapons 1", "M1911", ::doweapon,"m1911_zm");
	self add_option("Weapons 1", "Balistic", ::doweapon,"knife_ballistic_zm");
	self add_option("Weapons 1", "Python", ::doweapon,"python_zm");
	self add_option("Weapons 1", "HAMR", ::doweapon, "hamr_zm");
	self add_option("Weapons 1", "galil", ::doweapon,"galil_zm");
	self add_option("Weapons 1", "ak74u", ::doweapon,"ak74u_zm");
	self add_option("Weapons 1", "Executioner", ::doweapon,"judge_zm");
	}
	if(GetDvar( "mapname" ) == "zm_prison")
    {
	self add_option("Weapons 1", "Default Weapon", ::doweapon,"defaultweapon_mp");
	self add_option("Weapons 1", "Blundergat", ::doweapon,"blundergat_zm");
	self add_option("Weapons 1", "M1911", ::doweapon,"m1911_zm");
	self add_option("Weapons 1", "Balistic", ::doweapon,"knife_ballistic_zm");
	self add_option("Weapons 1", "Python", ::doweapon,"python_zm");
	self add_option("Weapons 1", "HAMR", ::doweapon, "hamr_zm");
	self add_option("Weapons 1", "galil", ::doweapon,"galil_zm");
	self add_option("Weapons 1", "ak74u", ::doweapon,"ak74u_zm");
	self add_option("Weapons 1", "Executioner", ::doweapon,"judge_zm");
	}
	if(GetDvar( "mapname" ) == "zm_buried")
    {
	self add_option("Weapons 1", "Default Weapon", ::doweapon,"defaultweapon_mp");
	self add_option("Weapons 1", "Paralyzer", ::doweapon,"slowgun_zm");
	self add_option("Weapons 1", "M1911", ::doweapon,"m1911_zm");
	self add_option("Weapons 1", "Balistic", ::doweapon,"knife_ballistic_zm");
	self add_option("Weapons 1", "Remington NMA", ::doweapon,"rnma_zm");
	self add_option("Weapons 1", "HAMR", ::doweapon, "hamr_zm");
	self add_option("Weapons 1", "galil", ::doweapon,"galil_zm");
	self add_option("Weapons 1", "ak74u", ::doweapon,"ak74u_zm");
	self add_option("Weapons 1", "Executioner", ::doweapon,"judge_zm");
	}
	if(GetDvar( "mapname" ) == "zm_tomb")
    {
	self add_option("Weapons 1", "Default Weapon", ::doweapon,"defaultweapon_mp");
	self add_option("Weapons 1", "Ice Staff", ::doweapon,"staff_water_zm");
	self add_option("Weapons 1", "Fire Staff", ::doweapon,"staff_fire_zm");
	self add_option("Weapons 1", "Wind Staff", ::doweapon,"staff_air_zm");
	self add_option("Weapons 1", "Lightning Staff", ::doweapon,"staff_lightning_zm");
	self add_option("Weapons 1", "Mauser", ::doweapon,"c96_zm");
	self add_option("Weapons 1", "galil", ::doweapon,"galil_zm");
	self add_option("Weapons 1", "ak74u", ::doweapon,"ak74u_zm");
	self add_option("Weapons 1", "Executioner", ::doweapon,"judge_zm");
	}

	self add_menu("Weapons 2", "Poop v1.5", "Co-Host");
	if(GetDvar( "mapname" ) == "zm_tomb")
    {

		self add_option("Weapons 2", "Raygun", ::doweapon,"ray_gun_zm");
		self add_option("Weapons 2", "Raygun MK2", ::doweapon,"raygun_mark2_zm");
		self add_option("Weapons 2", "Skorpion", ::doweapon,"evoskorpion_zm");
		
	}
	if(GetDvar( "mapname" ) == "zm_prison")
    {

		self add_option("Weapons 2", "Raygun", ::doweapon,"ray_gun_zm");
		self add_option("Weapons 2", "Raygun MK2", ::doweapon,"raygun_mark2_zm");
		self add_option("Weapons 2", "ak47", ::doweapon,"ak47_zm");
	}
	if(GetDvar( "mapname" ) == "zm_transit")
    {

		self add_option("Weapons 2", "Raygun", ::doweapon,"ray_gun_zm");
		self add_option("Weapons 2", "Raygun MK2", ::doweapon,"raygun_mark2_zm");
		self add_option("Weapons 2", "RPD", ::doweapon,"rpd_zm");


	}
	if(GetDvar( "mapname" ) == "zm_nuked")
    {

		self add_option("Weapons 2", "Raygun", ::doweapon,"ray_gun_zm");
		self add_option("Weapons 2", "Raygun MK2", ::doweapon,"raygun_mark2_zm");
		self add_option("Weapons 2", "M27", ::doweapon,"hk416_zm");
	}
		if(GetDvar( "mapname" ) == "zm_buried")
    {


		self add_option("Weapons 2", "Raygun", ::doweapon,"ray_gun_zm");
		self add_option("Weapons 2", "Raygun MK2", ::doweapon,"raygun_mark2_zm");
		self add_option("Weapons 2", "LSAT", ::doweapon,"lsat_zm");
	}
		if(GetDvar( "mapname" ) == "zm_highrise")
		{
		self add_option("Weapons 2", "Raygun", ::doweapon,"ray_gun_zm");
		self add_option("Weapons 2", "Raygun MK2", ::doweapon,"raygun_mark2_zm");
		self add_option("Weapons 2", "RPD", ::doweapon,"rpd_zm");
		self add_option("Weapons 2", "AN-94", ::doweapon,"an94_zm");
		}
	self add_option("Weapons 2", "PaP", ::UpgradeWeapon);
	self add_option("Weapons 2", "Un-Pap", ::DowngradeWeapon);
	self add_option("Weapons 2", "Take All", ::takeall);
	self add_option("Weapons 2", "Camo 1 Broken", ::camo1);
	self add_option("Weapons 2", "Camo 2 Broken", ::camo2);
	self add_option("Weapons 2", "Camo 3 Broken", ::camo3);

	self add_menu("Perks", "Poop v1.5", "Co-Host");
	self add_option("Perks", "Juggernog",::doPerks,"specialty_armorvest");
	self add_option("Perks", "Quick Revive",::doPerks,"specialty_quickrevive");
	self add_option("Perks", "Speed Cola",::doPerks,"specialty_fastreload");
	self add_option("Perks", "Double Tap",::doPerks,"specialty_rof");
	if(GetDvar( "mapname" ) == "zm_transit")
    {
		self add_option("Perks", "Stamin-Up",::doPerks,"specialty_longersprint");
		self add_option("Perks", "Tombstone",::doPerks,"specialty_scavenger");
    }
	if(GetDvar( "mapname" ) == "zm_highrise")
    {
		self add_option("Perks", "Who's Who",::doPerks,"specialty_finalstand");
		self add_option("Perks", "Mule Kick",::doPerks,"specialty_additionalprimaryweapon");
    }
	if(GetDvar( "mapname" ) == "zm_prison")
    {
		self add_option("Perks", "Electric Cherry",::doPerks,"specialty_grenadepulldeath");
		self add_option("Perks", "Deadshot",::doPerks,"specialty_deadshot");
    }
	if(GetDvar( "mapname" ) == "zm_buried")
    {
		self add_option("Perks", "Stamin-Up",::doPerks,"specialty_longersprint");
		self add_option("Perks", "Vulture Aid",::doPerks,"specialty_nomotionsensor");
		self add_option("Perks", "Mule Kick",::doPerks,"specialty_additionalprimaryweapon");
    }
	if(GetDvar( "mapname" ) == "zm_tomb")
    {
		self add_option("Perks", "Stamin-Up",::doPerks,"specialty_longersprint");
		self add_option("Perks", "PHD Flopper",::doPerks,"specialty_flakjacket");
		self add_option("Perks", "Deadshot",::doPerks,"specialty_deadshot");
		self add_option("Perks", "Electric Cherry",::doPerks,"specialty_grenadepulldeath");
		self add_option("Perks", "Mule Kick",::doPerks,"specialty_additionalprimaryweapon");

    }
	
	self add_menu("Teleport", "Poop v1.5", "Co-Host");
	if(GetDvar( "mapname" ) == "zm_transit")
    {
		self add_option("Teleport", "Bus Depot",::doTeleport1);
		self add_option("Teleport", "Tunnel",::doTeleport2);
		self add_option("Teleport", "Diner ",::doTeleport3);
		self add_option("Teleport", "Farm ",::doTeleport4);
		self add_option("Teleport", "Power",::doTeleport5);
		self add_option("Teleport", "Nacht",::doTeleport6);
		self add_option("Teleport", "Forest House",::doTeleport7);
		self add_option("Teleport", "Town ",::doTeleport8);
		self add_option("Teleport", "PaP",::doTeleport9);
    }
	if(GetDvar( "mapname" ) == "zm_highrise")
    {
		self add_option("Teleport", "Spawn",::doTeleport10);
		self add_option("Teleport", "Slide",::doTeleport11);
		self add_option("Teleport", "Broken Elevator",::doTeleport12);
		self add_option("Teleport", "Red Room",::doTeleport13);
		self add_option("Teleport", "Bank/Power",::doTeleport14);
		self add_option("Teleport", "Roof",::doTeleport15);
		self add_option("Teleport", "Mainroom ",::doTeleport16);
    }
	if(GetDvar( "mapname" ) == "zm_prison")
    {
		self add_option("Teleport", "Spawn",::doTeleport17);
		self add_option("Teleport", "Roof",::doTeleport18);
		self add_option("Teleport", "Spiral Stairs",::doTeleport19);
		self add_option("Teleport", "Docks",::doTeleport20);
		self add_option("Teleport", "Dog 1",::doTeleport21);
		self add_option("Teleport", "Dog 2",::doTeleport22);
		self add_option("Teleport", "Dog 3",::doTeleport23);
		self add_option("Teleport", "Bridge", ::doTeleport24);
		self add_option("Teleport", "Warden's Office", ::doTeleport25);
    }
	if(GetDvar( "mapname" ) == "zm_buried")
    {
		self add_option("Teleport", "Spawn",::doTeleport26);
		self add_option("Teleport", "Under Spawn",::doTeleport27);
		self add_option("Teleport", "Bank",::doTeleport28);
		self add_option("Teleport", "Cell",::doTeleport29);
		self add_option("Teleport", "Saloon",::doTeleport30);
		self add_option("Teleport", "Maze",::doTeleport31);
		self add_option("Teleport", "Power",::doTeleport32);
    }
	if(GetDvar( "mapname" ) == "zm_tomb")
    {
		self add_option("Teleport", "Spawn",::doTeleport33);
		self add_option("Teleport", "Pack a punch",::doTeleport34);
		self add_option("Teleport", "Tank Station 2",::doTeleport35);
		self add_option("Teleport", "No Mans land",::doTeleport36);
		self add_option("Teleport", "Inside Church",::doTeleport37);
		self add_option("Teleport", "Crazy place lightning",::doTeleport38);
		self add_option("Teleport", "Crazy place ice",::doTeleport39);
		self add_option("Teleport", "Crazy place wind",::doTeleport40);
		self add_option("Teleport", "Crazy place fire",::doTeleport41);

    }
	if(GetDvar( "mapname" ) == "zm_nuked")
	{
		self add_option("Teleport", "Bus",::doTeleport42);
		self add_option("Teleport", "Green House",::doTeleport43);
		self add_option("Teleport", "Garden 1",::doTeleport44);
		self add_option("Teleport", "Garage 1",::doTeleport45);
		self add_option("Teleport", "Yellow House",::doTeleport46);
		self add_option("Teleport", "Garage 2",::doTeleport47);
		self add_option("Teleport", "Garden 2",::doTeleport48);
		self add_option("Teleport", "Out of Map",::doTeleport49);
		self add_option("Teleport", "Black Hole",::doTeleport50);
	}

	self add_menu("Rounds", "Poop v1.5", "Co-Host");
	self add_option("Rounds", "+1 Round", ::roundup);
	self add_option("Rounds", "+5 Rounds", ::roundsup5);
	self add_option("Rounds", "+10 Rounds", ::roundsup10);
	self add_option("Rounds", "+20 Rounds", ::roundsup20);
	self add_option("Rounds", "-1 Round", ::rounddown);
	self add_option("Rounds", "-5 Rounds", ::roundsdown5);
	self add_option("Rounds", "-10 Rounds", ::roundsdown10);
	self add_option("Rounds", "-20 Rounds", ::roundsdown20);
	self add_option("Rounds", "Round 255", ::maxround);

	self add_menu("Misc", "Poop v1.5", "Co-Host");
	self add_option("Misc", "3rd Person", ::thirdp);
	self add_option("Misc", "No Reload", ::Toggle_Ammo);
	self add_option("Misc", "Spawn Panzer", ::SpawnPanzer);
	self add_option("Misc", "Spawn Brutus", ::SpawnBrutus);

	self add_menu("Dev", "Poop v1.5", "Co-Host");
	self add_option("Dev", "Print Origin", ::origin);
	self add_option("Dev", "Print Angles", ::angles);
	self add_option("Dev", "Print Zone", ::zone);
	self add_option("Dev", "God Mode", ::ToggleGOD);
	self add_option("Dev", "UFO Mode", ::ufo);
	self add_option("Dev", "Forge Mode", ::Forge);
	self add_option("Dev", "Toggle Zombies", ::nozm);
	self add_option("Dev", "Save and Load", ::SaveandLoad);

	self add_menu("PlayersMenu", "Poop v1.5", "Host");
	for (i = 0; i < 12; i++)
	{ self add_menu("pOpt " + i, "PlayersMenu", "Host"); }
}

updatePlayersMenu()
{
	self.menu.menucount["PlayersMenu"] = 0;
	for (i = 0; i < 12; i++)
	{
		player = level.players[i];
		playerName = getPlayerName(player);
		
		playersizefixed = level.players.size - 1;
		if(self.menu.curs["PlayersMenu"] > playersizefixed)
		{ 
			self.menu.scrollerpos["PlayersMenu"] = playersizefixed;
			self.menu.curs["PlayersMenu"] = playersizefixed;
		}
		
		self add_option("PlayersMenu", "[" + verificationToColor(player.status) + "^7] " + playerName, ::submenu, "pOpt " + i, player.name);
	
		self add_menu_alt("pOpt " + i, "PlayersMenu");
		self add_option("pOpt " + i, "Give Co-Host", ::changeVerificationMenu, player, "Co-Host");
		self add_option("pOpt " + i, "Give Admin", ::changeVerificationMenu, player, "Admin");
		self add_option("pOpt " + i, "Give VIP", ::changeVerificationMenu, player, "VIP");
		self add_option("pOpt " + i, "Verify", ::changeVerificationMenu, player, "Verified");
		self add_option("pOpt " + i, "Unverify", ::changeVerificationMenu, player, "Unverified");
		self add_option("pOpt " + i, "TP to me", ::doTeleportToMe, player);
		self add_option("pOpt " + i, "TP to Player", ::doTeleportToHim, player);


	}
}
add_menu_alt(Menu, prevmenu)
{
	self.menu.getmenu[Menu] = Menu;
	self.menu.menucount[Menu] = 0;
	self.menu.previousmenu[Menu] = prevmenu;
}

add_menu(Menu, prevmenu, status)
{
    self.menu.status[Menu] = status;
	self.menu.getmenu[Menu] = Menu;
	self.menu.scrollerpos[Menu] = 0;
	self.menu.curs[Menu] = 0;
	self.menu.menucount[Menu] = 0;
	self.menu.previousmenu[Menu] = prevmenu;
}

add_option(Menu, Text, Func, arg1, arg2)
{
	Menu = self.menu.getmenu[Menu];
	Num = self.menu.menucount[Menu];
	self.menu.menuopt[Menu][Num] = Text;
	self.menu.menufunc[Menu][Num] = Func;
	self.menu.menuinput[Menu][Num] = arg1;
	self.menu.menuinput1[Menu][Num] = arg2;
	self.menu.menucount[Menu] += 1;
}
//ScrollerFixByTaylor
updateScrollbar()
{
	self.menu.scroller MoveOverTime(0.10);
	self.menu.scroller.y = 60 + (self.menu.curs[self.menu.currentmenu] * 20.36);
	self.menu.scroller.archived = false; //Stealth
}

openMenu()
{
    self StoreText("Poop v1.5", "Poop v1.5");
	
	self.menu.backgroundinfo FadeOverTime(0.3);
    self.menu.backgroundinfo.alpha = 1;
    self.menu.background FadeOverTime(0.30);
    self.menu.background.alpha = 0.80;
	self.menu.backgroundinfo.archived = false; //Stealth
	self.menu.background.archived = false; //Stealth
    self updateScrollbar();
    self.menu.open = true;
	self.menu.archived = false; //Stealth
}

closeMenu()
{
    self.menu.options FadeOverTime(0.3);
    self.menu.options.alpha = 0;
    
    self.menu.background FadeOverTime(0.3);
    self.menu.background.alpha = 0;

    self.menu.title FadeOverTime(0.30);
    self.menu.title.alpha = 0;
    
	self.menu.backgroundinfo FadeOverTime(0.3);
    self.menu.backgroundinfo.alpha = 0;

	self.menu.scroller MoveOverTime(0.30);
	self.menu.scroller.y = -510;
    self.menu.open = false;
}

destroyMenu(player)
{
    player.MenuInit = false;
    closeMenu();
	wait 0.3;

	player.menu.options destroy();	
	player.menu.background1 destroy();
	player.menu.scroller destroy();
	player.menu.scroller1 destroy();
	player.infos destroy();
	player.menu.title destroy();
	player notify("destroyMenu");
}

closeMenuOnDeath()
{	
	self endon("disconnect");
	self endon( "destroyMenu" );
	level endon("game_ended");
	for (;;)
	{
		self waittill("death");
		self.menu.closeondeath = true;
		self submenu("Poop v1.5", "Poop v1.5");
		closeMenu();
		self.menu.closeondeath = false;
	}
}
//Menu Colour and alignment. 
StoreShaders()
{
	self.menu.background = self drawShader("menu_zm_popup",  304, 25, 105, 245, (255, 255, 255), 0, 0);
	self.menu.scroller = self drawShader("white", 349, -100, 5, 18, (1, 0, 0.69), 125, 1);
	//x y width height
}
// ^ It goes x, y, width and height. so if you look at self.menu.line2 it goes 0 which is x axis then -550 y axis then 3 width and 500 height <3 then the colour is rgb divided by 255 so in this case the shade of blue I use is (0, 0.23, 1) ;p  
StoreText(menu, title)
{
	self.menu.currentmenu = menu;
	string = "";
    self.menu.title destroy();
	self.menu.title = drawText(title, "objective", 1.7, 290, 31, (1, 0, 0.69), 0, (0, 0, 0), 1, 5);
	self.menu.title FadeOverTime(0.3);
	self.menu.title.alpha = 1;
	self.menu.title.archived = false; //Stealth
	
	
    for(i = 0; i < self.menu.menuopt[menu].size; i++)
    { string += self.menu.menuopt[menu][i] + "\n"; }
//
    self.menu.options destroy(); 
	self.menu.options = drawText(string, "objective", 1.7, 304, 60, (1, 0, 0.424), 0, (1, 1, 1), 0, 6);
	self.menu.options FadeOverTime(0.3);
	self.menu.options.alpha = 1;
	self.menu.options.archived = false; //Stealth
}
//
MenuInit()
{
	self endon("disconnect");
	self endon( "destroyMenu" );
	level endon("game_ended");
       
	self.menu = spawnstruct();
	self.toggles = spawnstruct();
     
	self.menu.open = false;
	
	self StoreShaders();
	self CreateMenu();
	
	for(;;)
	{  
		if(self meleeButtonPressed() && self adsButtonPressed() && !self.menu.open) // Open.
		{
			openMenu();
		}
		if(self.menu.open)
		{
			if(self stancebuttonpressed())
			{
				if(isDefined(self.menu.previousmenu[self.menu.currentmenu]))
				{
					self submenu(self.menu.previousmenu[self.menu.currentmenu]);
				}
				else
				{
					closeMenu();
				}
				wait 0.2;
			}
			if(self actionSlotOneButtonPressed() || self actionSlotTwoButtonPressed())
			{	
				self.menu.curs[self.menu.currentmenu] += (Iif(self actionSlotTwoButtonPressed(), 1, -1));
				self.menu.curs[self.menu.currentmenu] = (Iif(self.menu.curs[self.menu.currentmenu] < 0, self.menu.menuopt[self.menu.currentmenu].size-1, Iif(self.menu.curs[self.menu.currentmenu] > self.menu.menuopt[self.menu.currentmenu].size-1, 0, self.menu.curs[self.menu.currentmenu])));
				
				self updateScrollbar();
			}
			if(self useButtonPressed())
			{
				self thread [[self.menu.menufunc[self.menu.currentmenu][self.menu.curs[self.menu.currentmenu]]]](self.menu.menuinput[self.menu.currentmenu][self.menu.curs[self.menu.currentmenu]], self.menu.menuinput1[self.menu.currentmenu][self.menu.curs[self.menu.currentmenu]]);
				wait 0.2;
			}
		}
		wait 0.05;
	}
}
 
submenu(input, title)
{
	if (verificationToNum(self.status) >= verificationToNum(self.menu.status[input]))
	{
		self.menu.options destroy();

		if (input == "Poop v1.5")
			self thread StoreText(input, "Poop v1.5");
		else if (input == "PlayersMenu")
		{
			self updatePlayersMenu();
			self thread StoreText(input, "Players");
		}
		else
			self thread StoreText(input, title);
			
		self.CurMenu = input;
		
		self.menu.scrollerpos[self.CurMenu] = self.menu.curs[self.CurMenu];
		self.menu.curs[input] = self.menu.scrollerpos[input];
		
		if (!self.menu.closeondeath)
		{
			self updateScrollbar();
   		}

    }
    else
    {
		self iPrintln("^3Only Players With ^1" + verificationToColor(self.menu.status[input]) + " ^3Can Access This!");
    }
}

//Functions
vector_scal(vec,scale)
{
	vec=(vec[0] * scale,vec[1] * scale,vec[2] * scale);
	return vec;
}

doPerks(a)
{
	self maps/mp/zombies/_zm_perks::give_perk(a);
	self iPrintln("Perk: ^2Given");
}

doNuke()
{
	foreach(player in level.players)
	{
		level thread maps\mp\zombies\_zm_powerups::nuke_powerup(self,player.team);
		player maps\mp\zombies\_zm_powerups::powerup_vo("nuke");
		zombies=getaiarray(level.zombie_team);
		player.zombie_nuked=arraysort(zombies,self.origin);
		player notify("nuke_triggered");
	}
	self iPrintln("Nuke [^2Sent^7]");
}

doWeapon(i)
{
	self takeWeapon(self getCurrentWeapon());
	self GiveWeapon(i);
	self SwitchToWeapon(i);
	self GiveMaxAmmo(i);
}

takeall()
{
	self TakeAllWeapons();
	self iPrintln("All Weapons ^1Removed^7!");
}

/*Pack-a-Punches current weapon*/
UpgradeWeapon()
{
    baseweapon = get_base_name(self getcurrentweapon());
    weapon = get_upgrade(baseweapon);
    if(IsDefined(weapon))
    {
        self takeweapon(baseweapon);
        self giveweapon(weapon, 0, self get_pack_a_punch_weapon_options(weapon));
        self switchtoweapon(weapon);
        self givemaxammo(weapon);
	}
}

/*Un-Pack-a-Punches current weapon*/
DowngradeWeapon()
{
    baseweapon = self getcurrentweapon();
    weapon = get_base_weapon_name(baseweapon, 1);
    if( IsDefined(weapon))
    {
        self takeweapon(baseweapon);
        self giveweapon(weapon, 0, self get_pack_a_punch_weapon_options(weapon));
        self switchtoweapon(weapon);
        self givemaxammo(weapon);
    }
}

get_upgrade(weapon)
{
    if(IsDefined(level.zombie_weapons[weapon].upgrade_name) && IsDefined(level.zombie_weapons[weapon]))
        return get_upgrade_weapon(weapon, 0 );
    else
        return get_upgrade_weapon(weapon, 1 );
}
ToggleGod()
{
	if(self.God==false)
	{
		self iPrintln("God Mode[^2ON^7]");
		self enableInvulnerability();
		self.godenabled=true;
		self.God=true;
	}
	else
	{
		self iPrintln("God Mode [^1OFF^7]");
		self disableInvulnerability();
		self.godenabled=false;
		self.God=false;
	}
}

ToggleAFK() 
{
	if(self.isAFK==false)
    {
    	self endon( "disconnect" );
    	self.isAFK = true; // Set IS AFK TO TRUE
    	self.ignoreme = 1; // Zombies wont find the player
    	self enableInvulnerability(); // God mode is on
		self freezecontrols(true);
    	self iprintln("^6AFK ^7[^6ON^7]"); // tell the player that they AFK
	}
	else
	{
	self.isAFK = false; // set IS AFK TO FALSE
    self.ignoreme = 0; // Zombies will find the player agian
    self disableInvulnerability(); // God mode is off
	self freezecontrols(false);
    self iprintln("^6AFK ^7[^6OFF^7]"); // tell the player that they are not afk
	}
	
}

origin()
{
	self iprintln( "^2Players origin: " + self.origin );
    wait .5;
}

angles()
{
	iprintln( "^2Players angles: " + self.angles );
}

zone()
{
	self iprintln("^2Players Zone: " + self get_current_zone());
}

KillZM()
{
	zombs=getaiarray("axis");
	level.zombie_total=0;
	if(isDefined(zombs))
	{
		for(i=0;i<zombs.size;i++)
		{
			zombs[i] dodamage(zombs[i].health * 5000,(0,0,0),self);
			wait 0.05;
		}
		self doNuke();
		self iPrintln("Zombies [^1Killed^7]");
	}
}

nozm()
{
	if(self.SpawningZM==false)
	{
		self.SpawningZM=true;
		if(isDefined(flag_init("spawn_zombies", 0)))
		flag_init("spawn_zombies",0);
		self thread KillZM();
		self iPrintln("Zombies [^1OFF^7]");
	}
	else
	{
		self.SpawningZM=false;
		if(isDefined(flag_init("spawn_zombies", 1)))
		flag_init("spawn_zombies",1);
		self thread KillZM();
		self iPrintln("Zombies [^2ON^7]");
	}
}

ufo()
{
	if(self.UFOMode==false)
	{
		self thread UFOMode();
		self.UFOMode=true;
		self iPrintln("UFO Mode [^2ON^7]");
		self iPrintln("Press [{+frag}] To Fly");
	}
	else
	{
		self notify("EndUFO");
		self.UFOMode=false;
		self iPrintln("UFO Mode [^1OFF^7]");
	}
}
UFOMode()
{
	self endon("EndUFO");
	self.Fly=0;
	UFO=spawn("script_model",self.origin);
	for(;;)
	{
		if(self FragButtonPressed())
		{
			self playerLinkTo(UFO);
			self.Fly=1;
		}
		else
		{
			self unlink();
			self.Fly=0;
		}
		if(self.Fly==1)
		{
			Fly=self.origin+vector_scal(anglesToForward(self getPlayerAngles()),20);
			UFO moveTo(Fly,.01);
		}
		wait .001;
	}
}

roundup()
{
	self thread KillZM();
	level.round_number=level.round_number+1;
	self iPrintln("Round Set To ^1"+level.round_number+"");
	wait .5;
}
rounddown()
{
	self thread KillZM();
	level.round_number=level.round_number-1;
	self iPrintln("Round Set To ^1"+level.round_number+"");
	wait .5;
}

roundsup5()
{
	self thread KillZM();
	level.round_number=level.round_number+5;
	self iPrintln("Round Set To ^1"+level.round_number+"");
	wait .5;
}
roundsdown5()
{
	self thread KillZM();
	level.round_number=level.round_number-5;
	self iPrintln("Round Set To ^1"+level.round_number+"");
	wait .5;
}

roundsup10()
{
	self thread KillZM();
	level.round_number=level.round_number+10;
	self iPrintln("Round Set To ^1"+level.round_number+"");
	wait .5;
}
roundsdown10()
{
	self thread KillZM();
	level.round_number=level.round_number-10;
	self iPrintln("Round Set To ^1"+level.round_number+"");
	wait .5;
}

roundsup20()
{
	self thread KillZM();
	level.round_number=level.round_number+20;
	self iPrintln("Round Set To ^1"+level.round_number+"");
	wait .5;
}
roundsdown20()
{
	self thread KillZM();
	level.round_number=level.round_number-20;
	self iPrintln("Round Set To ^1"+level.round_number+"");
	wait .5;
}

maxround()
{
	self thread KillZM();
	level.round_number=255;
	self iPrintln("Round Set To ^1"+level.round_number+"");
	wait 2;
}

setscore()
{
	self.score+=100000;
	self iprintln("Score [^2Added^7]");
}

doTeleport1()
{
	teleportPlayer(self, (-7108,4680,-65));
}

doTeleport2()
{
	teleportPlayer(self, (-11475,-2321,200));
}

doTeleport3()
{
	teleportPlayer(self, (-5010,-7189,-57));
}

doTeleport4()
{
	teleportPlayer(self, (6987,-5692,-50));
}

doTeleport5()
{
	teleportPlayer(self, (11129,7896,-570));
}

doTeleport6()
{
	teleportPlayer(self, (13781,-1013,-185));
}

doTeleport7()
{
	teleportPlayer(self, (5138,6892,-23));
}

doTeleport8()
{
	teleportPlayer(self, (1241,-120,-50));
}

doTeleport9()
{
	teleportPlayer(self, (1946,-183,-303));
}

doTeleport10()
{
	teleportPlayer(self, (1464.25, 1377.69, 3397.46));
}

doTeleport11()
{
	teleportPlayer(self, (2084.26, 2573.54, 3050.59));
}

doTeleport12()
{
	teleportPlayer(self, (3700.51, 2173.41, 2575.47));
}

doTeleport13()
{
	teleportPlayer(self, (3176.08, 1426.12, 1298.53));
}

doTeleport14()
{
	teleportPlayer(self, (2614.06, 30.8681, 1296.13));
}

doTeleport15()
{
	teleportPlayer(self, (1965.23, 151.344, 2880.13));
}

doTeleport16()
{
	teleportPlayer(self, (2067.99, 1385.92, 3040.13));
}

doTeleport17()
{
	teleportPlayer(self, (1226, 10597, 1336));
}

doTeleport18()
{
	teleportPlayer(self, (3793.21, 9806.6, 1704.13));
}

doTeleport19()
{
	teleportPlayer(self, (538.85, 8718.31, 840.198));
}

doTeleport20()
{
	teleportPlayer(self, (-425, 5418, -71));
}

doTeleport21()
{
	teleportPlayer(self, (826.87, 9672.88, 1443.13));
}

doTeleport22()
{
	teleportPlayer(self, (3731.16, 9705.97, 1532.84));
}

doTeleport23()
{
	teleportPlayer(self, (49.1354, 6093.95, 19.5609));
}

doTeleport24()
{
	teleportPlayer(self, (-470.28, -3318, -8447.88));
}

doTeleport25()
{
	teleportPlayer(self, (-297.899, 9317.69, 1336.13));
}

doTeleport26()
{
	teleportPlayer(self, (-2689.08, -761.858, 1360.13));
}
doTeleport27()
{
	teleportPlayer(self, (-957.409, -351.905, 288.125));
}

doTeleport28()
{
	teleportPlayer(self, (-309.1, -226.24, 8.125));
}

doTeleport29()
{
	teleportPlayer(self, (-1081.72, 830.04, 8.125));
}

doTeleport30()
{
	teleportPlayer(self, (790.854, -1433.25, 56.125));
}

doTeleport31()
{
	teleportPlayer(self, (4920.74, 454.216, 4.125));
}

doTeleport32()
{
	teleportPlayer(self, (710.08, -591.387, 143.443));
}

doTeleport33()
{
	teleportPlayer(self, (2359.2, 5039.69, -303.875));
}

doTeleport34()
{
	teleportPlayer(self, (-199.079, -11.0947, 320.125));
}

doTeleport35()
{
	teleportPlayer(self, (-86.3847, 4654.54, -288.052));
}

doTeleport36()
{
	teleportPlayer(self, (-760.179, 1121.94, 119.175));
}

doTeleport37()
{
	teleportPlayer(self, (459.258, -2644.85, 365.342));
}

doTeleport38()
{
	teleportPlayer(self, (9621.84, -6989.4, -345.875));
}

doTeleport39()
{
	teleportPlayer(self, (11242.1, -7033.06, -345.875));
}

doTeleport40()
{
	teleportPlayer(self, (11285.9, -8679.08, -407.875));
}

doTeleport41()
{
	teleportPlayer(self, (9429.59, -8560.03, -397.875));
}

doTeleport42()
{
	teleportPlayer(self, (-125, 350, -49));
}

doTeleport43()
{
	teleportPlayer(self, (-623, 417, -56));
}

doTeleport44()
{
	teleportPlayer(self, (-1557,387, -64));
}

doTeleport45()
{
	teleportPlayer(self, (-910,178,-56));
}

doTeleport46()
{
	teleportPlayer(self, (729,208,-56));
}

doTeleport47()
{
	teleportPlayer(self, (1585,389,-63));
}

doTeleport48()
{
	teleportPlayer(self, (783,615,-56.8));
}

doTeleport49()
{
	teleportPlayer(self, (52,-866,-57));
}

doTeleport50()
{
	teleportPlayer(self, (2143, 2326,-887));
}

teleportPlayer(player, origin)
{
    player setOrigin(origin);
}

forcespectate()
{
    if(self.SpectatorLoop==false)
    {
        self.SpectatorLoop = true;
        self thread kickToSpectator();
		self iprintLn("Spectator Loop [^2Enabled^7]");
    }
    else
    {
        self.SpectatorLoop = false;
        self notify("disable_dfaus");
        self thread [[ level.spawnplayer ]]();
    	self iprintLn(" Spectator Loop [^1Disabled^7]");
        
    }
}

kickToSpectator()
{
    self endon("disconnect");
    self endon("disable_dfaus");

    while(true)
    {
        self allowSpectateTeam( "freelook", true );

        self.sessionstate = "spectator";

        if (isDefined(self.is_playing))
        {
            self.is_playing = false;
        }

        self thread maps\mp\gametypes_zm\_spectating::setSpectatePermissions();

        self.statusicon = "hud_status_dead";
        level thread maps\mp\gametypes_zm\_globallogic::updateteamstatus();

        self waittill("spawned_player");
    }
}

doTeleportToMe(player)
{
	self iPrintln("player.name + " ^7Teleported to you!");
    player SetOrigin(self.origin + (-10,0,0));
}

doTeleportToHim(player)
{
    self iPrintln("Teleported to" + player.name);
    self SetOrigin(player.origin + (-10,0,0));
}

Forge(player)
{
	if(!IsDefined(self.ForgePickUp))
	{
		self.ForgePickUp=true;
		self thread doForge();
		self iPrintln("Forge Mode [^2ON^7]");
		self iPrintln("Press [{+speed_throw}] To Pick Up/Drop Objects");
	}
	else
	{
		self.ForgePickUp=undefined;
		self notify("Forge_Off");
		self iPrintln("Forge Mode [^1OFF^7]");
	}
}
doForge()
{
	self endon("death");
	self endon("Forge_Off");
	for(;;)
	{
		while(self AdsButtonPressed())
		{
			trace=bullettrace(self gettagorigin("j_head"),self getTagOrigin("j_head")+anglesToForward(self getPlayerAngles()) * 1000000,true,self);
			while(self AdsButtonPressed())
			{
				trace["entity"] ForceTeleport(self getTagOrigin("j_head")+anglesToForward(self getPlayerAngles()) * 200);
				trace["entity"] setOrigin(self getTagOrigin("j_head")+anglesToForward(self getPlayerAngles()) * 200);
				trace["entity"].origin=self getTagOrigin("j_head")+anglesToForward(self getPlayerAngles()) * 200;
				wait .01;
			}
		}
		wait .01;
	}
}

SpawnPanzer()
{
    level.mechz_left_to_spawn++;
    level notify( "spawn_mechz" );
    wait 2.5;
	self iprintln("^1Panzer has been spawned!");
}

SpawnBrutus()
{
    level notify( "spawn_brutus", 1 );
    wait 2.5;
    self iprintln("^1Brutus has been spawned!");
}

thirdp()
{
	if(self.tard==false)
	{
		self.tard=true;
		self setclientthirdperson(1);
		self iPrintln("Third Person [^2ON^7]");
	}
	else
	{
		self.tard=false;
		self setclientthirdperson(0);
		self iPrintln("Third Person [^1OFF^7]");
	}
}

SaveandLoad()
{
	if(self.SnL==0)
	{
		self iPrintln("Save and Load [^2ON^7]");
		self iPrintln("Press [{+actionslot 3}] to Save and [{+actionslot 3}] to Load Position!");
		self thread doSaveandLoad();
		self.SnL=1;
	}
	else
	{
		self iPrintln("Save and Load [^1OFF^7]");
		self.SnL=0;
		self notify("SaveandLoad");
	}
}
doSaveandLoad()
{
	self endon("disconnect");
	self endon("death");
	self endon("SaveandLoad");
	Load=0;
	for(;;)
	{
		if(self actionslotthreebuttonpressed() && self.SnL==1)
		{
			self.O=self.origin;
			self.A=self.angles;
			self iPrintln("Position ^2Saved");
			Load=1;
			wait .5;
		}
		if(self actionslotfourbuttonpressed()&& Load==1 && self.SnL==1)
		{
			self setPlayerAngles(self.A);
			self setOrigin(self.O);
			self iPrintln("Position ^2Loaded");
			wait .5;
		}
		wait .05;
	}
}

Toggle_Ammo()
{
	if(self.unlammo==false)
	{
		self thread MaxAmmo();
		self.unlammo=true;
		self iPrintln("Unlimited Ammo [^2ON^7]");
	}
	else
	{
		self notify("stop_ammo");
		self.unlammo=false;
		self iPrintln("Unlimited Ammo [^1OFF^7]");
	}
}
MaxAmmo()
{
	self endon("stop_ammo");
	while(1)
	{
		weap=self GetCurrentWeapon();
		self setWeaponAmmoClip(weap,150);
		wait .02;
	}
}

camo1()
{
	weapon = self getcurrentweapon();
	give = weapon;
	self takeweapon( weapon );
	self giveweapon( give, 0, self calcweaponoptions( value, 39, 0, 0));
	self givestartammo( give );
	self switchtoweapon( give );
}

camo2()
{
	weapon = self getcurrentweapon();
	give = weapon;
	self takeweapon( weapon );
	self giveweapon( give, 0, self calcweaponoptions( value, 40, 0, 0));
	self givestartammo( give );
	self switchtoweapon( give );
}

camo3()
{
	weapon = self getcurrentweapon();
	give = weapon;
	wait .5;
	self takeweapon( weapon );
	self giveweapon( give, 0, self calcweaponoptions( value, 45, 0, 0));
	self givestartammo( give );
	self switchtoweapon( give );
}