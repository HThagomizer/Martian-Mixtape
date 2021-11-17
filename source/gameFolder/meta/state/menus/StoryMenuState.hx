package gameFolder.meta.state.menus;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import gameFolder.gameObjects.userInterface.menu.*;
import gameFolder.meta.MusicBeat.MusicBeatState;
import gameFolder.meta.data.*;
import gameFolder.meta.data.dependency.Discord;

using StringTools;

class StoryMenuState extends MusicBeatState
{
	var scoreText:FlxText;
	var curDifficulty:Int = 1;

	public static var weekUnlocked:Array<Bool> = [true, true, true, true, true, true, true];

	var weekCharacters:Array<Dynamic> = [
		[['alien', 'alien-rude'], 'bf', 'gf'],
		[['fbi', ''], 'bf', 'gf'],
		[['bones', ''], 'bf', 'gf'],
		[['harold', ''], 'bf', 'gf'],
		[['xigman', ''], 'bf', 'gf'],
		[['', ''], 'bf', 'gf']
	];

	var txtWeekTitle:FlxText;

	var curWeek:Int = 0;
	var currentCategory:Int = 0;

	var txtTracklist:FlxText;

	var grpWeekText:FlxTypedGroup<MenuItem>;
	var grpWeekCharacters:FlxTypedGroup<MenuCharacter>;

	var grpLocks:FlxTypedGroup<FlxSprite>;

	var difficultySelectors:FlxGroup;
	var sprDifficulty:FlxSprite;
	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;

	var buttonHint:FlxSprite;
	var changeFlash:FlxSprite;

	var yellowBG:FlxSprite;

	var weeksList:Array<Int> = [];

	override function create()
	{
		super.create();

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		#if !html5
		Discord.changePresence('STORY MENU', 'Main Menu');
		#end

		// freeaaaky
		ForeverTools.resetMenuMusic();

		persistentUpdate = persistentDraw = true;

		scoreText = new FlxText(10, 10, 0, "SCORE: 49324858", 36);
		scoreText.setFormat("VCR OSD Mono", 32);

		txtWeekTitle = new FlxText(FlxG.width * 0.7, 10, 0, "", 32);
		txtWeekTitle.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, RIGHT);
		txtWeekTitle.alpha = 0.7;

		var rankText:FlxText = new FlxText(0, 10);
		rankText.text = 'RANK: GREAT';
		rankText.setFormat(Paths.font("vcr.ttf"), 32);
		rankText.size = scoreText.size;
		rankText.screenCenter(X);

		var ui_tex = Paths.getSparrowAtlas('menus/base/storymenu/campaign_menu_UI_assets');
		yellowBG = new FlxSprite(0, 56).makeGraphic(FlxG.width, 400, 0xFFFFFFFF);
		yellowBG.color = 0xFFF9CF51;

		grpWeekText = new FlxTypedGroup<MenuItem>();
		add(grpWeekText);

