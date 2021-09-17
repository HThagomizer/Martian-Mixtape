package gameFolder.gameObjects;

import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxPoint;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import gameFolder.gameObjects.background.*;
import gameFolder.meta.state.PlayState;

using StringTools;

/**
	This is the stage class. It sets up everything you need for stages in a more organised and clean manner than the
	base game. It's not too bad, just very crowded. I'll be adding stages as a separate
	thing to the weeks, making them not hardcoded to the songs.
**/
class Stage extends FlxTypedGroup<FlxBasic>
{
	public var raveyard_belltower:FlxSprite;
	public var bgSkeletons:FlxSprite;
	public var danced:Bool = false;
	public var spinaltapbeam:FlxSprite;

	public var fbiSpin1:FlxSprite;
	public var fbiSpin2:FlxSprite;
	public var fbiScreen:FlxSprite;

	var lazerzfromlazerz:FlxTypedGroup<FlxSprite>;

	var defaultCamZoom:Float = 1.05;

	public var curStage:String;

	var daPixelZoom = PlayState.daPixelZoom;

	public function new(curStage)
	{
		super();

		this.curStage = curStage;

		/// get hardcoded stage type if chart is fnf style
		if (PlayState.determinedChartType == "FNF")
		{
			// this is because I want to avoid editing the fnf chart type
			// custom stage stuffs will come with forever charts
			switch (PlayState.SONG.song.toLowerCase())
			{
				case 'probed' | 'lazerz' | 'brainfuck' | 'annihilation' | 'annihilation-lol' | 'extermination':
					curStage = 'park';
				case 'marrow' | 'pelvic' | 'spinal tap':
					curStage = 'raveyard';
				case 'tinfoil' | 'itch' | 'jitter' | 'exclusion zone':
					curStage = 'freak';
				case 'boing' | 'freak':
					curStage = 'lab';
				case 'breakout':
					curStage = 'breakout';
				default:
					curStage = 'stage';
			}

			PlayState.curStage = curStage;
		}

		//

		switch (curStage)
		{
			case 'park':
				{
					PlayState.defaultCamZoom = 0.9;
					curStage = 'park';
					var park_bg:FlxSprite = new FlxSprite(-600, -500).loadGraphic(Paths.image('backgrounds/$curStage/park_sky'));
					park_bg.antialiasing = true;
					park_bg.scrollFactor.set(0.1, 0.1);
					park_bg.active = false;
					add(park_bg);

					// lazerz in lazerz!
					if (PlayState.SONG.song.toLowerCase() != 'probed')
					{
						lazerzfromlazerz = new FlxTypedGroup<FlxSprite>();

						var lazer = new FlxSprite(300, -300).loadGraphic(Paths.image('backgrounds/$curStage/lights2'));
						lazer.offset.set(lazer.width, lazer.height);
						lazerzfromlazerz.add(lazer);
						var lazer2 = new FlxSprite(700, -300).loadGraphic(Paths.image('backgrounds/$curStage/lights2'));
						lazer2.offset.set(0, lazer2.height);
						lazer2.flipX = true;
						lazerzfromlazerz.add(lazer2);
						add(lazerzfromlazerz);
					}

					var park_shrubs:FlxSprite = new FlxSprite(-500, 200).loadGraphic(Paths.image('backgrounds/$curStage/park_shrubs'));
					park_shrubs.setGraphicSize(Std.int(park_shrubs.width * 0.9));
					park_shrubs.updateHitbox();
					park_shrubs.antialiasing = true;
					park_shrubs.scrollFactor.set(0.8, 0.8);
					park_shrubs.active = false;
					add(park_shrubs);

					var park_trees:FlxSprite = new FlxSprite(-500, -500).loadGraphic(Paths.image('backgrounds/$curStage/park_trees'));
					park_trees.setGraphicSize(Std.int(park_trees.width * 0.9));
					park_trees.updateHitbox();
					park_trees.antialiasing = true;
					park_trees.scrollFactor.set(0.9, 0.9);
					park_trees.active = false;
					add(park_trees);

					var park_ground:FlxSprite = new FlxSprite(-650, 400).loadGraphic(Paths.image('backgrounds/$curStage/park_ground'));
					park_ground.setGraphicSize(Std.int(park_ground.width * 1.1));
					park_ground.updateHitbox();
					park_ground.antialiasing = true;
					park_ground.scrollFactor.set(0.9, 0.9);
					park_ground.active = false;
					add(park_ground);
				}
			// case 'fbi':
			// 	{
			// 		defaultCamZoom = 0.9;
			// 		curStage = 'fbi';

			// 		var bg:FlxSprite = new FlxSprite(-100).loadGraphic(Paths.image('backgrounds/$curStage/sky'));
			// 		bg.scrollFactor.set(0.1, 0.1);
			// 		add(bg);

			// 		var houses:FlxTiledSprite = new FlxTiledSprite(null, 256, 256, true, false).loadGraphic(Paths.image('backgrounds/$curStage/houses'));
			// 		add(houses);

					
			// 	}
			case 'raveyard':
				{
					defaultCamZoom = 0.9;
					curStage = 'raveyard';
					var raveyard_bg:FlxSprite = new FlxSprite(-550, -500).loadGraphic(Paths.image('backgrounds/$curStage/sky'));
					raveyard_bg.antialiasing = true;
					raveyard_bg.scrollFactor.set(0.1, 0.1);
					raveyard_bg.active = false;
					add(raveyard_bg);

					var raveyard_shrubs:FlxSprite = new FlxSprite(-500, 100).loadGraphic(Paths.image('backgrounds/$curStage/shrubs'));
					raveyard_shrubs.setGraphicSize(Std.int(raveyard_shrubs.width * 0.9));
					raveyard_shrubs.updateHitbox();
					raveyard_shrubs.antialiasing = true;
					raveyard_shrubs.scrollFactor.set(0.8, 0.8);
					raveyard_shrubs.active = false;
					add(raveyard_shrubs);

					raveyard_belltower = new FlxSprite(500, -300);
					raveyard_belltower.frames = Paths.getSparrowAtlas('backgrounds/$curStage/belltower');
					raveyard_belltower.animation.addByPrefix('idle', 'belltower', 24, true);
					raveyard_belltower.animation.addByPrefix('ringLEFT', 'LEFT belltower ring', 24, false);
					raveyard_belltower.animation.addByPrefix('ringRIGHT', 'RIGHT belltower ring', 24, false);
					raveyard_belltower.scrollFactor.set(0.8, 0.8);
					raveyard_belltower.animation.play('idle');
					add(raveyard_belltower);

					var raveyard_ground:FlxSprite = new FlxSprite(-900, 400).loadGraphic(Paths.image('backgrounds/$curStage/ground'));
					raveyard_ground.setGraphicSize(Std.int(raveyard_ground.width * 1.1));
					raveyard_ground.updateHitbox();
					raveyard_ground.antialiasing = true;
					raveyard_ground.scrollFactor.set(0.9, 0.9);
					raveyard_ground.active = false;
					add(raveyard_ground);

					var raveyard_gravesbacker:FlxSprite = new FlxSprite(-650, 300).loadGraphic(Paths.image('backgrounds/$curStage/gravesbacker'));
					raveyard_gravesbacker.updateHitbox();
					raveyard_gravesbacker.antialiasing = true;
					raveyard_gravesbacker.scrollFactor.set(0.9, 0.9);
					raveyard_gravesbacker.active = false;
					add(raveyard_gravesbacker);

					var raveyard_gravesback:FlxSprite = new FlxSprite(-650, 450).loadGraphic(Paths.image('backgrounds/$curStage/gravesback'));
					raveyard_gravesback.updateHitbox();
					raveyard_gravesback.antialiasing = true;
					raveyard_gravesback.scrollFactor.set(0.9, 0.9);
					raveyard_gravesback.active = false;
					add(raveyard_gravesback);

					if ((PlayState.SONG.song.toLowerCase() == 'pelvic' || PlayState.SONG.song.toLowerCase() == 'spinal tap'))
					{
						bgSkeletons = new FlxSprite(-250, 260);
						var skeletex = Paths.getSparrowAtlas('backgrounds/$curStage/skeletons');
						bgSkeletons.frames = skeletex;
						bgSkeletons.animation.addByPrefix('rise', 'skeletons rise', 24, false);
						bgSkeletons.animation.addByPrefix('idle', 'skeletons idle', 24, true);
						bgSkeletons.animation.addByPrefix('danceLEFT', 'skeletons dance left', 24, false);
						bgSkeletons.animation.addByPrefix('danceRIGHT', 'skeletons dance right', 24, false);
						bgSkeletons.animation.addByPrefix('fear cutscene', 'skeletons cutscene fear', 24, false);
						bgSkeletons.animation.addByPrefix('fear', 'skeletons fear', 24, false);
						if (PlayState.SONG.song.toLowerCase() == 'pelvic')
						{
							bgSkeletons.animation.play('rise');
						}
						else if (PlayState.SONG.song.toLowerCase() == 'spinal tap')
						{
							bgSkeletons.animation.play('fear');
						}
						bgSkeletons.scrollFactor.set(0.9, 0.9);
						add(bgSkeletons);
					}

					var raveyard_graves:FlxSprite = new FlxSprite(-400, 450).loadGraphic(Paths.image('backgrounds/$curStage/graves'));
					raveyard_graves.updateHitbox();
					raveyard_graves.antialiasing = true;
					raveyard_graves.scrollFactor.set(0.9, 0.9);
					raveyard_graves.active = false;
					add(raveyard_graves);

					var gravesfront:FlxSprite = new FlxSprite(-650, 400).loadGraphic(Paths.image('backgrounds/$curStage/gravesfront'));
					gravesfront.updateHitbox();
					gravesfront.antialiasing = true;
					gravesfront.scrollFactor.set(0.9, 0.9);
					gravesfront.active = false;

					if (PlayState.SONG.song.toLowerCase() == 'spinal tap')
					{
						spinaltapbeam = new FlxSprite(100, -100);
						spinaltapbeam.frames = Paths.getSparrowAtlas('cutscenes/w2/spinaltap-beamup');
						spinaltapbeam.animation.addByPrefix('idle', 'beam up', 24, false);
					}
				}

			case 'freak':
				{
					curStage = 'freak';
					var bg:FlxSprite = new FlxSprite(-500, -700).loadGraphic(Paths.image('backgrounds/$curStage/wallbg'));
					bg.antialiasing = true;
					bg.setGraphicSize(Std.int(bg.width * 1.3));
					bg.updateHitbox();
					bg.scrollFactor.set(0.9, 0.9);
					bg.active = false;
					add(bg);

					var pinboard:FlxSprite = new FlxSprite(450, -200).loadGraphic(Paths.image('backgrounds/$curStage/pinboard'));
					pinboard.antialiasing = true;
					pinboard.updateHitbox();
					pinboard.scrollFactor.set(0.9, 0.9);
					pinboard.active = false;
					add(pinboard);

					var backboard:FlxSprite = new FlxSprite(1150, -100).loadGraphic(Paths.image('backgrounds/$curStage/backmost pinboard'));
					backboard.antialiasing = true;
					backboard.updateHitbox();
					backboard.scrollFactor.set(0.9, 0.9);
					backboard.active = false;
					add(backboard);

					var whiteboard:FlxSprite = new FlxSprite(-200, -100).loadGraphic(Paths.image('backgrounds/$curStage/whiteboard'));
					whiteboard.antialiasing = true;
					whiteboard.updateHitbox();
					whiteboard.scrollFactor.set(0.9, 0.9);
					whiteboard.active = false;
					add(whiteboard);

					var desk:FlxSprite = new FlxSprite(800, 230).loadGraphic(Paths.image('backgrounds/$curStage/desk'));
					desk.antialiasing = true;
					desk.updateHitbox();
					desk.scrollFactor.set(0.9, 0.9);
					desk.active = false;
					add(desk);

					var board:FlxSprite = new FlxSprite(200, 300).loadGraphic(Paths.image('backgrounds/$curStage/board'));
					board.antialiasing = true;
					board.updateHitbox();
					board.scrollFactor.set(0.9, 0.9);
					board.active = false;
					add(board);

					var lights:FlxSprite = new FlxSprite(200, -100).loadGraphic(Paths.image('backgrounds/$curStage/lights'));
					lights.antialiasing = true;
					lights.updateHitbox();
					lights.scrollFactor.set(1.3, 1.3);
					lights.active = false;
					add(lights);
				}

			case 'lab':
				{
					PlayState.defaultCamZoom = 0.7;
					var bg:FlxSprite = new FlxSprite(-1000, -400).loadGraphic(Paths.image('backgrounds/$curStage/wallbg'));
					bg.antialiasing = true;
					bg.setGraphicSize(Std.int(bg.width * 1.3));
					bg.updateHitbox();
					bg.scrollFactor.set(0.4, 0.4);
					bg.active = false;
					add(bg);

					fbiScreen = new FlxSprite(200, -100);
					fbiScreen.frames = Paths.getSparrowAtlas('backgrounds/$curStage/tvfbi');
					fbiScreen.animation.addByPrefix('idle', 'tv fbi guy', 24, false);
					fbiScreen.scrollFactor.set(0.5, 0.5);
					add(fbiScreen);

					fbiSpin1 = new FlxSprite(-200, 0);
					fbiSpin1.frames = Paths.getSparrowAtlas('backgrounds/$curStage/tvspin');
					fbiSpin1.animation.addByPrefix('idle', 'spinny tv', 24, false);
					fbiSpin1.scrollFactor.set(0.5, 0.5);
					add(fbiSpin1);

					fbiSpin2 = new FlxSprite(1250, 0);
					fbiSpin2.frames = Paths.getSparrowAtlas('backgrounds/$curStage/tvspin');
					fbiSpin2.animation.addByPrefix('idle', 'spinny tv', 24, false);
					fbiSpin2.scrollFactor.set(0.5, 0.5);
					add(fbiSpin2);

					var rail:FlxSprite = new FlxSprite(-700, 350).loadGraphic(Paths.image('backgrounds/$curStage/rail'));
					rail.antialiasing = true;
					rail.updateHitbox();
					rail.scrollFactor.set(0.9, 0.9);
					rail.active = false;
					add(rail);

					var floor:FlxSprite = new FlxSprite(-1100, 400).loadGraphic(Paths.image('backgrounds/$curStage/floor'));
					floor.antialiasing = true;
					floor.setGraphicSize(Std.int(floor.width * 1.3));
					floor.updateHitbox();
					floor.scrollFactor.set(0.9, 0.9);
					floor.active = false;
					add(floor);

					var tubes:FlxSprite = new FlxSprite(-560, -120).loadGraphic(Paths.image('backgrounds/$curStage/tubes'));
					tubes.antialiasing = true;
					tubes.updateHitbox();
					tubes.scrollFactor.set(0.9, 0.9);
					tubes.active = false;
					add(tubes);
				}
			case 'breakout':
				{
					PlayState.defaultCamZoom = 0.7;
					var bg:FlxSprite = new FlxSprite(-1000, -400).loadGraphic(Paths.image('backgrounds/lab/wallbg'));
					bg.antialiasing = true;
					bg.setGraphicSize(Std.int(bg.width * 1.3));
					bg.updateHitbox();
					bg.scrollFactor.set(0.4, 0.4);
					bg.active = false;
					bg.color = 0xFF9999;
					add(bg);

					fbiScreen = new FlxSprite(200, -100);
					fbiScreen.frames = Paths.getSparrowAtlas('backgrounds/lab/tvfbi');
					fbiScreen.animation.addByPrefix('idle', 'tv fbi guy', 24, false);
					fbiScreen.scrollFactor.set(0.5, 0.5);
					fbiScreen.color = 0xFF9999;
					add(fbiScreen);

					fbiSpin1 = new FlxSprite(-200, 0);
					fbiSpin1.frames = Paths.getSparrowAtlas('backgrounds/lab/tvspin');
					fbiSpin1.animation.addByPrefix('idle', 'spinny tv', 24, false);
					fbiSpin1.scrollFactor.set(0.5, 0.5);
					fbiSpin1.color = 0xFF9999;
					add(fbiSpin1);

					fbiSpin2 = new FlxSprite(1250, 0);
					fbiSpin2.frames = Paths.getSparrowAtlas('backgrounds/lab/tvspin');
					fbiSpin2.animation.addByPrefix('idle', 'spinny tv', 24, false);
					fbiSpin2.scrollFactor.set(0.5, 0.5);
					fbiSpin2.color = 0xFF9999;
					add(fbiSpin2);

					var rail:FlxSprite = new FlxSprite(-700, 350).loadGraphic(Paths.image('backgrounds/lab/rail'));
					rail.antialiasing = true;
					rail.updateHitbox();
					rail.scrollFactor.set(0.9, 0.9);
					rail.active = false;
					rail.color = 0xFF9999;
					add(rail);

					var floor:FlxSprite = new FlxSprite(-1100, 400).loadGraphic(Paths.image('backgrounds/lab/floor'));
					floor.antialiasing = true;
					floor.setGraphicSize(Std.int(floor.width * 1.3));
					floor.updateHitbox();
					floor.scrollFactor.set(0.9, 0.9);
					floor.active = false;
					floor.color = 0xFF9999;
					add(floor);

					var tubes:FlxSprite = new FlxSprite(-560, -120).loadGraphic(Paths.image('backgrounds/lab/tubes'));
					tubes.antialiasing = true;
					tubes.updateHitbox();
					tubes.scrollFactor.set(0.9, 0.9);
					tubes.active = false;
					tubes.color = 0xFF9999;
					add(tubes);
				}
			case 'sky':
				{
					// unused secret stage LOL LOL LOL
					// looked sorta shit anyways
					PlayState.defaultCamZoom = 0.9;
					curStage = 'sky';

					var sky_bg:FlxSprite = new FlxSprite(-600, -500).loadGraphic(Paths.image('backgrounds/$curStage/skybg'));
					sky_bg.antialiasing = true;
					sky_bg.scrollFactor.set(0.1, 0.1);
					sky_bg.active = false;
					add(sky_bg);

					// fastCar = new FlxSprite(-300, 160).loadGraphic(Paths.image('week1_bg/sky/fastPlaneLol'));
				}

			default:
				PlayState.defaultCamZoom = 0.9;
				curStage = 'stage';
				var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('backgrounds/' + curStage + '/stageback'));
				bg.antialiasing = true;
				bg.scrollFactor.set(0.9, 0.9);
				bg.active = false;

				// add to the final array
				add(bg);

				var stageFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Paths.image('backgrounds/' + curStage + '/stagefront'));
				stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
				stageFront.updateHitbox();
				stageFront.antialiasing = true;
				stageFront.scrollFactor.set(0.9, 0.9);
				stageFront.active = false;

