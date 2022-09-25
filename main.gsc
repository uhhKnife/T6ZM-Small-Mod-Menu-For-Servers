#include maps/mp/_utility;
#include common_scripts/utility;
#include maps/mp/gametypes_zm/_hud_util;
#include maps/mp/gametypes_zm/_Weapons; 


init()
{
    level thread onplayerconnect();
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
		if(self.name == "yourname")
		{
			self.status = "Host";
		}
		if(self.name == "admin1" ||self.name == "admin2")
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
				self iPrintln("Welcome " + self.name + " to ^6Poop v1");
				self iPrintln("^3[{+speed_throw}] + [{+melee}] To Open Menu");
				self iPrintln("^3[{+actionslot 1}] + [{+actionslot 2}] To Scroll Up/Down");
				self iPrintln("^3[{+gostand}] to Select");
				self iPrintln("^3[{+activate}] to Go Back/Close");
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
	self add_menu("Poop v1", undefined, "Unverified"); //Don't Mess With This Unless Changing Parent**
	self add_option("Poop v1", "Main", ::submenu, "Main", "Main"); 
	self add_option("Poop v1", "Weapons 1", ::submenu, "Weapons 1", "Weapons 1");
	self add_option("Poop v1", "Weapons 2", ::submenu, "Weapons 2", "Weapons 2");
	self add_option("Poop v1", "Perks", ::submenu, "Perks", "Perks");
	self add_option("Poop v1", "Rounds", ::submenu, "Rounds", "Rounds");
	self add_option("Poop v1", "Dev", ::submenu, "Dev", "Dev");
	self add_option("Poop v1", "Players Menu", ::submenu, "PlayersMenu", "Players Menu");

	
	self add_menu("Main", "Poop v1", "Admin");
	self add_option("Main", "Toggle AFK", ::ToggleAFK);
	self add_option("Main", "Spectate", ::forcespectate);
	self add_option("Main", "Give Money", ::setscore);
	
	self add_menu("Weapons 1", "Poop v1", "Co-Host");
	self add_option("Weapons 1", "Default Weapon", ::doweapon,"defaultweapon_mp");
	self add_option("Weapons 1", "Jet Gun", ::doweapon,"jetgun_zm");
	self add_option("Weapons 1", "Sliquifier", ::doweapon,"slipgun_zm");
	self add_option("Weapons 1", "Blundergat", ::doweapon,"blundergat_zm");
	self add_option("Weapons 1", "Paralyzer", ::doweapon,"slowgun_zm");
	self add_option("Weapons 1", "Ice Staff", ::doweapon,"staff_water_zm");
	self add_option("Weapons 1", "Fire Staff", ::doweapon,"staff_fire_zm");
	self add_option("Weapons 1", "Wind Staff", ::doweapon,"staff_air_zm");
	self add_option("Weapons 1", "Electric Staff", ::doweapon,"sttaff_electric_zm");
	
	self add_menu("Weapons 2", "Poop v1", "Co-Host");
	self add_option("Weapons 2", "M1911", ::doweapon,"m1911_zm");
	self add_option("Weapons 2", "Mauser", ::doweapon,"c96_zm");
	self add_option("Weapons 2", "Balistic", ::doweapon,"knife_ballistic_zm");
	self add_option("Weapons 2", "Raygun", ::doweapon,"ray_gun_zm");
	self add_option("Weapons 2", "Raygun MK2", ::doweapon,"raygun_mark2_zm");
	self add_option("Weapons 2", "galil", ::doweapon,"galil_zm");
	self add_option("Weapons 2", "Python", ::doweapon,"python_zm");
	self add_option("Weapons 2", "ak74u", ::doweapon,"ak74u_zm");
	self add_option("Weapons 2", "Take All", ::takeall);

	self add_menu("Perks", "Poop v1", "Co-Host");
	self add_option("Perks", "Juggernog",::doPerks,"specialty_armorvest");
	self add_option("Perks", "Quick Revive",::doPerks,"specialty_quickrevive");
	self add_option("Perks", "Speed Cola",::doPerks,"specialty_fastreload");
	self add_option("Perks", "Double Tap",::doPerks,"specialty_rof");
	self add_option("Perks", "Mule Kick",::doPerks,"specialty_additionalprimaryweapon");
	self add_option("Perks", "Electric Cherry",::doPerks,"specialty_grenadepulldeath");
	self add_option("Perks", "PHD Flopper",::doPerks,"specialty_flakjacket");
	self add_option("Perks", "Deadshot",::doPerks,"specialty_deadshot");
	self add_option("Perks", "Stamin-Up",::doPerks,"specialty_longersprint");

	self add_menu("Rounds", "Poop v1", "Co-Host");
	self add_option("Rounds", "+1 Round", ::roundup);
	self add_option("Rounds", "+5 Rounds", ::roundsup5);
	self add_option("Rounds", "+10 Rounds", ::roundsup10);
	self add_option("Rounds", "+20 Rounds", ::roundsup20);
	self add_option("Rounds", "-1 Round", ::rounddown);
	self add_option("Rounds", "-5 Rounds", ::roundsdown5);
	self add_option("Rounds", "-10 Rounds", ::roundsdown10);
	self add_option("Rounds", "-20 Rounds", ::roundsdown20);
	self add_option("Rounds", "Round 255", ::maxround);

	self add_menu("Dev", "Poop v1", "Co-Host");
	self add_option("Dev", "Print Origin", ::origin);
	self add_option("Dev", "Print Angles", ::angles);
	self add_option("Dev", "UFO Mode", ::ufo);
	self add_option("Dev", "Disable Zombies", ::nozm);
	self add_option("Dev", "Forge Mode", ::Forge);
	

	self add_menu("PlayersMenu", "Poop v1", "Host");
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
		
		self add_option("PlayersMenu", "[" + verificationToColor(player.status) + "^7] " + playerName, ::submenu, "pOpt " + i, "Do What?");
	
		self add_menu_alt("pOpt " + i, "PlayersMenu");
		self add_option("pOpt " + i, "Give Co-Host", ::changeVerificationMenu, player, "Co-Host");
		self add_option("pOpt " + i, "Give Admin", ::changeVerificationMenu, player, "Admin");
		self add_option("pOpt " + i, "Give VIP", ::changeVerificationMenu, player, "VIP");
		self add_option("pOpt " + i, "Verify", ::changeVerificationMenu, player, "Verified");
		self add_option("pOpt " + i, "Unverify", ::changeVerificationMenu, player, "Unverified");
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
	self.menu.scroller.y = 160 + (self.menu.curs[self.menu.currentmenu] * 20.36);
}

