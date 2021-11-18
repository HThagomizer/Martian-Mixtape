package gameFolder.meta.state;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.system.ui.FlxSoundTray;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import gameFolder.meta.MusicBeat.MusicBeatState;
import gameFolder.meta.data.*;
import gameFolder.meta.data.font.Alphabet;
import gameFolder.meta.state.menus.*;
import lime.app.Application;
import openfl.Assets;

using StringTools;

/**
	I hate this state so much that I gave up after trying to rewrite it 3 times and just copy pasted the original code
	with like minor edits so it actually runs in forever engine. I'll redo this later, I've said that like 12 times now

	I genuinely fucking hate this code no offense ninjamuffin I just dont like it and I don't know why or how I should rewrite it
**/
class TitleState extends MusicBeatState
{
	static var initialized:Bool = false;

	var blackScreen:FlxSprite;
	var credTextShit:Alphabet;
	var textGroup:FlxGroup;

	var curWacky:Array<String> = [];

	var wackyImage:FlxSprite;
	var camGame:FlxCamera;

	override public function create():Void
	{
		controls.setKeyboardScheme(None, false);
		super.create();

		camGame = new FlxCamera();
		camGame.zoom = 0.7;
		FlxG.cameras.reset(camGame);
		FlxCamera.defaultCameras = [camGame];

		new FlxTimer().start(1, function(tmr:FlxTimer)
		{
			startIntro();
		});
	}

	var belltower:FlxSprite;
	var bgsmoke:FlxSprite;
	var ufo:FlxSprite;
	var fgsmoke:FlxSprite;
	var logoBl:FlxSprite;
	var titleText:FlxSprite;

	function startIntro()
	{
		var offsetX = -338; 
		var offsetY = -190;
		if (!initialized)
		{
			///*
			var diamond:FlxGraphic = FlxGraphic.fromClass(GraphicTransTileDiamond);
			diamond.persist = true;
			diamond.destroyOnNoUse = false;

			FlxTransitionableState.defaultTransIn = new TransitionData(FADE, FlxColor.BLACK, 0.32, new FlxPoint(0, -1),
				{asset: diamond, width: 32, height: 32}, new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));
			FlxTransitionableState.defaultTransOut = new TransitionData(FADE, FlxColor.BLACK, 0.32, new FlxPoint(0, 1),
				{asset: diamond, width: 32, height: 32}, new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));

			transIn = FlxTransitionableState.defaultTransIn;
			transOut = FlxTransitionableState.defaultTransOut;
			// */

