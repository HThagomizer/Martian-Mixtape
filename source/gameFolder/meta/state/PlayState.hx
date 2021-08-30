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
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxTimer;
import gameFolder.gameObjects.*;
import gameFolder.gameObjects.userInterface.*;
import gameFolder.meta.*;
import gameFolder.meta.MusicBeat.MusicBeatState;
import gameFolder.meta.data.*;
import gameFolder.meta.data.Song.SwagSong;
import gameFolder.meta.state.charting.*;
import gameFolder.meta.state.menus.*;
import gameFolder.meta.subState.*;
import openfl.utils.Assets;

using StringTools;

class PlayState extends MusicBeatState
{
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

	public var boyfriendAutoplay:Bool = false;

	private var dadAutoplay:Bool = true; // this is for testing purposes

	public static var assetModifier:String = 'base';
	public static var changeableSkin:String = 'default';

	private var notes:FlxTypedGroup<Note>;
	private var unspawnNotes:Array<Note> = [];
	private var ratingArray:Array<String> = [];
	private var allSicks:Bool = true;

	// control arrays I'll use later
	var holdControls:Array<Bool> = [];
	var pressControls:Array<Bool> = [];
	var releaseControls:Array<Bool> = []; // haha garcello!

	// get it cus release
	// I'm funny just trust me
	private var curSection:Int = 0;
	private var camFollow:FlxObject;

	//
	private static var prevCamFollow:FlxObject;

	// strums
	private var strumLine:FlxTypedGroup<FlxSprite>;

	public static var strumLineNotes:FlxTypedGroup<UIStaticArrow>;

	private var boyfriendStrums:FlxTypedGroup<UIStaticArrow>;
	private var dadStrums:FlxTypedGroup<UIStaticArrow>;

	private var curSong:String = "";
	private var splashNotes:FlxTypedGroup<NoteSplash>;

	private var gfSpeed:Int = 1;

	public static var health:Float = 1; // mario
	public static var combo:Int = 0;
	public static var misses:Int = 0;

	private var generatedMusic:Bool = false;
	private var startingSong:Bool = false;
	private var paused:Bool = false;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;

	public static var camHUD:FlxCamera;
	public static var camGame:FlxCamera;

	private var camDisplaceX:Float = 0;
	private var camDisplaceY:Float = 0; // might not use depending on result

	public static var defaultCamZoom:Float = 1.05;

	public static var forceZoom:Array<Float>;

	public static var songScore:Int = 0;

	var storyDifficultyText:String = "";
	var iconRPC:String = "";
	var songLength:Float = 0;

	private var stageBuild:Stage;
	private var uiHUD:ClassHUD;

	public static var daPixelZoom:Float = 6;
	public static var determinedChartType:String = "";

	private var ratingsGroup:FlxTypedGroup<FlxSprite>;
	private var timingsGroup:FlxTypedGroup<FlxSprite>;
	private var scoreGroup:FlxTypedGroup<FlxSprite>;

	private var isCutscene:Bool = false;

	// at the beginning of the playstate
	override public function create()
	{
		// reset any values and variables that are static
		songScore = 0;
		combo = 0;
		health = 1;
		misses = 0;

		defaultCamZoom = 1.05;
		forceZoom = [0, 0, 0, 0];

		assetModifier = 'base';
		changeableSkin = 'default';

		Timings.callAccuracy();

		// initialise the groups!
		ratingsGroup = new FlxTypedGroup<FlxSprite>();
		timingsGroup = new FlxTypedGroup<FlxSprite>();
		scoreGroup = new FlxTypedGroup<FlxSprite>();

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

		stageBuild = new Stage(curStage);
		add(stageBuild);

		/*
			Everything related to the stages aside from things done after are set in the stage class!
			this means that the girlfriend's type, boyfriend's position, dad's position, are all there

			It serves to clear clutter and can easily be destroyed later. The problem is,
			I don't actually know if this is optimised, I just kinda roll with things and hope
			they work. I'm not actually really experienced compared to a lot of other developers in the scene, 
			so I don't really know what I'm doing, I'm just hoping I can make a better and more optimised 
			engine for both myself and other modders to use!
		 */

		// preloading for martian mixtape special character anims

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
		gf.scrollFactor.set(0.95, 0.95);

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
			assetModifier += 'pixel';

		// isPixel = true;

		// reposition characters
		stageBuild.repositionPlayers(curStage, boyfriend, dadOpponent, gf);

		// add characters
		add(gf);

		add(dadOpponent);
		add(boyfriend);

		// force them to dance
		dadOpponent.dance();
		gf.dance();
		boyfriend.dance();

		// set song position before beginning
		Conductor.songPosition = -5000;

		// create strums and ui elements
		strumLine = new FlxTypedGroup<FlxSprite>();
		var strumLineY:Int = 50;
		if (Init.trueSettings.get('Downscroll'))
			strumLineY = FlxG.height - (strumLineY * 3);
		// trace('downscroll works???');

		for (i in 0...8)
		{
			var strumLinePart = new FlxSprite(0, strumLineY).makeGraphic(FlxG.width, 10);
			strumLinePart.scrollFactor.set();

			strumLine.add(strumLinePart);
		}

		// set up the elements for the notes
		strumLineNotes = new FlxTypedGroup<UIStaticArrow>();
		add(strumLineNotes);

		// now splash notes
		splashNotes = new FlxTypedGroup<NoteSplash>();
		add(splashNotes);

		// and now the note strums
		boyfriendStrums = new FlxTypedGroup<UIStaticArrow>();
		dadStrums = new FlxTypedGroup<UIStaticArrow>();

		// generate the song
		generateSong(SONG.song);

		// set the camera position to the center of the stage
		camPos.set(gf.x + (gf.width / 2), gf.y + (gf.height / 2));

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

		// set up camera dependencies (so that ui elements correspond to their cameras and such)
		strumLineNotes.cameras = [camHUD];
		splashNotes.cameras = [camHUD];
		notes.cameras = [camHUD];

		// actually set the camera up
		var camLerp = Main.framerateAdjust(0.02);
		FlxG.camera.follow(camFollow, LOCKON, camLerp);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow.getPosition());

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		// initialize ui elements
		startingSong = true;
		startedCountdown = true;

