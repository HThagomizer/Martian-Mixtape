package gameFolder.meta.state.menus;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import gameFolder.meta.MusicBeat.MusicBeatState;
import gameFolder.meta.data.dependency.Discord;

using StringTools;

/**
	This is the main menu state! Not a lot is going to change about it so it'll remain similar to the original, but I do want to condense some code and such.
	Get as expressive as you can with this, create your own menu!
**/
class MainMenuState extends MusicBeatState
{
	var menuItems:FlxTypedGroup<FlxSprite>;
	var curSelected:Float = 0;

	var bg:FlxSprite; // the background has been separated for more control
	var magenta:FlxSprite;

	var creditsButton:FlxSprite;
	var camGame:FlxCamera;

	// the create 'state'
	override function create()
	{
		super.create();

		// set the transitions to the previously set ones
		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		// make sure the music is playing
		ForeverTools.resetMenuMusic();

		#if !html5
		Discord.changePresence('MENU SCREEN', 'Main Menu');
		#end

		// uh
		persistentUpdate = persistentDraw = true;

		camGame = new FlxCamera();
		FlxG.cameras.reset(camGame);
		FlxCamera.defaultCameras = [camGame];

		// background
		bg = new FlxSprite();
		bg.loadGraphic(Paths.image('menus/mixtape/bgs/' + Std.string(FlxG.random.int(1, 2))));
		bg.setGraphicSize(Std.int(bg.width * (2 / 3)));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = (!Init.trueSettings.get('Disable Antialiasing'));
		add(bg);

		var menu:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menus/mixtape/bg'));
		menu.setGraphicSize(Std.int(menu.width * (2 / 3)));
		menu.updateHitbox();
		menu.screenCenter();
		menu.antialiasing = (!Init.trueSettings.get('Disable Antialiasing'));
		add(menu);

		// add the menu items
		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		var story:FlxSprite = new FlxSprite();
		story.frames = Paths.getSparrowAtlas('menus/mixtape/MENU');
		story.animation.addByPrefix('unpress', 'Story', 24, false);
		story.animation.addByIndices('press', 'Story', [9, 8, 7, 6, 5, 4, 3, 2, 1, 0], '', 24, false);
		story.animation.play('unpress');
		story.setGraphicSize(Std.int(story.width * (2 / 3)));
		story.updateHitbox();
		story.antialiasing = true;
		story.setPosition(890, 105);
		menuItems.add(story);

		var freeplay:FlxSprite = new FlxSprite();
		freeplay.frames = Paths.getSparrowAtlas('menus/mixtape/MENU');
		freeplay.animation.addByPrefix('unpress', 'freeplay', 24, false);
		freeplay.animation.addByIndices('press', 'freeplay', [9, 8, 7, 6, 5, 4, 3, 2, 1, 0], '', 24, false);
		freeplay.animation.play('unpress');
		freeplay.setGraphicSize(Std.int(freeplay.width * (2 / 3)));
		freeplay.updateHitbox();
		freeplay.antialiasing = true;
		freeplay.setPosition(745, 298);
		menuItems.add(freeplay);

		var options:FlxSprite = new FlxSprite();
		options.frames = Paths.getSparrowAtlas('menus/mixtape/MENU');
		options.animation.addByPrefix('unpress', 'Settings', 24, false);
		options.animation.addByIndices('press', 'Settings', [9, 8, 7, 6, 5, 4, 3, 2, 1, 0], '', 24, false);
		options.animation.play('unpress');
		options.setGraphicSize(Std.int(options.width * (2 / 3)));
		options.updateHitbox();
		options.antialiasing = true;
		options.setPosition(590, 520);
		menuItems.add(options);

		creditsButton = new FlxSprite();
		creditsButton.frames = Paths.getSparrowAtlas('menus/mixtape/MENU');
		creditsButton.animation.addByPrefix('unpress', 'Credits2', 24, false);
		creditsButton.animation.addByIndices('press', 'Credits2', [9, 8, 7, 6, 5, 4, 3, 2, 1, 0], '', 24, false);
		creditsButton.animation.play('unpress');
		creditsButton.setGraphicSize(Std.int(creditsButton.width * (2 / 3)));
		creditsButton.updateHitbox();
		creditsButton.antialiasing = true;
		menuItems.add(creditsButton);
		creditsButton.setPosition(-50, (FlxG.height - creditsButton.height) + 50);

		//
		var versionShit:FlxText = new FlxText(20, 20, 0, "Forever Engine v" + Main.gameVersion, 24);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		// FlxG.camera.zoom = 0.5;
		updateSelection();
	}

	// var colorTest:Float = 0;
	var selectedSomethin:Bool = false;
	var counterControl:Float = 0;

	override function update(elapsed:Float)
	{
		// colorTest += 0.125;
		// bg.color = FlxColor.fromHSB(colorTest, 100, 100, 0.5);

		var up = controls.UP;
		var down = controls.DOWN;
		var up_p = controls.UP_P;
		var down_p = controls.DOWN_P;
		if (!selectedSomethin)
		{
			if (up_p)
				updateSelection(-1);
			else if (down_p)
				updateSelection(1);
			if (controls.LEFT_P || controls.RIGHT_P)
				horizontalSelection();
			if (controls.ACCEPT)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('confirmMenu'));
				FlxTween.tween(camGame, {zoom: 2, angle: 12, alpha: 0}, 0.5, {
					ease: FlxEase.circInOut,
					onComplete: function(tween:FlxTween)
					{
						switch (curSelection)
						{
							case 0:
								Main.switchState(this, new StoryMenuState());
							case 1:
								Main.switchState(this, new FreeplayState());
							case 2:
								Main.switchState(this, new OptionsMenuState());
							case 3:
								Main.switchState(this, new CreditsState());
						}
					}
				});
			}
		}
	}

	var curSelection:Int = 0;

	function updateSelection(?updateBy:Int = 0)
	{
		selectionLeft = false;
		curSelection = curSelection + updateBy;
		if (curSelection < 0)
			curSelection = menuItems.members.length - 1;
		else if (curSelection >= menuItems.members.length)
			curSelection = 0;
		if (updateBy != 0)
			FlxG.sound.play(Paths.sound('scrollMenu'));

		menuItems.forEach(function(item:FlxSprite)
		{
			item.animation.play('unpress');
		});
		menuItems.members[curSelection].animation.play('press');
	}

	var selectionLeft:Bool = false;
	var lastSelection:Int;

	function horizontalSelection()
	{
		FlxG.sound.play(Paths.sound('scrollMenu'));
		if (!selectionLeft)
		{
			lastSelection = curSelection;
			curSelection = menuItems.members.length - 1;
			menuItems.forEach(function(item:FlxSprite)
			{
				item.animation.play('unpress');
			});
			creditsButton.animation.play('press');
			selectionLeft = true;
		}
		else
		{
			curSelection = lastSelection;
			updateSelection();
		}
	}
}