			Conductor.changeBPM(87);
		}

		persistentUpdate = true;

		var bg:FlxSprite = new FlxSprite(-138 + offsetX, -88 + offsetY).loadGraphic(Paths.image('menus/mixtape/title/sky'));
		bg.antialiasing = true;
		add(bg);

		belltower = new FlxSprite(533 + offsetX, -21 + offsetY);
		belltower.frames = Paths.getSparrowAtlas('menus/mixtape/title/belltower');
		belltower.antialiasing = true;
		belltower.animation.addByPrefix('bump', 'BellTower', 18, true);
		belltower.updateHitbox();
		add(belltower);

		var trees:FlxSprite = new FlxSprite(-108 + offsetX, 36 + offsetY).loadGraphic(Paths.image('menus/mixtape/title/trees'));
		trees.antialiasing = true;
		add(trees);

		bgsmoke = new FlxSprite(473 + offsetX, -93 + offsetY);
		bgsmoke.frames = Paths.getSparrowAtlas('menus/mixtape/title/backgroundsmoke');
		bgsmoke.antialiasing = true;
		bgsmoke.animation.addByPrefix('bump', 'SmokeBackground', 22, true);
		bgsmoke.animation.play('bump');
		bgsmoke.updateHitbox();
		add(bgsmoke);

		ufo = new FlxSprite(-88 + offsetX, 419 + offsetY);
		ufo.frames = Paths.getSparrowAtlas('menus/mixtape/title/ship');
		ufo.antialiasing = true;
		ufo.animation.addByPrefix('bump', 'Ship', 18, true);
		ufo.updateHitbox();
		add(ufo);

		fgsmoke = new FlxSprite(900 + offsetX, 868 + offsetY);
		fgsmoke.frames = Paths.getSparrowAtlas('menus/mixtape/title/foregroundsmoke');
		fgsmoke.antialiasing = true;
		fgsmoke.animation.addByPrefix('bump', 'SmokeForeground', 22, true);
		fgsmoke.animation.play('bump');
		fgsmoke.updateHitbox();
		add(fgsmoke);

		var fgdirt:FlxSprite = new FlxSprite(-173 + offsetX, 930 + offsetY).loadGraphic(Paths.image('menus/mixtape/title/foregrounddirt'));
		fgdirt.antialiasing = true;
		add(fgdirt);

		logoBl = new FlxSprite(886 + offsetX, 37 + offsetY);
		logoBl.frames = Paths.getSparrowAtlas('menus/mixtape/title/logobump');
		logoBl.antialiasing = true;
		logoBl.animation.addByPrefix('bump', 'LogoBump', 18, true);
		logoBl.updateHitbox();
		// logoBl.screenCenter();
		// logoBl.color = FlxColor.BLACK;

		add(logoBl);

		titleText = new FlxSprite();
		titleText.frames = Paths.getSparrowAtlas('menus/base/title/titleEnter');
		titleText.animation.addByPrefix('idle', "Press Enter to Begin", 24);
		titleText.animation.addByPrefix('press', "ENTER PRESSED", 24);
		titleText.antialiasing = true;
		titleText.animation.play('idle');
		titleText.updateHitbox();
		titleText.screenCenter();
		titleText.x += (320 - 100);
		titleText.y += 400;
		add(titleText);

		initialized = true;

		// credGroup.add(credTextShit);

		// to preload the song
		FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
		FlxG.sound.pause();

		FlxG.sound.playMusic(Paths.music('freakyAmbience'), 0.7);

		// we should have like ambient sounds playing or smth so it doesn't sound empty before you press enter
	}

	var transitioning:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;
		// FlxG.watch.addQuick('amp', FlxG.sound.music.amplitude);

		if (FlxG.keys.justPressed.F)
		{
			FlxG.fullscreen = !FlxG.fullscreen;
		}

		var pressedEnter:Bool = FlxG.keys.justPressed.ENTER;

		#if mobile
		for (touch in FlxG.touches.list)
		{
			if (touch.justPressed)
			{
				pressedEnter = true;
			}
		}
		#end

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		if (gamepad != null)
		{
			if (gamepad.justPressed.START)
				pressedEnter = true;

			#if switch
			if (gamepad.justPressed.B)
				pressedEnter = true;
			#end
		}

		if (pressedEnter && !transitioning)
		{
			titleText.animation.play('press');
			belltower.animation.play('bump');
			ufo.animation.play('bump');
			logoBl.animation.play('bump');

			FlxG.camera.flash(FlxColor.WHITE, 1);
			FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);

			FlxG.sound.playMusic(Paths.music('freakyMenu'), 0.7);
			Conductor.changeBPM(87);

			transitioning = true;
			// FlxG.sound.music.stop();

			new FlxTimer().start(4.84, function(tmr:FlxTimer)
			{
				FlxTween.tween(camGame, {zoom: 2, angle: 12, alpha: 0}, 0.3, {
					ease: FlxEase.circInOut,
					onComplete: function(tween:FlxTween)
					{
						// Check if version is outdated

						var version:String = "v" + Application.current.meta.get('version');
						/*
							if (version.trim() != NGio.GAME_VER_NUMS.trim() && !OutdatedSubState.leftState)
							{
								FlxG.switchState(new OutdatedSubState());
								trace('OLD VERSION!');
								trace('old ver');
								trace(version.trim());
								trace('cur ver');
								trace(NGio.GAME_VER_NUMS.trim());
							}
							else
							{ */
						Main.switchState(this, new MainMenuState());
						// }
					}
				});
			});
			// FlxG.sound.play(Paths.music('titleShoot'), 0.7);
		}

		super.update(elapsed);
	}

	override function beatHit()
	{
		super.beatHit();
	}
}