				// add to the final array
				add(stageFront);

				var stageCurtains:FlxSprite = new FlxSprite(-500, -300).loadGraphic(Paths.image('backgrounds/' + curStage + '/stagecurtains'));
				stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
				stageCurtains.updateHitbox();
				stageCurtains.antialiasing = true;
				stageCurtains.scrollFactor.set(1.3, 1.3);
				stageCurtains.active = false;

				// add to the final array
				add(stageCurtains);
		}
	}

	// return the girlfriend's type
	public function returnGFtype(curStage)
	{
		var gfVersion:String = 'gf';

		switch (curStage)
		{
			case 'park':
				gfVersion = 'gf-ufo';
			case 'raveyard':
				gfVersion = 'gf-tombstone';
			case 'breakout':
				gfVersion = 'gf-xigman';
		}

		return gfVersion;
	}

	// get the dad's position
	public function dadPosition(curStage, dad:Character, gf:Character, camPos:FlxPoint, songPlayer2):Void
	{
		switch (songPlayer2)
		{
			case 'gf':
				dad.setPosition(gf.x, gf.y);
				gf.visible = false;
			case 'alien' | 'alien-pissed' | 'alien-alt':
				dad.x += 160;
				dad.y += 110;
			case 'alien-rude':
				dad.x += 80;
				dad.y += 80;
			case 'bones':
				dad.x += 200;
				dad.y += 130;
			case 'bones-spectral':
				dad.x += 220;
				dad.y += 110;
			case 'bones-cool':
				dad.x += 180;
				dad.y += 110;
			case 'harold' | 'harold-caffeinated':
				dad.x += 200;
				dad.y += 150;
			case 'FBI':
				dad.y += 70;
				dad.x += 60;
			case 'FBIbodyguard':
				dad.y -= 70;
				dad.x -= 200;
				PlayState.health = 2;
			case 'FBIhacker':
				dad.x -= 168;
				dad.y -= 20;
			case 'xigman':
				dad.y -= 50;
			case 'ignignokt':
				dad.y += 250;
			case 'err':
				dad.y += 520;
				dad.x += 200;
		}
	}

	public function repositionPlayers(curStage, boyfriend:Character, dad:Character, gf:Character):Void
	{
		// REPOSITIONING PER STAGE
		switch (curStage)
		{
			case 'park':
				gf.x -= 300;
				gf.y -= 300;
				boyfriend.y -= 30;
				boyfriend.color = 0xa99dc9;
				dad.color = 0xa99dc9;
			case 'sky':
				dad.x -= 100;
				gf.x -= 500;
				gf.y -= 100;
			case 'raveyard':
				dad.y += 150;
				gf.y += 100;
				boyfriend.y += 100;
			case 'lab':
				gf.y -= 350;
				gf.x += 50;
			case 'breakout':
				gf.y -= 350;
				gf.x += 50;
				boyfriend.color = 0xFF9999;
				gf.color = 0xFF9999;
				dad.color = 0xFF9999;
		}
	}

	var curLight:Int = 0;
	var trainMoving:Bool = false;
	var trainFrameTiming:Float = 0;

	var trainCars:Int = 8;
	var trainFinishing:Bool = false;
	var trainCooldown:Int = 0;
	var startedMoving:Bool = false;

	public function stageUpdate(curBeat:Int, boyfriend:Boyfriend, gf:Character, dadOpponent:Character)
	{
		// trace('update backgrounds');
		switch (PlayState.curStage) {}
		//
	}

	public function stageUpdateConstant(elapsed:Float, boyfriend:Boyfriend, gf:Character, dadOpponent:Character)
	{
		switch (PlayState.curStage)
		{
			case 'park':
				if (lazerzfromlazerz != null)
				{
					var dir = -1;
					lazerzfromlazerz.forEach(function(lazer)
					{
						lazer.angle += dir;
						dir *= -1;
					});
				}
		}
	}
}