		for (i in 0...2)
			generateStaticArrows(i);

		uiHUD = new ClassHUD();
		add(uiHUD);
		uiHUD.cameras = [camHUD];
		//

		// call the funny intro cutscene depending on the song
		if (isStoryMode)
			songIntroCutscene();
		else
			switch (curSong.toLowerCase())
			{
				case 'marrow':
					isCutscene = true;
					FlxTween.tween(dadOpponent, {color: 0x000000}, 0.1);
					FlxTween.tween(uiHUD.iconP2, {color: 0x000000}, 0.1);
					camFollow.setPosition(dadOpponent.getMidpoint().x + 350, -300);
					FlxG.camera.focusOn(camFollow.getPosition());
					FlxG.camera.zoom = 1.5;
					FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 2.5, {
						ease: FlxEase.quadInOut,
						onComplete: function(twn:FlxTween)
						{
							startCountdown();
						}
					});
				case 'pelvic':
					uiHUD.iconP2.loadIcon('bones');
					remove(dadOpponent);
					dadOpponent = new Character(100, 100, 'bones');
					add(dadOpponent);
					dadOpponent.x += 320;
					dadOpponent.y += 260;
					FlxTween.tween(dadOpponent, {color: 0x000000}, 0.1);
					startCountdown();
				default:
					startCountdown();
			}

		super.create();
	}

	override public function update(elapsed:Float)
	{
		stageBuild.stageUpdateConstant(elapsed, boyfriend, gf, dadOpponent);

		super.update(elapsed);

		if (health > 2)
			health = 2;

		// pause the game if the game is allowed to pause and enter is pressed
		if (FlxG.keys.justPressed.ENTER && startedCountdown && canPause && !isCutscene)
		{
			// update drawing stuffs
			persistentUpdate = false;
			persistentDraw = true;
			paused = true;

			// open pause substate
			openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

			#if desktop
			// DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
			#end
		}

		// make sure you're not cheating lol
		if (!isStoryMode)
		{
			// charting state (more on that later)
			if ((FlxG.keys.justPressed.SEVEN) && (!startingSong))
			{
				resetMusic();
				if (Init.trueSettings.get('Use Forever Chart Editor'))
					Main.switchState(new ChartingState());
				else
					Main.switchState(new OriginalChartingState());
			}

			if (FlxG.keys.justPressed.SIX)
				boyfriendAutoplay = !boyfriendAutoplay;
		}

		///*
		if (startingSong)
		{
			if (startedCountdown && !isCutscene)
			{
				Conductor.songPosition += FlxG.elapsed * 1000;
				if (Conductor.songPosition >= 0)
					startSong();
			}
		}
		else
		{
			// Conductor.songPosition = FlxG.sound.music.time;
			Conductor.songPosition += FlxG.elapsed * 1000;

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

		if (generatedMusic && !isCutscene && PlayState.SONG.notes[Std.int(curStep / 16)] != null)
		{
			if (!PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection)
			{
				var char = dadOpponent;

				var getCenterX = char.getMidpoint().x + 150;
				var getCenterY = char.getMidpoint().y - 100;
				switch (dadOpponent.curCharacter)
				{
					case 'mom':
						getCenterY = char.getMidpoint().y;
					case 'senpai':
						getCenterY = char.getMidpoint().y - 430;
						getCenterX = char.getMidpoint().x - 100;
					case 'senpai-angry':
						getCenterY = char.getMidpoint().y - 430;
						getCenterX = char.getMidpoint().x - 100;
				}

				camFollow.setPosition(getCenterX + (camDisplaceX * 8), getCenterY);

				if (char.curCharacter == 'mom')
					vocals.volume = 1;

				///*
				if (SONG.song.toLowerCase().startsWith('annihilation'))
					forceZoom[0] = -0.15;
				// */
			}
			else
			{
				var char = boyfriend;

				var getCenterX = char.getMidpoint().x - 100;
				var getCenterY = char.getMidpoint().y - 100;
				switch (curStage)
				{
					case 'limo':
						getCenterX = char.getMidpoint().x - 300;
					case 'mall':
						getCenterY = char.getMidpoint().y - 200;
					case 'school':
						getCenterX = char.getMidpoint().x - 200;
						getCenterY = char.getMidpoint().y - 200;
					case 'schoolEvil':
						getCenterX = char.getMidpoint().x - 200;
						getCenterY = char.getMidpoint().y - 200;
				}

				camFollow.setPosition(getCenterX + (camDisplaceX * 8), getCenterY);

				///*
				if (SONG.song.toLowerCase().startsWith('annihilation'))
					forceZoom[0] = 0;
				//*/
			}
		}

		var easeLerp = 0.95;
		// camera stuffs
		FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom + forceZoom[0], FlxG.camera.zoom, easeLerp);
		camHUD.zoom = FlxMath.lerp(1 + forceZoom[1], camHUD.zoom, easeLerp);

		// not even forcezoom anymore but still
		FlxG.camera.angle = FlxMath.lerp(0 + forceZoom[2], FlxG.camera.angle, easeLerp);
		camHUD.angle = FlxMath.lerp(0 + forceZoom[3], camHUD.angle, easeLerp);

		if ((strumLineNotes.members.length > 0) && (!startingSong))
		{
			// fuckin uh strumline note stuffs
			for (i in 0...strumLineNotes.members.length)
			{
				strumLineNotes.members[i].x = FlxMath.lerp(strumLineNotes.members[i].xTo, strumLineNotes.members[i].x, easeLerp);
				strumLineNotes.members[i].y = FlxMath.lerp(strumLineNotes.members[i].yTo, strumLineNotes.members[i].y, easeLerp);

				strumLineNotes.members[i].angle = FlxMath.lerp(strumLineNotes.members[i].angleTo, strumLineNotes.members[i].angle, easeLerp);
			}
		}

		if (health <= 0 && startedCountdown)
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
		if (unspawnNotes[0] != null)
		{
			if ((unspawnNotes[0].strumTime - Conductor.songPosition) < 3500)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.add(dunceNote);

				unspawnNotes.splice(unspawnNotes.indexOf(dunceNote), 1);

				// thanks sammu I have no idea how this line works lmao
				notes.sort(FlxSort.byY, (!Init.trueSettings.get('Downscroll')) ? FlxSort.DESCENDING : FlxSort.ASCENDING);
			}
		}

		// handle all of the note calls
		if (!isCutscene)
			noteCalls();
	}

	//----------------------------------------------------------------
	//
	//
	//
	//	this is just a divider, move long.
	//
	//
	//
	//----------------------------------------------------------------

	private function mainControls(daNote:Note, char:Character, charStrum:FlxTypedGroup<UIStaticArrow>, autoplay:Bool, ?otherSide:Int = 0):Void
	{
		// call character type for later I'm so sorry this is painful
		var charCallType:Int = 0;
		if (char == boyfriend)
			charCallType = 1;

		// uh if condition from the original game

		// I have no idea what I have done
		var downscrollMultiplier = 1;
		if (Init.trueSettings.get('Downscroll'))
			downscrollMultiplier = -1;

		// im very sorry for this if condition I made it worse lmao
		///*
		if (daNote.isSustainNote
			&& (((daNote.y + daNote.offset.y <= (strumLine.members[Math.floor(daNote.noteData + (otherSide * 4))].y + Note.swagWidth / 2))
				&& !Init.trueSettings.get('Downscroll'))
				|| (((daNote.y - (daNote.offset.y * daNote.scale.y) + daNote.height) >= (strumLine.members[Math.floor(daNote.noteData + (otherSide * 4))].y
					+ Note.swagWidth / 2))
					&& Init.trueSettings.get('Downscroll')))
			&& (autoplay || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
		{
			var swagRectY = ((strumLine.members[Math.floor(daNote.noteData + (otherSide * 4))].y + Note.swagWidth / 2 - daNote.y) / daNote.scale.y);
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
				var canDisplayRating = false;
				if (charCallType == 1)
				{
					canDisplayRating = true;
					for (noteDouble in notesPressedAutoplay)
					{
						if (noteDouble.noteData == daNote.noteData)
						{
							// if (Math.abs(noteDouble.strumTime - daNote.strumTime) < 10)
							canDisplayRating = false;
							// removing the fucking check apparently fixes it
							// god damn it that stupid glitch with the double ratings is annoying
						}
						//
					}
					notesPressedAutoplay.push(daNote);
				}

				goodNoteHit(daNote, char, charStrum, canDisplayRating);
			}
			//
		}
	}

	//----------------------------------------------------------------
	//
	//
	//
	//	strum calls auto
	//
	//
	//
	//----------------------------------------------------------------

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

	//----------------------------------------------------------------
	//
	//
	//
	//
	//	idk I just need these cus the code is killing me
	//  I wanna see where the lines are for different functions
	//
	//
	//
	//----------------------------------------------------------------
	// call a note array
	public var notesPressedAutoplay:Array<Note> = [];

	private function noteCalls():Void
	{
		// get ready for nested script calls!

		// set up the controls for later usage
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

		// handle strumline stuffs
		for (i in 0...strumLine.length)
			strumLine.members[i].y = strumLineNotes.members[i].y + 25;

		for (i in 0...splashNotes.length)
		{
			// splash note positions
			splashNotes.members[i].x = strumLineNotes.members[i + 4].x - 48;
			splashNotes.members[i].y = strumLineNotes.members[i + 4].y - 56;
		}

		// reset strums
		for (i in 0...4)
		{
			boyfriendStrums.forEach(function(cStrum:UIStaticArrow)
			{
				if (boyfriendAutoplay)
					strumCallsAuto(cStrum);
			});
			dadStrums.forEach(function(cStrum:UIStaticArrow)
			{
				if (dadAutoplay)
					strumCallsAuto(cStrum);
			});
		}

		// if the song is generated
		if (generatedMusic)
		{
			// nested script #1
			controlPlayer(boyfriend, boyfriendAutoplay, boyfriendStrums, holdControls, pressControls, releaseControls);
			// controlPlayer(dadOpponent, dadAutoplay, dadStrums, holdControls, pressControls, releaseControls, false);

			notesPressedAutoplay = [];
			// call every single note that exists!
			notes.forEachAlive(function(daNote:Note)
			{
				// ya so this might be a lil unoptimised so I'm gonna keep it to a minimum with the calls honestly I'd rather not do them a lot

				// first we wanna orient the note positions.
				// lord forgive me for what I'm about to do but I can't use booleans as integers

				// don't follow this it's hellaaaa stupid code
				var otherSide = 0;
				var otherSustain:Float = 0;
				if (daNote.mustPress)
					otherSide = 1;
				if (daNote.isSustainNote)
					otherSustain = daNote.width;

				// set the notes x and y
				var downscrollMultiplier = 1;
				if (Init.trueSettings.get('Downscroll'))
					downscrollMultiplier = -1;

				daNote.y = (strumLine.members[Math.floor(daNote.noteData + (otherSide * 4))].y
					+ (downscrollMultiplier * -((Conductor.songPosition - daNote.strumTime) * (0.45 * FlxMath.roundDecimal(SONG.speed, 2)))));
				/*
					heres the part where I talk about how shitty my downscroll code is
					mostly because I don't actually understand downscroll and I don't play downscroll so its really more
					of an afterthought, if you feel like improving the code lemme know or make a pr or something I'll gladly accept it

					EDIT: I'm gonna try to revise it but no promises
					ya I give up if you wanna fix it go ahead idc anymore
					UPDATE: I MIGHT HAVE FIXED IT!!!!
				 */

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

				daNote.x = strumLineNotes.members[Math.floor(daNote.noteData + (otherSide * 4))].x + 25 + daNote.noteVisualOffset;

				// also set note rotation
				if (daNote.isSustainNote == false)
					daNote.angle = strumLineNotes.members[Math.floor(daNote.noteData + (otherSide * 4))].angle;

				// hell breaks loose here, we're using nested scripts!
				// get the note lane and run the corresponding script
				///*
				if (daNote.mustPress)
					mainControls(daNote, boyfriend, boyfriendStrums, boyfriendAutoplay, otherSide);
				else
					mainControls(daNote, dadOpponent, dadStrums, dadAutoplay); // dadOpponent autoplay is true by default and should be true unless neccessary
				// */

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
						healthCall(false);
						vocals.volume = 0;

						// I'll ask pixl if this is wrong and if he says yes I'll remove it
						decreaseCombo();

						// ambiguous name
						Timings.updateAccuracy(0);
					}

					daNote.active = false;
					daNote.visible = false;

					// note damage here I guess
					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}
			});
			//
		}
	}

	function controlPlayer(character:Character, autoplay:Bool, characterStrums:FlxTypedGroup<UIStaticArrow>, holdControls:Array<Bool>,
			pressControls:Array<Bool>, releaseControls:Array<Bool>, ?mustPress = true)
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

					notes.forEachAlive(function(daNote:Note)
					{
						if ((daNote.noteData == i) && daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit)
						{
							possibleNoteList.push(daNote);
							possibleNoteList.sort((a, b) -> Std.int(a.strumTime - b.strumTime));
						}
					});

					// if there is a list of notes that exists for that control
					if (possibleNoteList.length > 0)
					{
						var eligable = true;
						// this may be impractical, but I want overlayed notes to be played, just not count towards score or combo
						// this is so that they run code and stuff
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
					else
						missNoteCheck(i, pressControls, character); // else just call bad notes
					//
				}

				//
			}

			// check if anything is held
			if (holdControls.contains(true))
			{
				// check notes that are alive
				notes.forEachAlive(function(coolNote:Note)
				{
					if (coolNote.canBeHit && coolNote.mustPress && coolNote.isSustainNote && holdControls[coolNote.noteData])
						goodNoteHit(coolNote, character, characterStrums);
				});
			}

			// control camera movements
			// strumCameraRoll(characterStrums, true);

			characterStrums.forEach(function(strum:UIStaticArrow)
			{
				if ((pressControls[strum.ID]) && (strum.animation.curAnim.name != 'confirm'))
					strum.playAnim('pressed');
				if (releaseControls[strum.ID])
					strum.playAnim('static');
				//
			});
		}

		// reset bf's animation
		if (character.holdTimer > Conductor.stepCrochet * (4 / 1000) && (!holdControls.contains(true) || autoplay))
		{
			if (character.animation.curAnim.name.startsWith('sing') && !character.animation.curAnim.name.endsWith('miss'))
				character.dance();
		}
	}

	private var ratingTiming:String = "";

	function popUpScore(daRatings:Map<String, Array<Dynamic>>, baseRating:String, coolNote:Note)
	{
		// set up the rating
		var score:Int = 50;

		// notesplashes
		if (baseRating == "sick") // create the note splash if you hit a sick
			createSplash(coolNote);
		else // if it isn't a sick, and you had a sick combo, then it becomes not sick :(
			if (allSicks)
				allSicks = false;

		displayRating(baseRating);
		Timings.updateAccuracy(daRatings.get(baseRating)[2]);
		score = Std.int(daRatings.get(baseRating)[1]);

		songScore += score;

		popUpCombo();
	}

	private var createdColor = FlxColor.fromRGB(204, 66, 66);

	function popUpCombo()
	{
		var comboString:String = Std.string(combo);
		var negative = false;
		if ((comboString.startsWith('-')) || (combo == 0))
			negative = true;
		var stringArray:Array<String> = comboString.split("");
		for (scoreInt in 0...stringArray.length)
		{
			// numScore.loadGraphic(Paths.image('UI/' + pixelModifier + 'num' + stringArray[scoreInt]));
			var numScore = ForeverAssets.generateCombo('num' + stringArray[scoreInt], assetModifier, changeableSkin, 'UI', negative, createdColor, scoreInt,
				scoreGroup);
			add(numScore);

			FlxTween.tween(numScore, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween)
				{
					numScore.kill();
				},
				startDelay: Conductor.crochet * 0.002
			});
		}
	}

	//
	//
	//

	function decreaseCombo()
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
		popUpCombo();
		displayRating("miss");

		// gotta do it manually here lol
		Timings.updateFCDisplay();
	}

	function increaseCombo()
	{
		if (combo < 0)
			combo = 0;
		combo += 1;
	}

	//
	//
	//

	public function createSplash(coolNote:Note)
	{
		// play animation in existing notesplashes
		var noteSplashRandom:String = (Std.string((FlxG.random.int(0, 1) + 1)));
		splashNotes.members[coolNote.noteData].playAnim('anim' + noteSplashRandom);
	}

	public function displayRating(daRating:String)
	{
		// set a custom color if you have a perfect sick combo
		var perfectSickString:String = "";
		if ((allSicks) && (daRating == "sick"))
			perfectSickString = "-perfect";
		/* so you might be asking
			"oh but if the rating isn't sick why not just reset it"
			because miss ratings can pop, and they dont mess with your sick combo
		 */

		var noTiming:Bool = false;
		if ((daRating == "sick") || (daRating == "miss"))
			noTiming = true;

		var rating = ForeverAssets.generateRating('ratings/$daRating$perfectSickString', assetModifier, changeableSkin, 'UI', ratingsGroup);

		// this has to be loaded after unfortunately as much as I like to condense all of my code down
		if (assetModifier == 'basepixel' || assetModifier == 'foreverpixel')
			rating.setGraphicSize(Std.int(rating.width * daPixelZoom * 0.7));
		else
		{
			rating.antialiasing = true;
			rating.setGraphicSize(Std.int(rating.width * 0.7));
		}

		add(rating);

		// ooof this is very bad
		if (!noTiming)
		{
			var timing = timingsGroup.recycle(FlxSprite);
			timingsGroup.add(timing);
			// rating timing
			// setting the width, it's half of the sprite's width, I don't like doing this but that code scares me in terms of optimisations
			var newWidth = 166;
			if (assetModifier == 'pixel')
				newWidth = 26;

			timing.loadGraphic(Paths.image(ForeverTools.returnSkinAsset('ratings/$daRating-timings', assetModifier, changeableSkin, 'UI')), true, newWidth);
			timing.alpha = 1;
			// this code is quickly becoming painful lmao
			timing.animation.add('early', [0]);
			timing.animation.add('late', [1]);
			timing.animation.play(ratingTiming);

			timing.x = rating.x;
			timing.y = rating.y;
			timing.acceleration.y = rating.acceleration.y;
			timing.velocity.y = rating.velocity.y;
			timing.velocity.x = rating.velocity.x;

			// messy messy pixel stuffs
			// but thank you pixl your timings are awesome
			if (assetModifier == 'pixel')
			{
				// positions are stupid
				timing.x += (newWidth / 2) * daPixelZoom;
				timing.setGraphicSize(Std.int(timing.width * daPixelZoom * 0.7));
				if (ratingTiming != 'late')
					timing.x -= newWidth * 0.5 * daPixelZoom;
			}
			else
			{
				timing.antialiasing = (!Init.trueSettings.get('Disable Antialiasing'));
				timing.setGraphicSize(Std.int(timing.width * 0.7));
				if (ratingTiming == 'late')
					timing.x += newWidth * 0.5;
			}

			add(timing);

			FlxTween.tween(timing, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween)
				{
					timing.kill();
				},
				startDelay: Conductor.crochet * 0.00125
			});
		}

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

	function goodNoteHit(coolNote:Note, character:Character, characterStrums:FlxTypedGroup<UIStaticArrow>, ?canDisplayRating:Bool = true)
	{
		if (!coolNote.wasGoodHit)
		{
			coolNote.wasGoodHit = true;
			vocals.volume = 1;

			if (canDisplayRating)
			{
				// we'll need to call the rating here as it will also be used to determine health
				var noteDiff:Float = Math.abs(coolNote.strumTime - Conductor.songPosition);
				// also thanks sammu :mariocool:

				// call the ratings over from the timing class
				var daRatings = Timings.daRatings;

				var foundRating = false;
				// loop through all avaliable ratings
				var baseRating:String = "sick";
				for (myRating in daRatings.keys())
				{
					if ((daRatings.get(myRating)[0] != null)
						&& (((noteDiff > Conductor.safeZoneOffset * daRatings.get(myRating)[0])) && (!foundRating)))
					{
						// get the timing
						if (coolNote.strumTime < Conductor.songPosition)
							ratingTiming = "late";
						else
							ratingTiming = "early";

						// call the rating itself
						baseRating = myRating;
						foundRating = true;
					}
				}

				if (!coolNote.isSustainNote)
				{
					increaseCombo();
					popUpScore(daRatings, baseRating, coolNote);
					// health += 0.023;
				}
				else if (coolNote.isSustainNote)
				{
					// health += 0.004;
					// call updated accuracy stuffs
					Timings.updateAccuracy(100, true);
				}
				healthCall(true, coolNote, daRatings.get(baseRating)[3]);
			}

			characterPlayAnimation(coolNote, character);
			if (altString != 'miss')
			{
				characterStrums.members[coolNote.noteData].playAnim('confirm', true);

				if (!coolNote.isSustainNote)
				{
					// coolNote.callMods();
					coolNote.kill();
					notes.remove(coolNote, true);
					coolNote.destroy();
				}
			}
			else
				characterStrums.members[coolNote.noteData].playAnim('pressed', true);
			//
		}
	}

	function healthCall(increase:Bool, ?coolNote:Note, ?ratingMultiplier:Float = 0)
	{
		// health += 0.012;
		var healthBase:Float = 0.024 * 2.5;

		// self explanatory checks
		if (increase)
		{
			//
			var trueHealth = healthBase * 0.75;
			if ((coolNote.isSustainNote) && (coolNote.animation.name.endsWith('holdend')) && dadOpponent.curCharacter != 'FBIbodyguard')
				health += trueHealth;
			else if (!coolNote.isSustainNote && dadOpponent.curCharacter != 'FBIbodyguard')
				health += trueHealth * (ratingMultiplier / 100);
		}
		else
			health -= healthBase;
	}

	function missNoteCheck(direction:Int = 0, pressControls:Array<Bool>, character:Character)
	{
		if (pressControls[direction])
		{
			healthCall(false);
			var stringDirection:String = UIStaticArrow.getArrowFromNumber(direction);

			FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));
			character.playAnim('sing' + stringDirection.toUpperCase() + 'miss');

			decreaseCombo();
			//
		}
	}

	var altString:String = '';

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
					// changed it to FE formula yes I like consistency
					health += 0.024 * 2.5;
			}
		}

		stringArrow = baseString + altString;

		character.playAnim(stringArrow, true);

		if (character == dadOpponent && uiHUD.healthBar.percent > 50 && dadOpponent.curCharacter == 'FBI')
			health -= 0.03;

		character.holdTimer = 0;
	}

	//
	//
	//	please spare me
	//
	//

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

			#if desktop
			// Song duration in a float, useful for the time left feature
			songLength = songMusic.length;

			// Updating Discord Rich Presence (with Time Left)
			// DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC, true, songLength);
			#end
		}
	}

	private function generateSong(dataPath:String):Void
	{
		// FlxG.log.add(ChartParser.parse());

		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		curSong = songData.song;

		songMusic = new FlxSound().loadEmbedded(Paths.inst(SONG.song));

		if (SONG.needsVoices)
			vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
		else
			vocals = new FlxSound();

		FlxG.sound.list.add(songMusic);
		FlxG.sound.list.add(vocals);

		// here's where the chart loading takes place
		notes = new FlxTypedGroup<Note>();
		add(notes);

		// generate the chart
		// much simpler looking than in the original game lol
		ChartLoader.generateChartType(determinedChartType);

		// return the unspawned notes that were generated in said chart
		unspawnNotes = [];
		unspawnNotes = ChartLoader.returnUnspawnNotes();
		ChartLoader.flushUnspawnNotes();

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

	public function generateStaticArrows(player:Int):Void
	{
		for (i in 0...4)
		{
			// FlxG.log.add(i);
			// var babyArrow:FlxSprite = new FlxSprite(0, strumLine.y);
			var babyArrow:UIStaticArrow = ForeverAssets.generateUIArrows(0, strumLine.members[Math.floor(i + (player * 4))].y - 25, i, assetModifier);
			babyArrow.ID = i; // + (player * 4);

			switch (player)
			{
				case 1:
					boyfriendStrums.add(babyArrow);
				default:
					dadStrums.add(babyArrow);
			}

			babyArrow.x += 75;
			babyArrow.x += Note.swagWidth * i;
			babyArrow.x += ((FlxG.width / 2) * player);

			babyArrow.initialX = Math.floor(babyArrow.x);
			babyArrow.initialY = Math.floor(babyArrow.y);

			babyArrow.xTo = babyArrow.initialX;
			babyArrow.yTo = babyArrow.initialY;
			babyArrow.angleTo = 0;

			babyArrow.y -= 10;
			babyArrow.playAnim('static');

			babyArrow.alpha = 0;
			FlxTween.tween(babyArrow, {y: babyArrow.initialY, alpha: babyArrow.setAlpha}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});

			strumLineNotes.add(babyArrow);

			// generate note splashes
			if (player == 1)
			{
				var noteSplash:NoteSplash = ForeverAssets.generateNoteSplashes('noteSplashes', assetModifier, 'UI', i);
				noteSplash.x += Note.swagWidth * i;
				noteSplash.x += ((FlxG.width / 2) * player);
				splashNotes.add(noteSplash);
			}
		}
		//
	}

	//
	// I need some space okay? this code is claustrophobic as hell
	//

	function resyncVocals():Void
	{
		vocals.pause();

		songMusic.play();
		Conductor.songPosition = songMusic.time;
		vocals.time = Conductor.songPosition;
		vocals.play();
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
			&& (!dadOpponent.animation.curAnim.name.endsWith("swig")))
			dadOpponent.dance();
	}

	override function beatHit()
	{
		super.beatHit();

		if ((FlxG.camera.zoom < 1.35 && curBeat % 4 == 0) && (!Init.trueSettings.get('Reduced Movements')))
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
						dadOpponent = new Character(100, 100, 'alien-alt');
						FlxTween.tween(dadOpponent, {color: 0xa99dc9}, 0.0000001);
						add(dadOpponent);
						dadOpponent.alpha = 1;
						dadOpponent.x += 160;
						dadOpponent.y += 110;
					});

				case(168):
					remove(dadOpponent);
					dadOpponent = new Character(100, 100, 'alien');
					FlxTween.tween(dadOpponent, {color: 0xa99dc9}, 0.0000001);
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
						dadOpponent = new Character(100, 100, 'alien-pissed');
						uiHUD.iconP2.loadIcon('alien-pissed');
						FlxTween.tween(dadOpponent, {color: 0xa99dc9}, 0.0000001);
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
					remove(boyfriend);
					var black:FlxSprite = new FlxSprite(-250, -200).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
					black.scrollFactor.set();
					add(black);
					add(dadOpponent);
					FlxTween.tween(dadOpponent, {color: 0xFFFFFF}, 0.0000001);
					isCutscene = true;
					camHUD.visible = false;
					dadOpponent.playAnim('xigdeath', true);
			}
		}

		if (curSong == 'Annihilation')
		{
			switch (curBeat)
			{
				case 1:
					if (storyDifficulty == 1 || storyDifficulty == 0)
					{
						health = 0;
						new FlxTimer().start(1, function(swagTimer:FlxTimer)
						{
							FlxG.sound.play(Paths.sound('coward'), 1, false, null, true);
						});
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
				// FlxG.log.add('DING');

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
						dadOpponent = new Character(100, 100, 'harold-caffeinated');
						dadOpponent.x += 200;
						dadOpponent.y += 150;
						add(dadOpponent);
						uiHUD.iconP2.loadIcon('harold-caffeinated');
					});

				case 896:
					dadOpponent.playAnim("swig");
			}
		}
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
					vocals.volume = 1;
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
					dadOpponent = new Character(100, 100, 'bones-cool');
					dadOpponent.x += 320;
					dadOpponent.y += 220;
					add(dadOpponent);
					// SHUBS NOTE: using the code from the port of lazerz, which means this is gonna break too
					// fixed B)
					// thank you shubs :)
					uiHUD.iconP2.loadIcon('bones-cool');
					dadOpponent.playAnim('singUP');
					FlxTween.tween(yellow, {alpha: 0}, 1, {
						onComplete: function(twn:FlxTween)
						{
							FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 0.5);
						}
					});
				// FlxG.log.add('FLIP');

				case 50 | 54 | 58 | 62:
					// record scratches
					FlxTween.color(dadOpponent, 0.5, FlxColor.BLACK, FlxColor.WHITE);
					// FlxG.log.add('FLOP');
			}
		}
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

			if ((startTimer != null) && (!startTimer.finished))
				startTimer.active = true;
			paused = false;

			/*
				#if desktop
				if (startTimer.finished)
				{
					DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC, true, songLength - Conductor.songPosition);
				}
				else
				{
					DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
				}
				#end
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
		canPause = false;
		songMusic.volume = 0;
		vocals.volume = 0;
		if (SONG.validScore)
			Highscore.saveScore(SONG.song, songScore, storyDifficulty);

		if (!isStoryMode)
			Main.switchState(new FreeplayState());
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
				FlxG.sound.playMusic(Paths.music('freakyMenu'));

				// set up transitions
				transIn = FlxTransitionableState.defaultTransIn;
				transOut = FlxTransitionableState.defaultTransOut;

				// change to the menu state
				Main.switchState(new StoryMenuState());

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

	private function songEndSpecificActions()
	{
		switch (SONG.song.toLowerCase())
		{
			case 'eggnog':
				// make the lights go out
				var blackShit:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
					-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
				blackShit.scrollFactor.set();
				add(blackShit);
				camHUD.visible = false;

				// oooo spooky
				FlxG.sound.play(Paths.sound('Lights_Shut_off'));

				// call the song end
				var eggnogEndTimer:FlxTimer = new FlxTimer().start(Conductor.crochet / 1000, function(timer:FlxTimer)
				{
					callDefaultSongEnd();
				}, 1);

			default:
				callDefaultSongEnd();
		}
	}

	private function callDefaultSongEnd()
	{
		var difficulty:String = '-' + CoolUtil.difficultyFromNumber(storyDifficulty).toLowerCase();
		difficulty = difficulty.replace('-normal', '');

		FlxTransitionableState.skipNextTransIn = true;
		FlxTransitionableState.skipNextTransOut = true;

		PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + difficulty, PlayState.storyPlaylist[0]);
		ForeverTools.killMusic([songMusic, vocals]);

		Main.switchState(new PlayState());
	}

	public function songIntroCutscene()
	{
		switch (curSong.toLowerCase())
		{
			case 'probed':
				remove(dadOpponent);
				remove(gf);

				defaultCamZoom = 4;
				FlxG.camera.zoom = defaultCamZoom;
				forceZoom[0] = -3.1;

				var xigIntro:FlxSprite = new FlxSprite(100, -100);
				var cutsceneUfo:FlxSprite = new FlxSprite(100, -100);
				xigIntro.frames = Paths.getSparrowAtlas('cutscenes/opening');
				xigIntro.antialiasing = true;
				cutsceneUfo.frames = Paths.getSparrowAtlas('cutscenes/UFOempty');
				cutsceneUfo.antialiasing = true;
				xigIntro.animation.addByPrefix('idle', 'repairing', 24, false);
				cutsceneUfo.animation.addByPrefix('idle', 'Symbol 2 instance ', 24, false);
				add(cutsceneUfo);
				add(xigIntro);
				xigIntro.y += 300;
				xigIntro.x += 100;
				cutsceneUfo.y += 90;
				boyfriend.x += 250;

				boyfriend.dance();

				FlxTween.tween(boyfriend, {color: 0xa99dc9}, 0.0000001);
				FlxTween.tween(xigIntro, {color: 0xa99dc9}, 0.0000001);

				var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
				black.scrollFactor.set();
				add(black);

				camFollow.x -= 300;

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
			case 'annihilation-lol':
				var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
				black.scrollFactor.set();
				add(black);
				remove(dadOpponent);
				dadOpponent = new Character(100, 100, 'alien-pissed');
				add(dadOpponent);
				FlxTween.tween(dadOpponent, {color: 0xa99dc9}, 0.0000001);
				dadOpponent.x += 160;
				dadOpponent.y += 110;
				camFollow.x -= 300;

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
										dadOpponent = new Character(100, 100, 'alien-psychic');
										add(dadOpponent);
										FlxTween.tween(dadOpponent, {color: 0xa99dc9}, 0.0000001);
										new FlxTimer().start(1, function(swagTimer:FlxTimer)
										{
											FlxTween.tween(red, {alpha: 0}, 0.2, {
												onComplete: function(twn:FlxTween)
												{
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

				camFollow.x += 500;
				camFollow.y += 300;

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
			case 'itch':
				var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
				black.scrollFactor.set();
				add(black);
				remove(dadOpponent);
				dadOpponent = new Character(100, 100, 'harold');
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
									dadOpponent = new Character(100, 100, 'harold-caffeinated');
									add(dadOpponent);
									dadOpponent.x += 200;
									dadOpponent.y += 150;
									dadOpponent.playAnim('idle');
									FlxTween.tween(black, {alpha: 0}, 0.2, {
										onComplete: function(twn:FlxTween)
										{
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
			default:
				startCountdown();
		}
		//
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
				case 4:
			}

			swagCounter += 1;
			// generateSong('fresh');
		}, 5);
	}
}
