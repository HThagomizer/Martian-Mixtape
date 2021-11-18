package gameFolder.meta.state;

import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.effects.FlxTrail;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRandom;
import flixel.math.FlxRect;
import flixel.system.FlxAssets.FlxSoundAsset;
import flixel.system.FlxSound;
import flixel.system.FlxSoundGroup;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxTimer;
import gameFolder.gameObjects.*;
import gameFolder.gameObjects.background.BackgroundCloneSpawner;
import gameFolder.gameObjects.userInterface.*;
import gameFolder.gameObjects.userInterface.notes.*;
import gameFolder.gameObjects.userInterface.notes.Strumline.UIStaticArrow;
import gameFolder.meta.*;
import gameFolder.meta.MusicBeat.MusicBeatState;
import gameFolder.meta.data.*;
import gameFolder.meta.data.Song.SwagSong;
import gameFolder.meta.state.charting.*;
import gameFolder.meta.state.menus.*;
import gameFolder.meta.subState.*;
import openfl.events.KeyboardEvent;
import openfl.media.Sound;
import openfl.utils.Assets;
import sys.FileSystem;
import sys.io.File;

using StringTools;

#if !html5
import gameFolder.meta.data.dependency.Discord;
#end

class PlayState extends MusicBeatState
{
	// fuck you haxe layering
	public static var bgCloneSpawner:BackgroundCloneSpawner;
	public static var bgCloneSpawner2:BackgroundCloneSpawner;

	public var xigchad:FlxSprite;
	public var xigchadMoves:Bool = false;

	//
	public static var startTimer:FlxTimer;

	public static var curStage:String = '';
	public static var SONG:SwagSong;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 2;

	public static var songMusic:FlxSound;
	public static var vocals:FlxSound;

	public static var campaignScore:Int = 0;

	public static var dadOpponent:Character;
	public static var gf:Character;
	public static var boyfriend:Boyfriend;

	public static var assetModifier:String = 'base';
	public static var changeableSkin:String = 'default';

	private var unspawnNotes:Array<Note> = [];
	private var secondUnspawn:Array<Note> = [];
	private var ratingArray:Array<String> = [];
	private var allSicks:Bool = true;

	// if you ever wanna add more keys
	private var numberOfKeys:Int = 4;

	// get it cus release
	// I'm funny just trust me
	private var curSection:Int = 0;
	private var camFollow:FlxObject;

	// Discord RPC variables
	public static var songDetails:String = "";
	public static var detailsSub:String = "";
	public static var detailsPausedText:String = "";

	private static var prevCamFollow:FlxObject;

	private var curSong:String = "";
	private var gfSpeed:Int = 1;

	public static var health:Float = 1; // mario
	public static var combo:Int = 0;
	public static var misses:Int = 0;

	public var generatedMusic:Bool = false;

	private var startingSong:Bool = false;
	private var paused:Bool = false;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;

	public static var camHUD:FlxCamera;
	public static var camGame:FlxCamera;
	public static var dialogueHUD:FlxCamera;

	public var camDisplaceX:Float = 0;
	public var camDisplaceY:Float = 0; // might not use depending on result

	public static var defaultCamZoom:Float = 1.05;

	public static var forceZoom:Array<Float>;

	public static var songScore:Int = 0;

	var storyDifficultyText:String = "";

	public static var iconRPC:String = "";

	public static var songLength:Float = 0;
	public static var volumeMultiplier:Float = 1;

	private var stageBuild:Stage;

	public static var uiHUD:ClassHUD;

	public static var daPixelZoom:Float = 6;
	public static var determinedChartType:String = "";

	public var mutingTime:Float = 0.0;
	public var repositionTime:Float = 0.0;
	public var hudPositionX:Int = 0;
	public var hudPositionY:Int = 0;
	public var egomaniaRandom:Bool = false;
	public var showBeatGlow:Bool = false;
	public var beatGlowAlpha:Float = 0;
	public var dadOriginX:Float = 0;
	public var dadOriginY:Float = 0;
	public var timeElapsed:Float = 0;
	public var zoomBeat:Bool = false;

	// strumlines
	private var dadStrums:Strumline;
	private var boyfriendStrums:Strumline;

	public static var strumLines:FlxTypedGroup<Strumline>;

	private var isCutscene:Bool = false;
	private var isStationaryCam:Bool = false;

	public var jitterspeed:Float = 0;

	public var xigkill:FlxSprite;

	var egoSongPushed:FlxSound;
	var egoVocalsPushed:FlxSound;

	// at the beginning of the playstate
	override public function create()
	{
		super.create();

		// reset any values and variables that are static
		songScore = 0;
		combo = 0;
		health = 1;
		misses = 0;
		volumeMultiplier = 1;

		defaultCamZoom = 1.05;
		forceZoom = [0, 0, 0, 0];

		Timings.callAccuracy();

		assetModifier = 'base';
		changeableSkin = 'default';

		// stop any existing music tracks playing
		resetMusic();
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		// create the game camera
		camGame = new FlxCamera();

		// create the hud camera (separate so the hud stays on screen)
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);
		FlxCamera.defaultCameras = [camGame];

		// default song
		if (SONG == null)
			SONG = Song.loadFromJson('test', 'test');
		// reset egomania lmfao
		if (SONG.song.toLowerCase() == 'egomania')
			SONG = Song.loadFromJson('egomania', 'egomania');

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		/// here we determine the chart type!
		// determine the chart type here
		determinedChartType = "FNF";

		//

		// set up a class for the stage type in here afterwards
		curStage = "";
		// call the song's stage if it exists
		if (SONG.stage != null)
			curStage = SONG.stage;

		// cache ratings LOL
		displayRating('sick', 'early', true);
		popUpCombo(true);

		stageBuild = new Stage(curStage);
		add(stageBuild);

		if (SONG.song.toLowerCase() == 'probed')
		{
			dadOpponent = new Character(100, 100, 'alien-alt');
			dadOpponent.alpha = 0;
			add(dadOpponent);
		}

		if (SONG.song.toLowerCase() == 'lazerz')
		{
			dadOpponent = new Character(100, 100, 'alien-pissed');
			dadOpponent.alpha = 0;
			add(dadOpponent);
		}

		// set up characters here too
		gf = new Character(400, 130, stageBuild.returnGFtype(curStage));
		gf.scrollFactor.set(1, 1);

		dadOpponent = new Character(100, 100, SONG.player2);
		boyfriend = new Boyfriend(770, 450, SONG.player1);

		var camPos:FlxPoint = new FlxPoint(gf.getMidpoint().x - 100, boyfriend.getMidpoint().y - 100);

		// set the dad's position (check the stage class to edit that!)
		// reminder that this probably isn't the best way to do this but hey it works I guess and is cleaner
		stageBuild.dadPosition(curStage, dadOpponent, gf, camPos, SONG.player2);

		// I don't like the way I'm doing this, but basically hardcode stages to charts if the chart type is the base fnf one
		// (forever engine charts will have non hardcoded stages)

		changeableSkin = Init.trueSettings.get("UI Skin");
		if ((curStage.startsWith("school")) && ((determinedChartType == "FNF")))
			assetModifier = 'pixel';

		// isPixel = true;

		// reposition characters
		stageBuild.repositionPlayers(curStage, boyfriend, dadOpponent, gf);
		dadOriginX = dadOpponent.x;
		dadOriginY = dadOpponent.y;

		if (curStage == 'lab')
		{
			xigkill = new FlxSprite(1200, -600);
			xigkill.frames = Paths.getSparrowAtlas('cutscenes/lab/xigman FUCKING KILLS');
			xigkill.animation.addByPrefix('entrance', 'xigman ENTRANCE', 24);
			xigkill.animation.addByPrefix('shake', 'xigman SHAKE', 24, true);
			xigkill.animation.addByPrefix('kill', 'xigman KILL', 42);
			xigkill.antialiasing = true;
			xigkill.updateHitbox();
			xigkill.scrollFactor.set(1, 1);
			xigkill.visible = false;
			add(xigkill);
		}

		// add characters
		add(gf);

		// once again fuck you haxe layering
		if (curStage == 'breakout')
		{
			if (!Init.trueSettings.get('Photosensitivity Tweaks'))
			{
				bgCloneSpawner = new BackgroundCloneSpawner(false);
				add(bgCloneSpawner);

				xigchad = new FlxSprite(-1000, 160);
				xigchad.frames = Paths.getSparrowAtlas('backgrounds/$curStage/clones/chad');
				xigchad.animation.addByPrefix('walk', 'magnificent runner', 12);
				xigchad.animation.play("walk");

				xigchad.antialiasing = true;
				xigchad.color = 0xFF9999;
				xigchad.updateHitbox();
				xigchad.scrollFactor.set(1, 1);
				add(xigchad);
			}
		}
		//

		add(dadOpponent);
		add(boyfriend);

		// death
		if (curStage == 'breakout')
		{
			if (!Init.trueSettings.get('Photosensitivity Tweaks'))
			{
				bgCloneSpawner2 = new BackgroundCloneSpawner(true);
				add(bgCloneSpawner2);
			}
		}
		///

		// force them to dance
		dadOpponent.dance();
		gf.dance();
		boyfriend.dance();

		// set song position before beginning
		Conductor.songPosition = -(Conductor.crochet * 4);

		// strum setup
		strumLines = new FlxTypedGroup<Strumline>();

		// generate the song
		generateSong(SONG.song);

		// set the camera position to the center of the stage
		camPos.set(gf.x + (gf.frameWidth / 2), gf.y + (gf.frameHeight / 2));

		// create the game camera
		camFollow = new FlxObject(0, 0, 1, 1);
		camFollow.setPosition(camPos.x, camPos.y);