		var blackBarThingie:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, 56, FlxColor.BLACK);
		add(blackBarThingie);

		grpWeekCharacters = new FlxTypedGroup<MenuCharacter>();

		grpLocks = new FlxTypedGroup<FlxSprite>();
		add(grpLocks);

		addWeeks();

		trace("Line 96");

		for (char in 0...3)
		{
			var character = weekCharacters[curWeek][char];
			var alt = '';

			if (char == 0)
			{
				character = weekCharacters[curWeek][char][0];
				alt = weekCharacters[curWeek][char][1];
			}

			var weekCharacterThing:MenuCharacter = new MenuCharacter((FlxG.width * 0.25) * (1 + char) - 150, character, alt);
			weekCharacterThing.antialiasing = (!Init.trueSettings.get('Disable Antialiasing'));

			switch (weekCharacterThing.character)
			{
				case 'bf':
					weekCharacterThing.setGraphicSize(Std.int(weekCharacterThing.width * 0.9));
					weekCharacterThing.updateHitbox();
					weekCharacterThing.x -= 80;
				case 'gf':
					weekCharacterThing.setGraphicSize(Std.int(weekCharacterThing.width * 0.5));
					weekCharacterThing.updateHitbox();
			}

			grpWeekCharacters.add(weekCharacterThing);
		}

		difficultySelectors = new FlxGroup();
		add(difficultySelectors);

		trace("Line 124");

		leftArrow = new FlxSprite(grpWeekText.members[0].x + grpWeekText.members[0].width + 10, grpWeekText.members[0].y + 10);
		leftArrow.frames = ui_tex;
		leftArrow.animation.addByPrefix('idle', "arrow left");
		leftArrow.animation.addByPrefix('press', "arrow push left");
		leftArrow.animation.play('idle');
		difficultySelectors.add(leftArrow);

		sprDifficulty = new FlxSprite(leftArrow.x + 130, leftArrow.y);
		sprDifficulty.frames = ui_tex;
		for (i in CoolUtil.difficultyArray)
			sprDifficulty.animation.addByPrefix(i.toLowerCase(), i.toUpperCase());
		sprDifficulty.animation.addByPrefix("alt", "ALT");
		sprDifficulty.animation.play('easy');
		changeDifficulty();

		difficultySelectors.add(sprDifficulty);

		rightArrow = new FlxSprite(sprDifficulty.x + sprDifficulty.width + 100, leftArrow.y);
		rightArrow.frames = ui_tex;
		rightArrow.animation.addByPrefix('idle', 'arrow right');
		rightArrow.animation.addByPrefix('press', "arrow push right", 24, false);
		rightArrow.animation.play('idle');
		difficultySelectors.add(rightArrow);

		trace("Line 150");

		add(yellowBG);
		add(grpWeekCharacters);

		txtTracklist = new FlxText(FlxG.width * 0.05, yellowBG.x + yellowBG.height + 100, 0, "Tracks", 32);
		txtTracklist.alignment = CENTER;
		txtTracklist.font = rankText.font;
		txtTracklist.color = 0xFFe55777;
		add(txtTracklist);
		// add(rankText);
		add(scoreText);
		add(txtWeekTitle);

		// very unprofessional yoshubs!

		buttonHint = new FlxSprite(900, 600);
		buttonHint.frames = ui_tex;
		buttonHint.animation.addByPrefix('alt', 'altbutton');
		buttonHint.animation.addByPrefix('story', "storybutton");
		buttonHint.animation.play('alt');
		add(buttonHint);

		changeFlash = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFFFFFFFF);
		changeFlash.alpha = 0;
		add(changeFlash);

		updateText();
	}

	override function update(elapsed:Float)
	{
		// scoreText.setFormat('VCR OSD Mono', 32);
		var lerpVal = Main.framerateAdjust(0.5);
		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, lerpVal));

		scoreText.text = "WEEK SCORE:" + lerpScore;

		txtWeekTitle.text = Main.gameWeeks[weeksList[curWeek]][3].toUpperCase();
		txtWeekTitle.x = FlxG.width - (txtWeekTitle.width + 10);

		// FlxG.watch.addQuick('font', scoreText.font);

		difficultySelectors.visible = weekUnlocked[curWeek];

		grpLocks.forEach(function(lock:FlxSprite)
		{
			lock.y = grpWeekText.members[lock.ID].y;
		});

		if (!movedBack)
		{
			if (!selectedWeek)
			{
				if (controls.UP_P)
					changeWeek(-1);
				else if (controls.DOWN_P)
					changeWeek(1);

				if (controls.RIGHT)
					rightArrow.animation.play('press')
				else
					rightArrow.animation.play('idle');

				if (controls.LEFT)
					leftArrow.animation.play('press');
				else
					leftArrow.animation.play('idle');

				if (currentCategory == 0)
				{
					if (controls.RIGHT_P)
						changeDifficulty(1);
					if (controls.LEFT_P)
						changeDifficulty(-1);
				}

				if (FlxG.keys.justPressed.E)
				{
					if (currentCategory == 0)
					{
						currentCategory = 1;
					}
					else
					{
						currentCategory = 0;
					}

					changeDifficulty(0);

					FlxG.sound.play(Paths.sound('confirmMenu'));
					if (!Init.trueSettings.get('Photosensitivity Tweaks'))
					{
						changeFlash.alpha = 1.2;
					}
					curWeek	= 0;
					addWeeks();
					updateText();
				}
			}

			if (controls.ACCEPT)
				selectWeek();
		}

		if (controls.BACK && !movedBack && !selectedWeek)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			movedBack = true;
			Main.switchState(this, new MainMenuState());
		}

		if (currentCategory == 0)
		{
			buttonHint.animation.play('alt');
			yellowBG.color = 0xFF52BF62;

			leftArrow.alpha = 1;
			rightArrow.alpha = 1;
		}
		else
		{
			buttonHint.animation.play('story');
			sprDifficulty.animation.play('alt');
			yellowBG.color = 0xFF3399FF;

			leftArrow.alpha = 0;
			rightArrow.alpha = 0;
		}

		if (changeFlash.alpha > 0)
			changeFlash.alpha -= 0.01;

		super.update(elapsed);
	}

	var movedBack:Bool = false;
	var selectedWeek:Bool = false;
	var stopspamming:Bool = false;

	function selectWeek()
	{
		if (weekUnlocked[curWeek])
		{
			if (stopspamming == false)
			{
				FlxG.sound.play(Paths.sound('confirmMenu'));

				grpWeekText.members[curWeek].startFlashing();
				grpWeekCharacters.members[1].createCharacter('bfConfirm');
				stopspamming = true;
			}

			if (currentCategory == 1)
				curDifficulty = 1;

			PlayState.storyPlaylist = Main.gameWeeks[weeksList[curWeek]][0].copy();
			PlayState.isStoryMode = true;
			selectedWeek = true;

			var diffic:String = '-' + CoolUtil.difficultyFromNumber(curDifficulty).toLowerCase();
			diffic = diffic.replace('-normal', '');

			PlayState.storyDifficulty = curDifficulty;

			PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + diffic, PlayState.storyPlaylist[0].toLowerCase());
			PlayState.storyWeek = curWeek;
			PlayState.campaignScore = 0;
			new FlxTimer().start(1, function(tmr:FlxTimer)
			{
				Main.switchState(this, new PlayState());
			});
		}
	}

	function changeDifficulty(change:Int = 0):Void
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = CoolUtil.difficultyLength - 1;
		if (curDifficulty > CoolUtil.difficultyLength - 1)
			curDifficulty = 0;

		sprDifficulty.offset.x = 0;

		var difficultyString = CoolUtil.difficultyFromNumber(curDifficulty).toLowerCase();
		sprDifficulty.animation.play(difficultyString);
		switch (curDifficulty)
		{
			case 0:
				sprDifficulty.offset.x = 20;
			case 1:
				sprDifficulty.offset.x = 70;
			case 2:
				sprDifficulty.offset.x = 20;
		}

		if (currentCategory == 1)
		{
			sprDifficulty.offset.x = -30;
		}

		sprDifficulty.alpha = 0;

		// USING THESE WEIRD VALUES SO THAT IT DOESNT FLOAT UP
		sprDifficulty.y = leftArrow.y - 15;
		intendedScore = Highscore.getWeekScore(curWeek, curDifficulty);

		FlxTween.tween(sprDifficulty, {y: leftArrow.y + 15, alpha: 1}, 0.07);
	}

	var lerpScore:Int = 0;
	var intendedScore:Int = 0;

	function changeWeek(change:Int = 0):Void
	{
		curWeek += change;

		if (curWeek >= weeksList.length)
			curWeek = 0;
		if (curWeek < 0)
			curWeek = weeksList.length - 1;

		var bullShit:Int = 0;

		for (item in grpWeekText.members)
		{
			item.targetY = bullShit - curWeek;
			if (item.targetY == Std.int(0) && weekUnlocked[curWeek])
				item.alpha = 1;
			else
				item.alpha = 0.6;
			bullShit++;
		}

		FlxG.sound.play(Paths.sound('scrollMenu'));

		updateText();
	}

	function updateText()
	{
		grpWeekCharacters.members[0].createCharacter(weekCharacters[curWeek][0][currentCategory], true);
		// grpWeekCharacters.members[1].createCharacter(weekCharacters[curWeek][1]);
		// grpWeekCharacters.members[2].createCharacter(weekCharacters[curWeek][2]);
		txtTracklist.text = "Tracks\n";

		var stringThing:Array<String> = Main.gameWeeks[weeksList[curWeek]][0];
		for (i in stringThing)
			txtTracklist.text += "\n" + CoolUtil.dashToSpace(i);

		txtTracklist.text += "\n"; // pain
		txtTracklist.text = txtTracklist.text.toUpperCase();

		txtTracklist.screenCenter(X);
		txtTracklist.x -= FlxG.width * 0.35;

		intendedScore = Highscore.getWeekScore(curWeek, curDifficulty);
	}

	function addWeeks()
	{
		var ui_tex = Paths.getSparrowAtlas('menus/base/storymenu/campaign_menu_UI_assets');
		
		grpWeekText.clear();
		grpLocks.clear();

		weeksList = [];

		var weekIndex = 0;
		for (i in 0...Main.gameWeeks.length)
		{
			if (Main.gameWeeks[i][4] != currentCategory) 
				continue;

			weeksList.push(i);
			
			var weekThing:MenuItem = new MenuItem(0, yellowBG.y + yellowBG.height + 10, weekIndex);
			weekThing.y += ((weekThing.height + 20) * weekIndex);
			weekThing.targetY = weekIndex;
			grpWeekText.add(weekThing);

			weekThing.screenCenter(X);
			weekThing.antialiasing = (!Init.trueSettings.get('Disable Antialiasing'));
			// weekThing.updateHitbox();

			// Needs an offset thingie
			if (!weekUnlocked[weekIndex])
			{
				var lock:FlxSprite = new FlxSprite(weekThing.width + 10 + weekThing.x);
				lock.frames = ui_tex;
				lock.animation.addByPrefix('lock', 'lock');
				lock.animation.play('lock');
				lock.ID = weekIndex;
				lock.antialiasing = (!Init.trueSettings.get('Disable Antialiasing'));
				grpLocks.add(lock);
			}

			weekIndex++;
		}

		trace(weeksList);
	}
}