openMenu()
{
    self StoreText("Poop v1", "Poop v1");
	
	self.menu.backgroundinfo FadeOverTime(0.3);
    self.menu.backgroundinfo.alpha = 1;

    self.menu.background FadeOverTime(0.30);
    self.menu.background.alpha = 0.80;

    self updateScrollbar();
    self.menu.open = true;
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
		self submenu("Poop v1", "Poop v1");
		closeMenu();
		self.menu.closeondeath = false;
	}
}
//Menu Colour and alignment. 
StoreShaders()
{
	self.menu.background = self drawShader("white",  -304, 130, 105, 220, (0, 0, 0), 0, 0);
	self.menu.scroller = self drawShader("white", -349, -100, 5, 18, (1, 0.42, 0.69), 125, 1);
	//x y width height
}
// ^ It goes x, y, width and height. so if you look at self.menu.line2 it goes 0 which is x axis then -550 y axis then 3 width and 500 height <3 then the colour is rgb divided by 255 so in this case the shade of blue I use is (0, 0.23, 1) ;p  
StoreText(menu, title)
{
	self.menu.currentmenu = menu;
	string = "";
    self.menu.title destroy();
	self.menu.title = drawText(title, "objective", 2, -315, 131, (1, 1, 1), 0, (0, 0, 0), 1, 5);
	self.menu.title FadeOverTime(0.3);
	self.menu.title.alpha = 1;
	
    for(i = 0; i < self.menu.menuopt[menu].size; i++)
    { string += self.menu.menuopt[menu][i] + "\n"; }
//
    self.menu.options destroy(); 
	self.menu.options = drawText(string, "objective", 1.7, -304, 160, (1, 1, 1), 0, (1, 1, 1), 0, 6);
	self.menu.options FadeOverTime(0.3);
	self.menu.options.alpha = 1;
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
			if(self useButtonPressed())
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
			if(self jumpButtonPressed())
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

		if (input == "Poop v1")
			self thread StoreText(input, "Poop v1");
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
	self GiveWeapon(i);
	self SwitchToWeapon(i);
	self GiveMaxAmmo(i);
	self iPrintln("Weapon "+self.Menu.System["MenuText"][self.Menu.System["MenuRoot"]][self.Menu.System["MenuCurser"]]+" ^2Gived");
}

takeall()
{
	self TakeAllWeapons();
	self iPrintln("All Weapons ^1Removed^7!");
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
	wait 1.5;
	self iprintln( "Player's origin: " + self.origin );
    wait .5;
}

angles()
{
	wait 1.5;
	iprintln( "Player's angles: " + self.angles );
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
		self iPrintln("Disable Zombies [^2ON^7]");
	}
	else
	{
		self.SpawningZM=false;
		if(isDefined(flag_init("spawn_zombies", 1)))
		flag_init("spawn_zombies",1);
		self thread KillZM();
		self iPrintln("Disable Zombies [^1OFF^7]");
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

Forge()
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