		// check if the camera was following someone previouslyw
		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}

		add(camFollow);

		// actually set the camera up
		var camLerp = Main.framerateAdjust(0.04);
		FlxG.camera.follow(camFollow, LOCKON, camLerp);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow.getPosition());

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		// initialize ui elements
		startingSong = true;
		startedCountdown = true;

		//
		var placement = (FlxG.width / 2);
		dadStrums = new Strumline(placement - (FlxG.width / 4), this, dadOpponent, false, true, false, 4, Init.trueSettings.get('Downscroll'));
		dadStrums.visible = !Init.trueSettings.get('Centered Notefield');
		boyfriendStrums = new Strumline(placement + (!Init.trueSettings.get('Centered Notefield') ? (FlxG.width / 4) : 0), this, boyfriend, true, false, true,
			4, Init.trueSettings.get('Downscroll'));

		strumLines.add(dadStrums);
		strumLines.add(boyfriendStrums);
		strumLines.cameras = [camHUD];
		add(strumLines);

		uiHUD = new ClassHUD();
		add(uiHUD);
		uiHUD.cameras = [camHUD];
		//

		// create a hud over the hud camera for dialogue
		dialogueHUD = new FlxCamera();
		dialogueHUD.bgColor.alpha = 0;
		FlxG.cameras.add(dialogueHUD);

		// preload crack cutscene shit
		if (curSong == 'Crack')
		{
				var crackPreload:FlxSprite = new FlxSprite().loadGraphic(Paths.image('characters/hominid/alien_hominid'));
				add(crackPreload);
				crackPreload.visible = false;
		}

		// preload egomania shit
		if (curSong == 'Egomania')
		{
			var egoPreload:FlxSprite = new FlxSprite().loadGraphic(Paths.image("dialogue/portraits/hank"));
			add(egoPreload);
			egoPreload.visible = false;
			var textboxPreload:FlxSprite = new FlxSprite().loadGraphic(Paths.image("dialogue/boxes/speech_bubble_talking/speech_bubble_talking"));
			add(textboxPreload);
			textboxPreload.visible = false;

			// evil hank
			var rageHank:FlxSprite = new FlxSprite().loadGraphic(Paths.image("characters/secret character/hank-RAGE"));
			add(rageHank);
			rageHank.visible = false;

			var tempSong = Song.loadFromJson('egomania-2', 'egomania');
			Conductor.changeBPM(tempSong.bpm);
			secondUnspawn = ChartLoader.generateChartType(tempSong, determinedChartType);
			Conductor.changeBPM(SONG.bpm);
			secondUnspawn.sort(sortByShit);

			egoSongPushed = new FlxSound().loadEmbedded(Sound.fromFile('./' + 'assets/songs/egomania/Inst-2.ogg'), false, true);
			egoSongPushed.play();
			egoSongPushed.pause();
			egoSongPushed.time = 0;
			egoVocalsPushed = new FlxSound().loadEmbedded(Sound.fromFile('./' + 'assets/songs/egomania/Voices-2.ogg'), false, true);
			egoVocalsPushed.play();
			egoVocalsPushed.pause();
			egoSongPushed.time = 0;
		}

		if (isStoryMode)
			songIntroCutscene();
		else
			switch (curSong.toLowerCase())
			{
				case 'marrow':
					isCutscene = true;
					isStationaryCam = true;
					FlxTween.tween(dadOpponent, {color: 0x000000}, 0.1);
					FlxTween.tween(uiHUD.iconP2, {color: 0x000000}, 0.1);
					camFollow.setPosition(dadOpponent.getMidpoint().x + 350, -300);
					FlxG.camera.focusOn(camFollow.getPosition());
					FlxG.camera.zoom = 1.5;
					FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 2.5, {
						ease: FlxEase.quadInOut,
						onComplete: function(twn:FlxTween)
						{
							isCutscene = false;
							startCountdown();
						}
					});
				case 'pelvic':
					uiHUD.iconP2.updateIcon('bones');
					remove(dadOpponent);
					dadOpponent.generateCharacter(100, 100, 'bones');
					add(dadOpponent);
					dadOpponent.x += 320;
					dadOpponent.y += 260;
					FlxTween.tween(dadOpponent, {color: 0x000000}, 0.1);
					startCountdown();
				default:
					callTextbox();
			}

		// */
	}

	var staticDisplace:Int = 0;
	var immuneTest:Bool = false;

	override public function update(elapsed:Float)
	{
		stageBuild.stageUpdateConstant(elapsed, boyfriend, gf, dadOpponent);

		super.update(elapsed);

		timeElapsed += elapsed;
		FlxG.camera.followLerp = elapsed * 2;

		if (health > 2)
			health = 2;

		if (repositionTime > 0)
		{
			camHUD.x = FlxMath.lerp(camHUD.x, hudPositionX, elapsed * 2);
			camHUD.y = FlxMath.lerp(camHUD.y, hudPositionY, elapsed * 2);
			repositionTime -= elapsed;
			if (repositionTime <= 0)
			{
				repositionTime = 0;
			}
		}
		else
		{
			camHUD.x = FlxMath.lerp(camHUD.x, 0, elapsed * 2);
			camHUD.y = FlxMath.lerp(camHUD.y, 0, elapsed * 2);
		}

		if (mutingTime > 0)
		{
			mutingTime -= elapsed;
			if (mutingTime <= 0)
			{
				mutingTime = 0;
			}
		}

		// dialogue checks
		if (dialogueBox != null && dialogueBox.alive)
		{
			// the change I made was just so that it would only take accept inputs
			if (FlxG.keys.anyJustPressed([dialogueBox.pressKey]) && dialogueBox.textStarted)
			{
				if (dialogueBox.finishedTyping)
				{
					FlxG.sound.play(Paths.sound('cancelMenu'));
					dialogueBox.curPage += 1;

					if (dialogueBox.curPage == dialogueBox.dialogueData.dialogue.length)
					{
						dialogueBox.closeDialog();
						volumeMultiplier = 1;

						songMusic.volume = 1 * volumeMultiplier;
						vocals.volume = 1 * volumeMultiplier;
						distractionVisible = false;

						isCutscene = false;
						startedCountdown = true;
					}
					else
						dialogueBox.updateDialog();
				}
				else
				{
					dialogueBox.finishTyping();
				}
			}
		}

		// pause the game if the game is allowed to pause and enter is pressed
		if (FlxG.keys.justPressed.ENTER && startedCountdown && canPause && !isCutscene && !distractionVisible)
		{
			// update drawing stuffs
			persistentUpdate = false;
			persistentDraw = true;
			paused = true;

			// open pause substate
			openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
			updateRPC(true);
		}

		// make sure you're not cheating lol
		if (!isStoryMode)
		{
			// charting state (more on that later)
			if ((FlxG.keys.justPressed.SEVEN) && (!startingSong))
			{
				resetMusic();
				if (Init.trueSettings.get('Use Forever Chart Editor'))
					Main.switchState(this, new ChartingState());
				else
					Main.switchState(this, new OriginalChartingState());
			}
		}

		///*
		if (startingSong)
		{
			if (startedCountdown && !isCutscene)
			{
				Conductor.songPosition += elapsed * 1000;
				if (Conductor.songPosition >= 0)
					startSong();
			}
		}
		else
		{
			// Conductor.songPosition = FlxG.sound.music.time;
			Conductor.songPosition += elapsed * 1000;

			if (!paused)
			{
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				// Interpolation type beat
				if (Conductor.lastSongPos != Conductor.songPosition)
				{
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
					// Conductor.songPosition += FlxG.elapsed * 1000;
					// trace('MISSED FRAME');
				}
			}

			// Conductor.lastSongPos = FlxG.sound.music.time;
			// song shit for testing lols
		}

		// boyfriend.playAnim('singLEFT', true);
		// */

		if (generatedMusic && !isCutscene && !isStationaryCam && PlayState.SONG.notes[Std.int(curStep / 16)] != null)
		{
			if (!PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection)
			{
				var char = dadOpponent;

				var getCenterX = char.getMidpoint().x + 150;
				var getCenterY = char.getMidpoint().y - 100;
				switch (dadOpponent.curCharacter)
				{
					case 'FBImech':
						getCenterY = char.getMidpoint().y - 850;
						getCenterX = char.getMidpoint().x - 500;
					case 'mooninites':
						getCenterY = char.getMidpoint().y;
					case 'alien-ouch':
						getCenterY = char.getMidpoint().y + 80;
						getCenterX = char.getMidpoint().x - 50;
				}

				camFollow.setPosition(getCenterX + (camDisplaceX * 8), getCenterY);

				///*
				switch (SONG.song.toLowerCase())
				{
					case 'annihilation' | 'annihilation-lol':
						forceZoom[0] = -0.15;
					case 'aneurysmia':
						forceZoom[0] = -0.075;
					case 'enforcement':
						forceZoom[0] = -0.85;
				}

				// */
			}
			else
			{
				var char = boyfriend;

				var getCenterX = char.getMidpoint().x - 100;
				var getCenterY = char.getMidpoint().y - 100;
				///*
				switch (SONG.song.toLowerCase())
				{
					case 'annihilation' | 'annihilation-lol' | 'aneurysmia':
						forceZoom[0] = 0;
					case 'enforcement':
						forceZoom[0] = -0.65;
						getCenterY -= 200;
				}

				camFollow.setPosition(getCenterX + (camDisplaceX * 8), getCenterY);
				//*/
			}

			if (curStage == 'sky')
			{
				var char = gf;

				var getCenterX = char.getMidpoint().x + 75;
				var getCenterY = char.getMidpoint().y + 300;

				camFollow.setPosition(getCenterX, getCenterY);
			}
		}

		var easeLerp = 0.95;
		// camera stuffs
		FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom + forceZoom[0], FlxG.camera.zoom, easeLerp);
		camHUD.zoom = FlxMath.lerp(1 + forceZoom[1], camHUD.zoom, easeLerp);

		// not even forcezoom anymore but still
		FlxG.camera.angle = FlxMath.lerp(0 + forceZoom[2], FlxG.camera.angle, easeLerp);
		camHUD.angle = FlxMath.lerp(0 + forceZoom[3], camHUD.angle, easeLerp);

		if (health <= 0 && !immuneTest && startedCountdown)
		{
			// startTimer.active = false;
			persistentUpdate = false;
			persistentDraw = false;
			paused = true;

			resetMusic();

			openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

			// discord stuffs should go here
		}

		// spawn in the notes from the array
		if ((unspawnNotes[0] != null) && ((unspawnNotes[0].strumTime - Conductor.songPosition) < 3500))
		{
			var dunceNote:Note = unspawnNotes[0];
			// push note to its correct strumline
			strumLines.members[Math.floor((dunceNote.noteData + (dunceNote.mustPress ? 4 : 0)) / numberOfKeys)].push(dunceNote);
			unspawnNotes.splice(unspawnNotes.indexOf(dunceNote), 1);
		}

		if (!isCutscene)
			noteCalls();

		if (curStage == 'sky')
		{
			if (showBeatGlow)
			{
				beatGlowAlpha = FlxMath.lerp(beatGlowAlpha, 1, elapsed * 8);
			}
			else
			{
				beatGlowAlpha = FlxMath.lerp(beatGlowAlpha, 0, elapsed * 8);
			}
			stageBuild.beatglow.alpha = FlxMath.roundDecimal((beatGlowAlpha * 2), 1) / 2;
		}

		if (curStage == 'breakout' && xigchadMoves)
		{
			if (!Init.trueSettings.get('Photosensitivity Tweaks'))
			{
				xigchad.x += 240 * elapsed;
			}
		}

		if (dadOpponent.curCharacter == "alien-power" && !isCutscene && curBeat < 128)
		{
			var char = dadOpponent;
			char.y = (dadOriginY + (Math.sin(timeElapsed * 2) * 100)) - 75;

			if (curBeat > 63)
				char.x = (dadOriginX + (Math.sin(timeElapsed * 4) * 50)) - 25;
		}
	}

	function noteCalls()
	{
		// (control stuffs don't go here they go in noteControls(), I just have them here so I don't call them every. single. time. noteControls() is called)
		var up = controls.UP;
		var right = controls.RIGHT;
		var down = controls.DOWN;
		var left = controls.LEFT;

		var upP = controls.UP_P;
		var rightP = controls.RIGHT_P;
		var downP = controls.DOWN_P;
		var leftP = controls.LEFT_P;

		var upR = controls.UP_R;
		var rightR = controls.RIGHT_R;
		var downR = controls.DOWN_R;
		var leftR = controls.LEFT_R;

		var holdControls = [left, down, up, right];
		var pressControls = [leftP, downP, upP, rightP];
		var releaseControls = [leftR, downR, upR, rightR];

		// reset strums
		for (strumline in strumLines)
		{
			// handle strumline stuffs
			var i = 0;
			for (uiNote in strumline.receptors)
			{
				if (strumline.autoplay)
					strumCallsAuto(uiNote);
			}

			if (strumline.splashNotes != null)
				for (i in 0...strumline.splashNotes.length)
				{
					strumline.splashNotes.members[i].x = strumline.receptors.members[i].x - 48;
					strumline.splashNotes.members[i].y = strumline.receptors.members[i].y - 56;
				}
		}

		if (generatedMusic)
		{
			for (strumline in strumLines)
			{
				if (!strumline.autoplay)
					controlPlayer(strumline.character, strumline.autoplay, strumline, holdControls, pressControls, releaseControls);

				strumline.notesGroup.forEachAlive(function(daNote:Note)
				{
					// set the notes x and y
					var downscrollMultiplier = 1;
					if (Init.trueSettings.get('Downscroll'))
						downscrollMultiplier = -1;

					var psuedoY:Float = (downscrollMultiplier *
						-((Conductor.songPosition - daNote.strumTime) * (0.45 * FlxMath.roundDecimal(daNote.noteSpeed, 2))));

					var psuedoX = 25 + daNote.noteVisualOffset;

					daNote.y = strumline.receptors.members[Math.floor(daNote.noteData)].y
						+ (Math.cos(flixel.math.FlxAngle.asRadians(daNote.noteDirection)) * psuedoY)
						+ (Math.sin(flixel.math.FlxAngle.asRadians(daNote.noteDirection)) * psuedoX);
					// painful math equation
					daNote.x = strumline.receptors.members[Math.floor(daNote.noteData)].x
						+ (Math.cos(flixel.math.FlxAngle.asRadians(daNote.noteDirection)) * psuedoX)
						+ (Math.sin(flixel.math.FlxAngle.asRadians(daNote.noteDirection)) * psuedoY);

					if (daNote.isSustainNote)
					{
						// note alignments (thanks pixl for pointing out what made old downscroll weird)
						if ((daNote.animation.curAnim.name.endsWith('holdend')) && (daNote.prevNote != null))
						{
							if (Init.trueSettings.get('Downscroll'))
								daNote.y += (daNote.prevNote.height);
							else
								daNote.y -= ((daNote.prevNote.height / 2));
						}
						else
							daNote.y -= ((daNote.height / 2) * downscrollMultiplier);
						if (Init.trueSettings.get('Downscroll'))
							daNote.flipY = true;
					}

					// also set note rotation
					daNote.angle = -daNote.noteDirection;

					// hell breaks loose here, we're using nested scripts!
					mainControls(daNote, strumline.character, strumline, strumline.autoplay);

					// check where the note is and make sure it is either active or inactive
					if (daNote.y > FlxG.height)
					{
						daNote.active = false;
						daNote.visible = false;
					}
					else
					{
						daNote.visible = true;
						daNote.active = true;
					}

					// if the note is off screen (above)
					if (((!Init.trueSettings.get('Downscroll')) && (daNote.y < -daNote.height))
						|| ((Init.trueSettings.get('Downscroll')) && (daNote.y > (FlxG.height + daNote.height))))
					{
						if ((daNote.tooLate || !daNote.wasGoodHit) && (daNote.mustPress))
						{
							vocals.volume = 0;
							missNoteCheck((Init.trueSettings.get('Ghost Tapping')) ? true : false, daNote.noteData, boyfriend, true);
							// ambiguous name
							Timings.updateAccuracy(0);
						}

						daNote.active = false;
						daNote.visible = false;

						// note damage here I guess
						daNote.kill();
						if (strumline.notesGroup.members.contains(daNote))
							strumline.notesGroup.remove(daNote, true);
						daNote.destroy();
					}
				});
			}
		}
	}

	function controlPlayer(character:Character, autoplay:Bool, characterStrums:Strumline, holdControls:Array<Bool>, pressControls:Array<Bool>,
			releaseControls:Array<Bool>)
	{
		if (!autoplay)
		{
			// check if anything is pressed
			if (pressControls.contains(true))
			{
				// check all of the controls
				for (i in 0...pressControls.length)
				{
					// improved this a little bit, maybe its a lil
					var possibleNoteList:Array<Note> = [];
					var pressedNotes:Array<Note> = [];

					characterStrums.notesGroup.forEachAlive(function(daNote:Note)
					{
						if ((daNote.noteData == i) && daNote.canBeHit && !daNote.tooLate && !daNote.wasGoodHit)
							possibleNoteList.push(daNote);
					});
					possibleNoteList.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

					// if there is a list of notes that exists for that control
					if (possibleNoteList.length > 0)
					{
						var eligable = true;
						var firstNote = true;
						// loop through the possible notes
						for (coolNote in possibleNoteList)
						{
							// and if a note is being pressed
							if (pressControls[coolNote.noteData])
							{
								for (noteDouble in pressedNotes)
								{
									if (Math.abs(noteDouble.strumTime - coolNote.strumTime) < 10)
										firstNote = false;
									else
										eligable = false;
								}

								if (eligable)
								{
									goodNoteHit(coolNote, character, characterStrums, firstNote); // then hit the note
									pressedNotes.push(coolNote);
								}
							}
							// end of this little check
						}
						//
					}
					else // else just call bad notes
						if (!Init.trueSettings.get('Ghost Tapping') && pressControls[i])
							missNoteCheck(true, i, character, true);
					//
				}
			}

			// check if anything is held
			if (holdControls.contains(true))
			{
				// check notes that are alive
				characterStrums.notesGroup.forEachAlive(function(coolNote:Note)
				{
					if (coolNote.canBeHit && coolNote.mustPress && coolNote.isSustainNote && holdControls[coolNote.noteData])
						goodNoteHit(coolNote, character, characterStrums);
				});
			}

			// control camera movements
			// strumCameraRoll(characterStrums, true);

			characterStrums.receptors.forEach(function(strum:UIStaticArrow)
			{
				if ((pressControls[strum.ID]) && (strum.animation.curAnim.name != 'confirm'))
					strum.playAnim('pressed');
				if (releaseControls[strum.ID])
					strum.playAnim('static');
				//
			});
		}

		// reset bf's animation
		if ((character != null && character.animation != null)
			&& (character.holdTimer > Conductor.stepCrochet * (4 / 1000) && (!holdControls.contains(true) || autoplay)))
		{
			if (character.animation.curAnim.name.startsWith('sing') && !character.animation.curAnim.name.endsWith('miss'))
				character.dance();
		}
	}

	var altString:String = '';

	function goodNoteHit(coolNote:Note, character:Character, characterStrums:Strumline, ?canDisplayJudgement:Bool = true)
	{
		if (!coolNote.wasGoodHit)
		{
			coolNote.wasGoodHit = true;
			vocals.volume = 1 * volumeMultiplier;

			characterPlayAnimation(coolNote, character);
			if (characterStrums.receptors.members[coolNote.noteData] != null)
				characterStrums.receptors.members[coolNote.noteData].playAnim('confirm', true);

			if (canDisplayJudgement)
			{
				// special thanks to sam, they gave me the original system which kinda inspired my idea for this new one

				// get the note ms timing
				var noteDiff:Float = Math.abs(coolNote.strumTime - Conductor.songPosition + 4);
				trace(noteDiff);
				// get the timing
				if (coolNote.strumTime < Conductor.songPosition)
					ratingTiming = "late";
				else
					ratingTiming = "early";

				// loop through all avaliable judgements
				var foundRating:String = 'miss';
				var lowestThreshold:Float = Math.POSITIVE_INFINITY;
				for (myRating in Timings.judgementsMap.keys())
				{
					var myThreshold:Float = Timings.judgementsMap.get(myRating)[1];
					if (noteDiff <= myThreshold && (myThreshold < lowestThreshold))
					{
						foundRating = myRating;
						lowestThreshold = myThreshold;
					}
				}

				if (!coolNote.isSustainNote)
				{
					increaseCombo(foundRating, coolNote.noteData, character);
					popUpScore(foundRating, ratingTiming, characterStrums, coolNote);
					healthCall(Timings.judgementsMap.get(foundRating)[3]);
				}
				else if (coolNote.isSustainNote)
				{
					// call updated accuracy stuffs
					Timings.updateAccuracy(100, true);
					if (coolNote.animation.name.endsWith('holdend'))
						healthCall(100);
				}
			}

			if (!coolNote.isSustainNote)
			{
				// coolNote.callMods();
				if (altString != 'miss')
				{
					characterStrums.receptors.members[coolNote.noteData].playAnim('confirm', true);

					if (!coolNote.isSustainNote)
					{
						// coolNote.callMods();
						coolNote.kill();
						if (characterStrums.notesGroup.members.contains(coolNote))
							characterStrums.notesGroup.remove(coolNote, true);
						coolNote.destroy();
					}
				}
				else
					characterStrums.receptors.members[coolNote.noteData].playAnim('pressed', true);
			}
			//
		}
	}

	function missNoteCheck(?includeAnimation:Bool = false, direction:Int = 0, character:Character, popMiss:Bool = false, lockMiss:Bool = false)
	{
		if (includeAnimation)
		{
			var stringDirection:String = UIStaticArrow.getArrowFromNumber(direction);

			FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));
			character.playAnim('sing' + stringDirection.toUpperCase() + 'miss', lockMiss);
		}
		decreaseCombo(popMiss);

		//
	}

	function characterPlayAnimation(coolNote:Note, character:Character)
	{
		// alright so we determine which animation needs to play
		// get alt strings and stuffs
		var stringArrow:String = '';
		altString = '';

		var baseString = 'sing' + UIStaticArrow.getArrowFromNumber(coolNote.noteData).toUpperCase();

		// I tried doing xor and it didnt work lollll
		if (coolNote.noteAlt > 0)
			altString = '-alt';
		if (((SONG.notes[Math.floor(curStep / 16)] != null) && (SONG.notes[Math.floor(curStep / 16)].altAnim))
			&& (character.animOffsets.exists(baseString + '-alt')))
		{
			if (altString != '-alt')
				altString = '-alt';
			else
				altString = '';
		}

		if (character == dadOpponent && dadOpponent.curCharacter == 'FBI' && health > 1.2)
			altString = '-alt';

		if ((curSong == 'Annihilation-Lol') && (character == dadOpponent))
		{
			switch (curStep)
			{
				case 139 | 201 | 205 | 215 | 216 | 219 | 146 | 156 | 199 | 204 | 210 | 161 | 164 | 178 | 186 | 200 | 203 | 209 | 217 | 168 | 172 | 182 | 184 |
					196 | 197 | 214 | 218:
					altString = 'miss';
					healthCall(100);
			}
		}

		stringArrow = baseString + altString;

		character.playAnim(stringArrow, true);

		if (character == dadOpponent && uiHUD.healthBar.percent > 50 && dadOpponent.curCharacter == 'FBI')
			health -= 0.03;

		character.holdTimer = 0;
	}

	private function strumCallsAuto(cStrum:UIStaticArrow, ?callType:Int = 1, ?daNote:Note):Void
	{
		switch (callType)
		{
			case 1:
				// end the animation if the calltype is 1 and it is done
				if ((cStrum.animation.finished) && (cStrum.canFinishAnimation))
					cStrum.playAnim('static');
			default:
				// check if it is the correct strum
				if (daNote.noteData == cStrum.ID)
				{
					// if (cStrum.animation.curAnim.name != 'confirm')
					cStrum.playAnim('confirm'); // play the correct strum's confirmation animation (haha rhymes)

					// stuff for sustain notes
					if ((daNote.isSustainNote) && (!daNote.animation.curAnim.name.endsWith('holdend')))
						cStrum.canFinishAnimation = false; // basically, make it so the animation can't be finished if there's a sustain note below
					else
						cStrum.canFinishAnimation = true;
				}
		}
	}

	private function mainControls(daNote:Note, char:Character, strumline:Strumline, autoplay:Bool):Void
	{
		var notesPressedAutoplay = [];
		// I have no idea what I have done
		var downscrollMultiplier = 1;
		if (Init.trueSettings.get('Downscroll'))
			downscrollMultiplier = -1;

		// im very sorry for this if condition I made it worse lmao
		///*
		if (daNote.isSustainNote
			&& (((daNote.y + daNote.offset.y <= (strumline.receptors.members[Math.floor(daNote.noteData)].y + Note.swagWidth / 2))
				&& !Init.trueSettings.get('Downscroll'))
				|| (((daNote.y - (daNote.offset.y * daNote.scale.y) + daNote.height) >= (strumline.receptors.members[Math.floor(daNote.noteData)].y
					+ Note.swagWidth / 2))
					&& Init.trueSettings.get('Downscroll')))
			&& (autoplay || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
		{
			var swagRectY = ((strumline.receptors.members[Math.floor(daNote.noteData)].y + Note.swagWidth / 2 - daNote.y) / daNote.scale.y);
			var swagRect = new FlxRect(0, 0, daNote.width * 2, daNote.height * 2);
			// I feel genuine pain
			// basically these should be flipped based on if it is downscroll or not
			if (Init.trueSettings.get('Downscroll'))
			{
				swagRect.height = swagRectY;
				swagRect.y -= swagRect.height - daNote.height;
			}
			else
			{
				swagRect.y = swagRectY;
				swagRect.height -= swagRect.y;
			}

			daNote.clipRect = swagRect;
		}
		// */

		// here I'll set up the autoplay functions
		if (autoplay)
		{
			// check if the note was a good hit
			if (daNote.strumTime <= Conductor.songPosition)
			{
				// use a switch thing cus it feels right idk lol
				// make sure the strum is played for the autoplay stuffs
				/*
					charStrum.forEach(function(cStrum:UIStaticArrow)
					{
						strumCallsAuto(cStrum, 0, daNote);
					});
				 */

				// kill the note, then remove it from the array
				var canDisplayJudgement = false;
				if (strumline.displayJudgements)
				{
					canDisplayJudgement = true;
					for (noteDouble in notesPressedAutoplay)
					{
						if (noteDouble.noteData == daNote.noteData)
						{
							// if (Math.abs(noteDouble.strumTime - daNote.strumTime) < 10)
							canDisplayJudgement = false;
							// removing the fucking check apparently fixes it
							// god damn it that stupid glitch with the double judgements is annoying
						}
						//
					}
					notesPressedAutoplay.push(daNote);
				}

				goodNoteHit(daNote, char, strumline, canDisplayJudgement);
			}
			//
		}

		// unoptimised asf camera control based on strums
		strumCameraRoll(strumline.receptors, daNote.mustPress);
	}

	private function strumCameraRoll(cStrum:FlxTypedGroup<UIStaticArrow>, mustHit:Bool)
	{
		if (!Init.trueSettings.get('No Camera Note Movement'))
		{
			var camDisplaceExtend:Float = 1.5;
			var camDisplaceSpeed = 0.0125;
			if (PlayState.SONG.notes[Std.int(curStep / 16)] != null)
			{
				if ((PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection && mustHit)
					|| (!PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection && !mustHit))
				{
					if ((cStrum.members[0].animation.curAnim.name == 'confirm') && (camDisplaceX > -camDisplaceExtend))
						camDisplaceX -= camDisplaceSpeed;
					else if ((cStrum.members[3].animation.curAnim.name == 'confirm') && (camDisplaceX < camDisplaceExtend))
						camDisplaceX += camDisplaceSpeed;
				}
			}
		}
		//
	}

	override public function onFocus():Void
	{
		if (!paused)
			updateRPC(false);
		super.onFocus();
	}

	override public function onFocusLost():Void
	{
		updateRPC(true);
		super.onFocusLost();
	}

	public static function updateRPC(pausedRPC:Bool)
	{
		#if !html5
		var displayRPC:String = (pausedRPC) ? detailsPausedText : songDetails;

		if (health > 0)
		{
			if (Conductor.songPosition > 0 && !pausedRPC)
				Discord.changePresence(displayRPC, detailsSub, iconRPC, true, songLength - Conductor.songPosition);
			else
				Discord.changePresence(displayRPC, detailsSub, iconRPC);
		}
		#end
	}

	var animationsPlay:Array<Note> = [];

	private var ratingTiming:String = "";

	function popUpScore(baseRating:String, timing:String, strumline:Strumline, coolNote:Note)
	{
		// set up the rating
		var score:Int = 50;

		// notesplashes
		if (baseRating == "sick") // create the note splash if you hit a sick
			createSplash(coolNote, strumline);
		else // if it isn't a sick, and you had a sick combo, then it becomes not sick :(
			if (allSicks)
				allSicks = false;

		displayRating(baseRating, timing);
		Timings.updateAccuracy(Timings.judgementsMap.get(baseRating)[3]);
		score = Std.int(Timings.judgementsMap.get(baseRating)[2]);

		songScore += score;

		popUpCombo();
	}

	public function createSplash(coolNote:Note, strumline:Strumline)
	{
		// play animation in existing notesplashes
		var noteSplashRandom:String = (Std.string((FlxG.random.int(0, 1) + 1)));
		if (strumline.splashNotes != null)
			strumline.splashNotes.members[coolNote.noteData].playAnim('anim' + noteSplashRandom);
	}

	private var createdColor = FlxColor.fromRGB(204, 66, 66);

	function popUpCombo(?preload:Bool = false)
	{
		var comboString:String = Std.string(combo);
		var negative = false;
		if ((comboString.startsWith('-')) || (combo == 0))
			negative = true;
		var stringArray:Array<String> = comboString.split("");
		for (scoreInt in 0...stringArray.length)
		{
			// numScore.loadGraphic(Paths.image('UI/' + pixelModifier + 'num' + stringArray[scoreInt]));
			var numScore = ForeverAssets.generateCombo('combo', stringArray[scoreInt], (!negative ? allSicks : false), assetModifier, changeableSkin, 'UI',
				negative, createdColor, scoreInt);
			add(numScore);
			// hardcoded lmao
			if (Init.trueSettings.get('Fixed Judgements'))
			{
				numScore.cameras = [camHUD];
				numScore.x += 100;
				numScore.y += 50;
			}

			if (preload)
				numScore.visible = false;

			FlxTween.tween(numScore, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween)
				{
					numScore.kill();
				},
				startDelay: Conductor.crochet * 0.002
			});
		}
	}

	function decreaseCombo(?popMiss:Bool = false)
	{
		// painful if statement
		if (((combo > 5) || (combo < 0)) && (gf.animOffsets.exists('sad')))
			gf.playAnim('sad');

		if (combo > 0)
			combo = 0; // bitch lmao
		else
			combo--;

		// misses
		songScore -= 10;
		misses++;

		// display negative combo
		if (popMiss)
		{
			// doesnt matter miss ratings dont have timings
			displayRating("miss", 'late');
			healthCall(Timings.judgementsMap.get("miss")[3]);
		}
		popUpCombo();

		// gotta do it manually here lol
		Timings.updateFCDisplay();
	}

	function increaseCombo(?baseRating:String, ?direction = 0, ?character:Character)
	{
		// trolled this can actually decrease your combo if you get a bad/shit/miss
		if (baseRating != null)
		{
			if (Timings.judgementsMap.get(baseRating)[3] > 0)
			{
				if (combo < 0)
					combo = 0;
				combo += 1;
			}
			else
				missNoteCheck(true, direction, character, false, true);
		}
	}

	public function displayRating(daRating:String, timing:String, ?cache:Bool = false)
	{
		/* so you might be asking
			"oh but if the rating isn't sick why not just reset it"
			because miss judgements can pop, and they dont mess with your sick combo
		 */
		var rating = ForeverAssets.generateRating('$daRating', (daRating == 'sick' ? allSicks : false), timing, assetModifier, changeableSkin, 'UI');
		add(rating);

		if (Init.trueSettings.get('Fixed Judgements'))
		{
			// bound to camera
			rating.cameras = [camHUD];
			rating.screenCenter();
		}

		// set new smallest rating
		if (Timings.smallestRating != daRating)
		{
			if (Timings.judgementsMap.get(Timings.smallestRating)[0] < Timings.judgementsMap.get(daRating)[0])
				Timings.smallestRating = daRating;
		}

		if (cache)
			rating.visible = false;

		///*
		FlxTween.tween(rating, {alpha: 0}, 0.2, {
			onComplete: function(tween:FlxTween)
			{
				rating.kill();
			},
			startDelay: Conductor.crochet * 0.00125
		});
		// */
	}

	function healthCall(?ratingMultiplier:Float = 0)
	{
		// health += 0.012;
		var healthBase:Float = 0.06;
		var additiveHealth:Float = (healthBase * (ratingMultiplier / 100));

		if (additiveHealth < 0 || dadOpponent.curCharacter != 'FBIbodyguard')
			health += additiveHealth;
	}

	function startSong():Void
	{
		startingSong = false;

		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		if (!paused)
		{
			songMusic.play();
			songMusic.onComplete = endSong;
			vocals.play();

			resyncVocals();

			#if !html5
			// Song duration in a float, useful for the time left feature
			songLength = songMusic.length;

			// Updating Discord Rich Presence (with Time Left)
			updateRPC(false);
			#end
		}
	}

	private function generateSong(dataPath:String):Void
	{
		// FlxG.log.add(ChartParser.parse());

		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
		songDetails = CoolUtil.dashToSpace(SONG.song) + ' - ' + CoolUtil.difficultyFromNumber(storyDifficulty);

		// String for when the game is paused
		detailsPausedText = "Paused - " + songDetails;

		// set details for song stuffs
		detailsSub = "";

		// Updating Discord Rich Presence.
		updateRPC(false);

		curSong = songData.song;
		songMusic = new FlxSound().loadEmbedded(Sound.fromFile('./' + Paths.inst(SONG.song)), false, true);

		if (SONG.needsVoices)
			vocals = new FlxSound().loadEmbedded(Sound.fromFile('./' + Paths.voices(SONG.song)), false, true);
		else
			vocals = new FlxSound();

		FlxG.sound.list.add(songMusic);
		FlxG.sound.list.add(vocals);

		// generate the chart
		unspawnNotes = ChartLoader.generateChartType(SONG, determinedChartType);
		// sometime my brain farts dont ask me why these functions were separated before

		// sort through them
		unspawnNotes.sort(sortByShit);
		// give the game the heads up to be able to start
		generatedMusic = true;

		Timings.accuracyMaxCalculation(unspawnNotes);
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	function resyncVocals():Void
	{
		vocals.pause();

		songMusic.play();
		Conductor.songPosition = songMusic.time;
		vocals.time = Conductor.songPosition;
		vocals.play();
	}

	override function stepHit()
	{
		super.stepHit();
		///*
		if (songMusic.time > Conductor.songPosition + 20 || songMusic.time < Conductor.songPosition - 20)
		{
			resyncVocals();
		}
		//*/

		if (curSong == 'Pelvic')
		{
			switch (curStep)
			{
				case 252 | 1020:
					// GF and BF cheers
					// SHUBS NOTE: GF is also meant to cheer at different parts of the song but they arent on beat so i dunno how to do that

					// it works for me I think???
					vocals.volume = 1 * volumeMultiplier;
					boyfriend.playAnim('hey', true);
					gf.playAnim('cheer', true);

				case 84 | 87 | 94 | 116 | 119 | 126:
					gf.playAnim('cheer', true);

				case 64:
					// big flashy
					stageBuild.bgSkeletons.animation.play('idle');
					FlxG.camera.zoom = 1.2;
					remove(dadOpponent);
					var yellow:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.YELLOW);
					yellow.scrollFactor.set();
					add(yellow);
					if (Init.trueSettings.get('Photosensitivity Tweaks'))
					{
						yellow.alpha = 0;
					}
					dadOpponent.generateCharacter(100, 100, 'bones-cool');
					dadOpponent.x += 320;
					dadOpponent.y += 220;
					add(dadOpponent);
					// SHUBS NOTE: using the code from the port of lazerz, which means this is gonna break too
					// fixed B)
					// thank you shubs :)
					uiHUD.iconP2.updateIcon('bones-cool');
					dadOpponent.playAnim('singUP');
					if (!Init.trueSettings.get('Photosensitivity Tweaks'))
					{
						FlxTween.tween(yellow, {alpha: 0}, 1, {
							onComplete: function(twn:FlxTween)
							{
								FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 0.5);
							}
						});
					}
				// FlxG.log.add('FLIP');

				case 50 | 54 | 58 | 62:
					// record scratches
					FlxTween.color(dadOpponent, 0.5, FlxColor.BLACK, FlxColor.WHITE);
					// FlxG.log.add('FLOP');
			}
		}
	}

	private function charactersDance(curBeat:Int)
	{
		if ((curBeat % gfSpeed == 0) && (!gf.animation.curAnim.name.startsWith("sing")))
			gf.dance();

		if (!boyfriend.animation.curAnim.name.startsWith("sing"))
			boyfriend.dance();

		// added this for opponent cus it wasn't here before and skater would just freeze
		if ((!dadOpponent.animation.curAnim.name.startsWith("sing"))
			&& (!dadOpponent.animation.curAnim.name.endsWith("death"))
			&& (!dadOpponent.animation.curAnim.name.endsWith("swig"))
			&& (!dadOpponent.animation.curAnim.name.endsWith("puppet"))
			&& (!dadOpponent.animation.curAnim.name.endsWith("rage"))
			&& (!dadOpponent.animation.curAnim.name.endsWith("fuck"))
			&& (!dadOpponent.animation.curAnim.name.endsWith("pain")))
			dadOpponent.dance();
	}

	override function beatHit()
	{
		super.beatHit();

		if ((FlxG.camera.zoom < 1.35 && ((curBeat % 4 == 0) || zoomBeat)) && (!Init.trueSettings.get('Reduced Movements')))
		{
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.05;
		}

		uiHUD.beatHit();

		//
		charactersDance(curBeat);

		// stage stuffs
		stageBuild.stageUpdate(curBeat, boyfriend, gf, dadOpponent);

		if (curSong == 'Probed' && dadOpponent.curCharacter == 'alien' || dadOpponent.curCharacter == 'alien-alt')
		{
			switch (curBeat)
			{
				case(131):
					dadOpponent.playAnim('OUCH', true);
					new FlxTimer().start(0.5, function(tmr:FlxTimer)
					{
						remove(dadOpponent);
						dadOpponent.generateCharacter(100, 100, 'alien-alt');
						dadOpponent.color = 0xa99dc9;
						add(dadOpponent);
						dadOpponent.alpha = 1;
						dadOpponent.x += 160;
						dadOpponent.y += 110;
					});

				case(168):
					remove(dadOpponent);
					dadOpponent.generateCharacter(100, 100, 'alien');
					dadOpponent.color = 0xa99dc9;
					add(dadOpponent);
					dadOpponent.x += 160;
					dadOpponent.y += 110;
					// dadOpponent.playAnim('OUCH', true);
			}
		}

		if (curSong == 'Lazerz' && dadOpponent.curCharacter == 'alien')
		{
			switch (curBeat)
			{
				case(128):
					dadOpponent.playAnim('psychic', true);
					new FlxTimer().start(0.5, function(tmr:FlxTimer)
					{
						remove(dadOpponent);
						dadOpponent.generateCharacter(100, 100, 'alien-pissed');
						uiHUD.iconP2.updateIcon('alien-pissed');
						dadOpponent.color = 0xa99dc9;
						add(dadOpponent);
						dadOpponent.alpha = 1;
						dadOpponent.x += 160;
						dadOpponent.y += 110;
					});
			}
		}

		if (curSong == 'Annihilation-Lol')
		{
			switch (curBeat)
			{
				case 55:
					remove(dadOpponent);
					dadOpponent.color = 0xFFFFFF;
					remove(boyfriend);
					var black:FlxSprite = new FlxSprite(-250, -200).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
					black.scrollFactor.set();
					add(black);
					add(dadOpponent);
					isCutscene = true;
					camHUD.visible = false;
					dadOpponent.playAnim('xigdeath', true);
			}
		}

		if (curSong == 'Extermination' && dadOpponent.curCharacter == 'alien-rude' || dadOpponent.curCharacter == 'alien-ouch')
		{
			switch (curBeat)
			{
				case 31:
					boyfriend.playAnim('hey', true);
				case 158:
					dadOpponent.playAnim('pain', true);
				case 159:
					dadOpponent.playAnim('fuck', true);
				case 320:
					remove(dadOpponent);
					dadOpponent.generateCharacter(100, 100, 'alien-ouch');
					dadOpponent.x += 80;
					dadOpponent.y += 100;
					add(dadOpponent);
			}
		}

		if ((curSong == 'Craniotomy') && (!Init.trueSettings.get('Photosensitivity Tweaks')))
		{
			switch (curBeat)
			{
				case 94:
					// fade to black
					stageBuild.black.alpha = 0;
					FlxTween.tween(stageBuild.black, {alpha: 1}, 0.5);

					FlxTween.tween(gf, {alpha: 0}, 0.5);
					FlxTween.tween(boyfriend, {alpha: 0}, 0.5);
					FlxTween.tween(dadOpponent, {alpha: 0}, 0.5);
				case 96:
					// xigmund fade in
					dadOpponent.color = 0xFF0000;
					FlxTween.tween(dadOpponent, {alpha: 1}, 0.5);
					// hardcoded zooms every beat like in milf
					zoomBeat = true;
				case 104:
					// bf fade in
					boyfriend.color = 0x0000FF;
					FlxTween.tween(boyfriend, {alpha: 1}, 0.5);
				case 128:
					// hardcoded zooms stop
					zoomBeat = false;
				case 190:
					// bf and xigmund fade back to black
					FlxTween.tween(boyfriend, {alpha: 0}, 0.5);
					FlxTween.tween(dadOpponent, {alpha: 0}, 0.5);
				case 192:
					// fade back in to normal stuff
					FlxTween.tween(stageBuild.black, {alpha: 0}, 0.5);

					boyfriend.color = 0xa99dc9;
					dadOpponent.color = 0xa99dc9;
					FlxTween.tween(gf, {alpha: 1}, 0.5);
					FlxTween.tween(boyfriend, {alpha: 1}, 0.5);
					FlxTween.tween(dadOpponent, {alpha: 1}, 0.5);
				case 254:
					// fade back to black again, xigmund and bf red and blue automatically
					stageBuild.black.alpha = 0;
					FlxTween.tween(stageBuild.black, {alpha: 1}, 0.5);

					FlxTween.tween(gf, {alpha: 0}, 0.5);
					FlxTween.tween(boyfriend, {alpha: 0}, 0.5);
					FlxTween.tween(dadOpponent, {alpha: 0}, 0.5);
				case 256:
					// xig and bf fade in
					dadOpponent.color = 0xFF0000;
					FlxTween.tween(dadOpponent, {alpha: 1}, 0.5);
					boyfriend.color = 0x0000FF;
					FlxTween.tween(boyfriend, {alpha: 1}, 0.5);
				case 286:
					// xig and bf back to black
					FlxTween.tween(boyfriend, {alpha: 0}, 0.5);
					FlxTween.tween(dadOpponent, {alpha: 0}, 0.5);
				case 288:
					// back to normal again
					FlxTween.tween(stageBuild.black, {alpha: 0}, 0.5);

					boyfriend.color = 0xa99dc9;
					dadOpponent.color = 0xa99dc9;
					FlxTween.tween(gf, {alpha: 1}, 0.5);
					FlxTween.tween(boyfriend, {alpha: 1}, 0.5);
					FlxTween.tween(dadOpponent, {alpha: 1}, 0.5);
			}
		}

		if (curSong == 'Aneurysmia')
		{
			switch (curBeat)
			{
				case 128:
					dadOpponent.playAnim('death');
			}
		}

		if (curSong == 'Crack')
		{
			if (mutingTime > 0)
			{
				if ((curBeat % 1) == 0)
				{
					FlxG.sound.changeVolume(-0.1);
				}
			}

			if ((curBeat % 32) == 0)
			{
				switch (FlxG.random.int(0, 3))
				{
					case 0:
						mutingTime = 5.0;
					case 1:
						if (!Init.trueSettings.get('Photosensitivity Tweaks'))
						{
							uiHUD.noiseTime = 8.0;
						}
						else
						{
							repositionTime = 8.0;
							hudPositionX = FlxG.random.int(-300, 300);
							hudPositionY = FlxG.random.int(-300, 300);
						}
					case 2:
						repositionTime = 8.0;
						hudPositionX = FlxG.random.int(-300, 300);
						hudPositionY = FlxG.random.int(-300, 300);
				}
			}
		}

		if (curSong == 'Marrow')
		{
			// again i apologize to programmers everywhere
			// i could easily reprogram this to use GF animation code. but i dont WAAAAAAANT to
			switch (curBeat)
			{
				case 8 | 12 | 20:
					stageBuild.raveyard_belltower.animation.play('ringLEFT');
				// FlxG.log.add('DONG');

				case 10 | 16 | 22:
					stageBuild.raveyard_belltower.animation.play('ringRIGHT');
					if (curBeat == 16)
						isStationaryCam = false;

				case 24:
					FlxTween.color(dadOpponent, 0.5, FlxColor.BLACK, FlxColor.WHITE);
					FlxTween.color(uiHUD.iconP2, 0.5, FlxColor.BLACK, FlxColor.WHITE);
			}
		}

		if (curSong == 'Pelvic')
		{
			if (curBeat % 2 == 0 && curBeat >= 64)
			{
				stageBuild.danced = !stageBuild.danced;

				if (stageBuild.danced)
					stageBuild.bgSkeletons.animation.play('danceRIGHT');
				else
					stageBuild.bgSkeletons.animation.play('danceLEFT');
			}
		}

		if (curSong == 'Spinal Tap')
		{
			if (curBeat % 2 == 0)
			{
				stageBuild.bgSkeletons.animation.play('fear');
			}

			switch (curBeat)
			{
				case 236:
					add(stageBuild.spinaltapbeam);
					stageBuild.spinaltapbeam.x = dadOpponent.x - 100;
					stageBuild.spinaltapbeam.y = dadOpponent.y - 1100;
					remove(dadOpponent);
					stageBuild.spinaltapbeam.animation.play('idle');
			}
		}

		if (curSong == 'Exclusion Zone' && (dadOpponent.curCharacter == 'harold' || dadOpponent.curCharacter == 'harold-caffeinated'))
		{
			switch (curStep)
			{
				case 376:
					dadOpponent.playAnim("short swig");
					new FlxTimer().start(0.8, function(tmr:FlxTimer)
					{
						remove(dadOpponent);
						dadOpponent.generateCharacter(100, 100, 'harold-caffeinated');
						dadOpponent.x += 200;
						dadOpponent.y += 150;
						add(dadOpponent);
						uiHUD.iconP2.updateIcon('harold-caffeinated');
					});

				case 896:
					dadOpponent.playAnim("swig");
			}
		}

		if (curSong == 'Egomania'
			&& !hasEgomaniad
			&& (dadOpponent.curCharacter == 'hagomizer' || dadOpponent.curCharacter == 'hagomizer-puppet'))
		{
			if ((((curBeat % 24) == 0) && (curBeat > 25) && (curBeat != 96)) && !distractionVisible)
			{
				spawnDistraction();
			}

			switch (curBeat)
			{
				case 14:
					spawnDistraction('/hardcoded/start');
				case 31:
					dadOpponent.playAnim("cough");
				case 96:
					egomaniaRandom = true;
					spawnDistraction('/hardcoded/random');
					stageBuild.face.alpha = 0;
					stageBuild.face2.alpha = 1;
				case 157:
					dadOpponent.playAnim("puppet");
				case 160:
					remove(dadOpponent);
					dadOpponent.generateCharacter(100, 100, 'hagomizer-puppet');
					dadOpponent.x -= 16;
					dadOpponent.y -= 9;
					add(dadOpponent);

					spawnDistraction('/hardcoded/puppet');
				case 192:
					remove(dadOpponent);
					dadOpponent.generateCharacter(100, 100, 'hagomizer');
					dadOpponent.x -= 16;
					dadOpponent.y -= 9;
					add(dadOpponent);

					stageBuild.face.alpha = 1;
					stageBuild.face2.alpha = 0;
			}
		}

		// egomania part 2
		if (curSong == 'Egomania' && hasEgomaniad)
		{
			// bad code lol im so lazy. doesnt work. pls fix
			// if (((curBeat == 0) || (curBeat == 1)) && (dadOpponent.curCharacter == 'hagomizer-rage'))
			// {
			// 	dadOpponent.playAnim('rage');
			// }
			if (((curBeat % 16) == 0) && !distractionVisible && (curBeat < 135))
			{
				spawnDistraction();
			}
		}

		if (curStage == 'lab' || curStage == 'breakout')
		{
			if (curBeat % 2 == 0)
			{
				stageBuild.fbiSpin1.animation.play("idle");
				stageBuild.fbiSpin2.animation.play("idle");
				stageBuild.fbiScreen.animation.play("idle");
			}
		}

		if (curStage == 'breakout')
		{
			if (curBeat == 128 && FlxG.random.bool(25))
			{
				xigchadMoves = true;
			}

			switch (curBeat)
			{
				case 147 | 187 | 311:
					gf.playAnim('cheer');
			}
		}

		if (curStage == 'fbi')
		{
			if (curSong != 'Enforcement')
			{
				if (curBeat % 2 == 0)
				{
					stageBuild.tank.animation.play("idle");
					if (curSong == 'Confidential')
					{
						stageBuild.bodyguardbopper.animation.play("idle");
						stageBuild.hackerbopper.animation.play("idle");
					}
					else if (curSong == 'Aegis')
					{
						stageBuild.gruntbopper.animation.play("idle");
						stageBuild.hackerbopper.animation.play("idle");
					}
					else if (curSong == 'Crack')
					{
						stageBuild.bodyguardbopper.animation.play("idle");
						stageBuild.gruntbopper.animation.play("idle");
					}
				}
			}
		}

		if (curStage == 'sky')
			showBeatGlow = ((curBeat % 4) == 0 || (curBeat % 4) == 1);
	}

	//
	//
	/// substate stuffs
	//
	//

	public static function resetMusic()
	{
		// simply stated, resets the playstate's music for other states and substates
		if (songMusic != null)
			songMusic.stop();

		if (vocals != null)
			vocals.stop();

		if (uiHUD != null)
			uiHUD.staticSound.stop();
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			// trace('null song');
			if (songMusic != null)
			{
				//	trace('nulled song');
				songMusic.pause();
				vocals.pause();
				uiHUD.staticSound.pause();
				//	trace('nulled song finished');
			}

			// trace('ui shit break');
			if ((startTimer != null) && (!startTimer.finished))
				startTimer.active = false;
		}

		// trace('open substate');
		super.openSubState(SubState);
		// trace('open substate end ');
	}

	override function closeSubState()
	{
		if (paused)
		{
			if (songMusic != null && !startingSong)
				resyncVocals();
			uiHUD.staticSound.play();

			if ((startTimer != null) && (!startTimer.finished))
				startTimer.active = true;
			paused = false;

			///*
			updateRPC(false);
			// */
		}

		super.closeSubState();
	}

	/*
		Extra functions and stuffs
	 */
	/// song end function at the end of the playstate lmao ironic I guess
	private var endSongEvent:Bool = false;

	function endSong():Void
	{
		mutingTime = 0;
		repositionTime = 0;

		if (uiHUD.noiseTime > 0.5)
			uiHUD.noiseTime = 0.5;

		canPause = false;
		songMusic.volume = 0;
		vocals.volume = 0;
		if (SONG.validScore)
			Highscore.saveScore(SONG.song, songScore, storyDifficulty);

		if (!isStoryMode)
			songEndSpecificActions();
		else
		{
			// set the campaign's score higher
			campaignScore += songScore;

			// remove a song from the story playlist
			storyPlaylist.remove(storyPlaylist[0]);

			// check if there aren't any songs left
			if ((storyPlaylist.length <= 0) && (!endSongEvent))
			{
				// play menu music
				ForeverTools.resetMenuMusic();

				// set up transitions
				transIn = FlxTransitionableState.defaultTransIn;
				transOut = FlxTransitionableState.defaultTransOut;

				// change to the menu state
				Main.switchState(this, new StoryMenuState());

				// save the week's score if the score is valid
				if (SONG.validScore)
					Highscore.saveWeekScore(storyWeek, campaignScore, storyDifficulty);

				// flush the save
				FlxG.save.flush();
			}
			else
				songEndSpecificActions();
		}
		//
	}

	var hasEgomaniad:Bool = false;

	private function songEndSpecificActions()
	{
		switch (SONG.song.toLowerCase())
		{
			case 'egomania':
				if (!hasEgomaniad)
				{
					egomaniaExclusions = [];
					callTextbox(Paths.json('egomania/dialogue2'), true);
				}
				else
					callDefaultSongEnd();
			case 'crack':
				if (!isStoryMode)
				{
					callDefaultSongEnd();
				}
				else
				{
					var black:FlxSprite = new FlxSprite(-FlxG.width / 2, -FlxG.height / 2).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
					black.scrollFactor.set();
					black.alpha = 0;
					add(black);

					camHUD.visible = false;
					stageBuild.bodyguardbopper.animation.play("woh");
					stageBuild.gruntbopper.animation.play("woh");
					dadOpponent.animation.play("woh");
	
					var gfX = gf.x;
					var gfY = gf.y;
					remove(gf);
					gf.generateCharacter(gfX, gfY, 'gf-hominid');
					gf.y -= 253;
					add(gf);
	
					gf.animation.play('land');

					new FlxTimer().start(2, function(tmr:FlxTimer)
					{
						FlxTween.tween(black, {alpha: 1}, 0.5, {
							onComplete: function(twn:FlxTween)
							{
								callDefaultSongEnd();
							}
						});
					});
				}
			case 'freak':
				if (!isStoryMode)
				{
					callDefaultSongEnd();
				}
				else
				{
					var red:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.RED);
					red.scrollFactor.set();
					red.alpha = 0;
					add(red);

					// xigkill.addOffset("shake", -39, -718);
					// xigkill.addOffset("kill", 754, -545);

					isCutscene = true;
					camFollow.setPosition(gf.getMidpoint().x + 250, gf.getMidpoint().y - 50);
					camHUD.visible = false;

					new FlxTimer().start(1.5, function(tmr:FlxTimer)
					{
						FlxG.sound.play(Paths.sound('fwoosh'), 1.5, false, null, true);

						xigkill.visible = true;
						xigkill.animation.play("entrance");
						new FlxTimer().start(0.4, function(tmr:FlxTimer)
						{
							xigkill.x += 39;
							xigkill.y += 718;
							xigkill.animation.play("shake");
							new FlxTimer().start(1.5, function(tmr:FlxTimer)
							{
								xigkill.x -= 39;
								xigkill.y -= 718;

								xigkill.x -= 780;
								xigkill.y += 545;
								xigkill.animation.play("kill");

								FlxG.sound.play(Paths.sound('xigman_scream'), 1.5, false, null, true);
								new FlxTimer().start(0.2, function(tmr:FlxTimer)
								{
									FlxG.sound.play(Paths.sound('fbihit'), 1.5, false, null, true);
									FlxTween.tween(red, {alpha: 1}, 0.125, {
										onComplete: function(twn:FlxTween)
										{
											new FlxTimer().start(0.2, function(tmr:FlxTimer)
											{
												FlxG.sound.play(Paths.sound('fbipwned'), 1.5, false, null, true);

												new FlxTimer().start(2, function(tmr:FlxTimer)
												{
													callDefaultSongEnd();
												});
											});
										}
									});
								});
							});
						});
					});
				}
			default:
				callDefaultSongEnd();
		}
	}

	private function callDefaultSongEnd()
	{
		uiHUD.staticSound.stop();
		volumeMultiplier = 1;
		vocals.volume = 1;
		if (isStoryMode)
		{
			var difficulty:String = '-' + CoolUtil.difficultyFromNumber(storyDifficulty).toLowerCase();
			difficulty = difficulty.replace('-normal', '');

			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;

			PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + difficulty, PlayState.storyPlaylist[0]);
			ForeverTools.killMusic([songMusic, vocals]);

			// deliberately did not use the main.switchstate as to not unload the assets
			FlxG.switchState(new PlayState());
		}
		else
		{
			Main.switchState(this, new FreeplayState());
		}
	}

	var dialogueBox:DialogueBox;
	var distractionVisible = false;

	public function songIntroCutscene()
	{
		switch (curSong.toLowerCase())
		{
			case 'probed' | 'rude':
				remove(dadOpponent);
				remove(gf);

				defaultCamZoom = 4;
				FlxG.camera.zoom = defaultCamZoom;
				forceZoom[0] = -3.1;

				var xigIntro:FlxSprite = new FlxSprite(100, -100);
				var cutsceneUfo:FlxSprite = new FlxSprite(100, -100);
				if (curSong == 'Probed')
				{
					xigIntro.frames = Paths.getSparrowAtlas('cutscenes/opening');
				}
				else
				{
					xigIntro.frames = Paths.getSparrowAtlas('cutscenes/opening alt');
				}
				xigIntro.antialiasing = true;
				cutsceneUfo.frames = Paths.getSparrowAtlas('cutscenes/UFOempty');
				cutsceneUfo.antialiasing = true;
				if (curSong == 'Probed')
				{
					xigIntro.animation.addByPrefix('idle', 'repairing', 24, false);
				}
				else
				{
					xigIntro.animation.addByPrefix('idle', 'xigmund cscene1', 24, false);
				}
				cutsceneUfo.animation.addByPrefix('idle', 'Symbol 2 instance ', 24, false);
				add(cutsceneUfo);
				add(xigIntro);
				xigIntro.y += 300;
				xigIntro.x += 100;
				cutsceneUfo.y += 90;
				boyfriend.x += 250;

				boyfriend.dance();

				boyfriend.color = 0xa99dc9;
				xigIntro.color = 0xa99dc9;

				var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
				black.scrollFactor.set();
				add(black);

				camFollow.x = (dadOpponent.getMidpoint().x + 150);

				isCutscene = true;
				camHUD.visible = false;

				FlxG.sound.play(Paths.sound('xigmund_intro'), 1, false, null, true);

				FlxTween.tween(black, {alpha: 0}, 2.5, {
					onComplete: function(twn:FlxTween)
					{
						xigIntro.animation.play('idle');
						new FlxTimer().start(3, function(swagTimer:FlxTimer)
						{
							camFollow.x += 300;
						});
						new FlxTimer().start(6, function(swagTimer:FlxTimer)
						{
							boyfriend.animation.play('singLEFT');
						});
						new FlxTimer().start(10, function(swagTimer:FlxTimer)
						{
							FlxTween.tween(black, {alpha: 1}, 0.2, {
								onComplete: function(twn:FlxTween)
								{
									remove(xigIntro);
									remove(cutsceneUfo);
									add(gf);
									add(dadOpponent);
									boyfriend.x -= 250;
									boyfriend.animation.play('idle');
									FlxTween.tween(black, {alpha: 0}, 0.2, {
										onComplete: function(twn:FlxTween)
										{
											isCutscene = false;
											camHUD.visible = true;
											// FlxG.camera.zoom = defaultCamZoom;
											startCountdown();
										}
									});
								}
							});
						});
					}
				});
			case 'annihilation-lol' | 'aneurysmia':
				var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
				black.scrollFactor.set();
				add(black);
				remove(dadOpponent);
				if (curSong.toLowerCase() == 'annihilation-lol')
				{
					dadOpponent.generateCharacter(100, 100, 'alien-pissed');
				}
				else
				{
					dadOpponent.generateCharacter(100, 100, 'alien-ouch');
				}
				add(dadOpponent);
				dadOpponent.color = 0xa99dc9;
				dadOpponent.x += 160;
				dadOpponent.y += 110;
				camFollow.x = (dadOpponent.getMidpoint().x + 150);

				isCutscene = true;
				camHUD.visible = false;

				FlxTween.tween(black, {alpha: 0}, 1, {
					onComplete: function(twn:FlxTween)
					{
						FlxG.sound.play(Paths.sound('xigcharge'), 1, false, null, true);
						dadOpponent.playAnim('charging');
						new FlxTimer().start(3, function(swagTimer:FlxTimer)
						{
							var red:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.RED);
							red.scrollFactor.set();
							red.alpha = 0;
							add(red);
							new FlxTimer().start(0.5, function(swagTimer:FlxTimer)
							{
								FlxTween.tween(red, {alpha: 1}, 0.2, {
									onComplete: function(twn:FlxTween)
									{
										remove(dadOpponent);
										if (curSong.toLowerCase() == 'annihilation-lol')
										{
											dadOpponent.generateCharacter(100, 100, 'alien-psychic');
										}
										else
										{
											dadOpponent.generateCharacter(100, 100, 'alien-power');
										}
										add(dadOpponent);
										dadOpponent.color = 0xa99dc9;
										new FlxTimer().start(1, function(swagTimer:FlxTimer)
										{
											FlxTween.tween(red, {alpha: 0}, 0.2, {
												onComplete: function(twn:FlxTween)
												{
													isCutscene = false;
													camHUD.visible = true;
													FlxG.camera.zoom = defaultCamZoom;
													startCountdown();
												}
											});
										});
									}
								});
							});
						});
					}
				});
			case 'marrow':
				remove(dadOpponent);
				remove(gf);
				remove(boyfriend);

				var bonesIntro:FlxSprite = new FlxSprite(100, -100);
				var cutsceneGrave:FlxSprite = new FlxSprite(100, -100);
				bonesIntro.frames = Paths.getSparrowAtlas('cutscenes/w2/bonesrise');
				cutsceneGrave.frames = Paths.getSparrowAtlas('cutscenes/w2/grave');
				bonesIntro.animation.addByPrefix('idle', 'xigcutscene', 24, false);
				cutsceneGrave.animation.addByPrefix('idle', 'Symbol 1 instance ', 24, false);
				add(cutsceneGrave);
				cutsceneGrave.x += 500;
				cutsceneGrave.y += 600;

				var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
				black.scrollFactor.set();
				add(black);

				camFollow.x = 800;
				camFollow.y = 600;

				isCutscene = true;
				camHUD.visible = false;

				FlxTween.tween(black, {alpha: 0}, 2.5, {
					onComplete: function(twn:FlxTween)
					{
						FlxG.sound.play(Paths.sound('bones_rise'), 1, false, null, true);
						new FlxTimer().start(5, function(swagTimer:FlxTimer)
						{
							camFollow.y += 50;
							add(bonesIntro);
							bonesIntro.x += 600;
							bonesIntro.y += 900;
							bonesIntro.animation.play('idle');
						});

						new FlxTimer().start(14, function(swagTimer:FlxTimer)
						{
							FlxTween.tween(black, {alpha: 1}, 0.2, {
								onComplete: function(twn:FlxTween)
								{
									remove(bonesIntro);
									remove(cutsceneGrave);
									add(gf);
									add(dadOpponent);
									add(boyfriend);

									camFollow.setPosition(dadOpponent.getMidpoint().x + 350, -300);

									FlxTween.tween(black, {alpha: 0}, 0.2, {
										onComplete: function(twn:FlxTween)
										{
											camHUD.visible = true;
											FlxG.camera.zoom = defaultCamZoom;
											FlxTween.tween(dadOpponent, {color: 0x000000}, 0.1);
											FlxG.camera.focusOn(camFollow.getPosition());
											FlxG.camera.zoom = 1.5;
											FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 2.5, {
												ease: FlxEase.quadInOut,
												onComplete: function(twn:FlxTween)
												{
													isCutscene = false;
													startCountdown();
												}
											});
										}
									});
								}
							});
						});
					}
				});
			case 'pelvic':
				uiHUD.iconP2.updateIcon('bones');
				remove(dadOpponent);
				dadOpponent.generateCharacter(100, 100, 'bones');
				add(dadOpponent);
				dadOpponent.x += 320;
				dadOpponent.y += 260;
				FlxTween.tween(dadOpponent, {color: 0x000000}, 0.1);
				startCountdown();
			case 'spinal tap':
				remove(dadOpponent);

				var bonesFuck:FlxSprite = new FlxSprite(100, -100);
				bonesFuck.frames = Paths.getSparrowAtlas('cutscenes/w2/spinaltap-intro-xig');
				bonesFuck.animation.addByPrefix('idle', 'cutscene spinal tap FULL', 24, false);
				add(bonesFuck);
				bonesFuck.x += 100;
				bonesFuck.y += 200;

				var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
				black.scrollFactor.set();
				add(black);

				camFollow.x = (dadOpponent.getMidpoint().x + 150);
				camFollow.y += 20;

				stageBuild.bgSkeletons.animation.play('idle');

				isCutscene = true;
				camHUD.visible = false;

				FlxTween.tween(black, {alpha: 0}, 2.5, {
					onComplete: function(twn:FlxTween)
					{
						bonesFuck.animation.play('idle');
						FlxG.sound.play(Paths.sound('bones_bonk'), 1, false, null, true);
						new FlxTimer().start(0.7, function(swagTimer:FlxTimer)
						{
							stageBuild.bgSkeletons.animation.play("fear cutscene");
						});
						new FlxTimer().start(9, function(swagTimer:FlxTimer)
						{
							FlxTween.tween(black, {alpha: 1}, 0.2, {
								onComplete: function(twn:FlxTween)
								{
									remove(bonesFuck);
									add(dadOpponent);

									FlxTween.tween(black, {alpha: 0}, 0.2, {
										onComplete: function(twn:FlxTween)
										{
											isCutscene = false;
											startCountdown();
											camHUD.visible = true;
											FlxG.camera.zoom = defaultCamZoom;
										}
									});
								}
							});
						});
					}
				});
			case 'jitter':
				var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
				black.scrollFactor.set();
				add(black);
				remove(dadOpponent);
				dadOpponent.generateCharacter(100, 100, 'harold');
				add(dadOpponent);
				dadOpponent.x += 200;
				dadOpponent.y += 150;
				camFollow.x = (dadOpponent.getMidpoint().x + 150);

				isCutscene = true;
				camHUD.visible = false;

				FlxTween.tween(black, {alpha: 0}, 1, {
					onComplete: function(twn:FlxTween)
					{
						FlxG.sound.play(Paths.sound('drinka_boy'), 1, false, null, true);
						dadOpponent.playAnim('swig');
						new FlxTimer().start(4, function(swagTimer:FlxTimer)
						{
							FlxTween.tween(black, {alpha: 1}, 0.2, {
								onComplete: function(twn:FlxTween)
								{
									remove(dadOpponent);
									dadOpponent.generateCharacter(100, 100, 'harold-caffeinated');
									add(dadOpponent);
									dadOpponent.x += 200;
									dadOpponent.y += 150;
									dadOpponent.playAnim('idle');
									FlxTween.tween(black, {alpha: 0}, 0.2, {
										onComplete: function(twn:FlxTween)
										{
											isCutscene = false;
											camHUD.visible = true;
											FlxG.camera.zoom = defaultCamZoom;
											startCountdown();
										}
									});
								}
							});
						});
					}
				});
			case 'boing':
				var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
				black.scrollFactor.set();
				add(black);
				dadOpponent.visible = false;
				// boyfriend.visible = false;
				gf.visible = false;
				stageBuild.gtubes.visible = false;
				stageBuild.ctubes.visible = true;
				stageBuild.xigtube.visible = true;

				isCutscene = true;
				isStationaryCam = true;
				camHUD.visible = false;

				FlxG.sound.play(Paths.sound('xigman_jingle'), 1.5, false, null, true);

				FlxTween.tween(black, {alpha: 0}, 1, {
					onComplete: function(twn:FlxTween)
					{
						new FlxTimer().start(1.5, function(tmr:FlxTimer)
						{
							stageBuild.xigtube.animation.play("rise");
							new FlxTimer().start(2.184, function(tmr:FlxTimer)
							{
								FlxG.sound.play(Paths.sound('glass_break'), 1.5, false, null, true);
								stageBuild.xigtube.animation.play("out");
								new FlxTimer().start(2, function(tmr:FlxTimer)
								{
									FlxTween.tween(black, {alpha: 1}, 1, {
										onComplete: function(twn:FlxTween)
										{
											new FlxTimer().start(2, function(tmr:FlxTimer)
											{
												dadOpponent.visible = true;
												gf.visible = true;
												stageBuild.gtubes.visible = true;
												stageBuild.ctubes.visible = false;
												stageBuild.xigtube.visible = false;
												camHUD.visible = true;

												isCutscene = false;
												isStationaryCam = false;

												startCountdown();

												FlxTween.tween(black, {alpha: 0}, 0.5, {
													onComplete: function(twn:FlxTween)
													{
														remove(black);
													}
												});
											});
										}
									});
								});
							});
						});
					}
				});
			case 'breakout':
				var red:FlxSprite = new FlxSprite(-FlxG.width, -FlxG.height).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.RED);
				red.scrollFactor.set();
				red.alpha = 1;
				add(red);

				FlxTween.tween(red, {alpha: 0}, 0.5);
			default:
				callTextbox();
		}
		//
	}

	function callTextbox(dialogPath:String = "", ?egomaniaEnd:Bool = false)
	{
		if (dialogPath == "")
		{
			dialogPath = Paths.json(SONG.song.toLowerCase() + '/dialogue');
		}

		if (sys.FileSystem.exists(dialogPath))
		{
			if (dialogueBox != null)
				dialogueBox.destroy();

			isCutscene = true;
			startedCountdown = false;

			dialogueBox = DialogueBox.createDialogue(sys.io.File.getContent(dialogPath));
			dialogueBox.cameras = [dialogueHUD];
			if (egomaniaEnd)
				dialogueBox.whenDaFinish = egomania2;

			add(dialogueBox);
		}
		else
			startCountdown();
	}

	function egomania2()
	{
		hasEgomaniad = true;
		SONG = Song.loadFromJson('egomania-2', 'egomania');
		dadOpponent.generateCharacter(dadOpponent.x, dadOpponent.y, SONG.player2);
		dadOpponent.animation.play("rage");
		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);
		// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
		songDetails = 'Egomania!!?? - ' + CoolUtil.difficultyFromNumber(storyDifficulty);
		detailsPausedText = "Paused - " + songDetails;
		detailsSub = "";
		//
		Conductor.songPosition = -(Conductor.crochet * 5);
		songMusic = egoSongPushed;
		vocals = egoVocalsPushed;
		FlxG.sound.list.add(songMusic);
		FlxG.sound.list.add(vocals);
		unspawnNotes = secondUnspawn;
		//
		canPause = true;
		startSong();
	};

	var egomaniaExclusions:Array<Int> = [8];

	function spawnDistraction(path:String = "", isTop:Bool = false)
	{
		volumeMultiplier = 0.25;
		songMusic.volume = 1 * volumeMultiplier;
		vocals.volume = 1 * volumeMultiplier;

		if (path == "")
		{
			var egoInteger:Int = FlxG.random.int(0, 14, egomaniaExclusions);
			var suffix:String = '';
			if (hasEgomaniad)
				suffix = '-2';
			egoInteger = FlxG.random.int(0, 7, egomaniaExclusions);
			path = ('/distractions' + suffix + '/' + egoInteger);
			egomaniaExclusions.push(egoInteger);
		}

		dialogueBox.destroy();

		var pressKey:String = "SPACE";

		if (egomaniaRandom)
		{
			pressKey = String.fromCharCode(FlxG.random.int(65, 90, [65, 68, 70, 74, 75, 87, 83] // WASD and DFJK
			));
		}

		if (hasEgomaniad)
			isTop = FlxG.random.bool(50);
		if (Init.trueSettings.get('Downscroll'))
			isTop = !isTop;

		var dialogPath = Paths.json(SONG.song.toLowerCase() + path);
		dialogueBox = DialogueBox.createDialogue(sys.io.File.getContent(dialogPath), pressKey, isTop);
		dialogueBox.cameras = [dialogueHUD];

		distractionVisible = true;
		add(dialogueBox);
	}

	public static var swagCounter:Int = 0;

	private function startCountdown():Void
	{
		Conductor.songPosition = -(Conductor.crochet * 5);
		swagCounter = 0;

		startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{
			charactersDance(curBeat);

			var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
			introAssets.set('default', [
				ForeverTools.returnSkinAsset('ready', assetModifier, changeableSkin, 'UI'),
				ForeverTools.returnSkinAsset('set', assetModifier, changeableSkin, 'UI'),
				ForeverTools.returnSkinAsset('go', assetModifier, changeableSkin, 'UI')
			]);

			var introAlts:Array<String> = introAssets.get('default');
			for (value in introAssets.keys())
			{
				if (value == PlayState.curStage)
					introAlts = introAssets.get(value);
			}

			switch (swagCounter)
			{
				case 0:
					FlxG.sound.play(Paths.sound('intro3-' + assetModifier), 0.6);
					Conductor.songPosition = -(Conductor.crochet * 4);
				case 1:
					var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[0]));
					ready.scrollFactor.set();
					ready.updateHitbox();

					if (assetModifier == 'pixel')
						ready.setGraphicSize(Std.int(ready.width * PlayState.daPixelZoom));

					ready.screenCenter();
					add(ready);
					FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							ready.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('intro2-' + assetModifier), 0.6);

					Conductor.songPosition = -(Conductor.crochet * 3);
				case 2:
					var set:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[1]));
					set.scrollFactor.set();

					if (assetModifier == 'pixel')
						set.setGraphicSize(Std.int(set.width * PlayState.daPixelZoom));

					set.screenCenter();
					add(set);
					FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							set.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('intro1-' + assetModifier), 0.6);

					Conductor.songPosition = -(Conductor.crochet * 2);
				case 3:
					var go:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[2]));
					go.scrollFactor.set();

					if (assetModifier == 'pixel')
						go.setGraphicSize(Std.int(go.width * PlayState.daPixelZoom));

					go.updateHitbox();

					go.screenCenter();
					add(go);
					FlxTween.tween(go, {y: go.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							go.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('introGo-' + assetModifier), 0.6);

					Conductor.songPosition = -(Conductor.crochet * 1);
			}

			swagCounter += 1;
			// generateSong('fresh');
		}, 5);
	}

	override function add(Object:FlxBasic):FlxBasic
	{
		Main.loadedAssets.insert(Main.loadedAssets.length, Object);
		return super.add(Object);
	}
}
