package gameFolder.meta.state.menus;

import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.tweens.misc.ColorTween;
import flixel.util.FlxColor;
import gameFolder.gameObjects.userInterface.HealthIcon;
import gameFolder.meta.MusicBeat.MusicBeatState;
import gameFolder.meta.data.*;
import gameFolder.meta.data.Song.SwagSong;
import gameFolder.meta.data.dependency.Discord;
import gameFolder.meta.data.font.Alphabet;
import lime.utils.Assets;
import openfl.media.Sound;
import sys.FileSystem;
import sys.thread.Thread;

using StringTools;

class FreeplayState extends MusicBeatState
{
	//
	var songs:Array<SongMetadata> = [];

	var selector:FlxText;
	var curSelected:Int = 0;
	var curSongPlaying:Int = -1;
	var curDifficulty:Int = 1;

	var blurbText:FlxText;
	var scoreText:FlxText;
	var diffText:FlxText;
	var lerpScore:Int = 0;
	var intendedScore:Int = 0;

	var songThread:Thread;
	var threadActive:Bool = true;

	private var grpSongs:FlxTypedGroup<Alphabet>;
	private var curPlaying:Bool = false;

	private var iconGroup:FlxTypedGroup<HealthIcon>;

	private var mainColor = FlxColor.WHITE;

	private var behind:FlxSprite;
	private var sides:FlxSprite;
	private var hologram:FlxSprite;
	private var marker:FlxSprite;

	private var grayBox:FlxSprite;

	private var topButtonsFrame:FlxSprite;
	private var bottom:FlxSprite;

	private var buttonGroup:FlxTypedGroup<FlxSprite>;

	private var scoreBG:FlxSprite;

	private var existingSongs:Array<String> = [];
	private var existingDifficulties:Array<Array<String>> = [];

	private var selectingCategory:Bool = true;
	private var selectedCategory:Int = 0;

	public static var songBlurbs:Map<String, String> = [
		// week 1
		"probed" => "lets hope it doesnt go THERE",
		"lazerz" => "cowboy alien music",
		"brainfuck" => "saying what the masses are afraid to",
		"annihilation-lol" => "this is top notch charting",

		// week 2
		"confidential" => "[REDACTED]",
		"aegis" => "hes kinda built though",
		"crack" => "like hacking or like drugs?",
		"enforcement" => "everything is fine and aliens are not real",

		// week 3
		"marrow" => "like bone juice",
		"pelvic" => "jet set who?",
		"spinal tap" => "SKELETON GUITAR",

		// week 4
		"tinfoil" => "he seems like a well adjusted individual",
		"jitter" => "wheres the screenshake",
		"exclusion zone" => "unchill beats to evade the FBI to",

		// week 5
		"boing" => "google eyed weirdo",
		"freak" => "those teeth could bite someones head off",
		"breakout" => "i dont feel safe",

		// week 1-alt
		"rude" => "why are you being mean to me",
		"extermination" => "official yoshubs statement: banger alert",
		"craniotomy" => "maybe some aspirin would help",
		"aneurysmia" => "we did the same joke again",

		// bonus songs
		"annihilation" => "you asked for it",
		"aerodynamix" => "wait who's driving",
		"spacecataz" => "jumping... is useless",
		"egomania" => "you got your dialogue alright"
	];

	override function create()
	{
		super.create();

		selectedCategory = 0;

		/**
			Wanna add songs? They're in the Main state now, you can just find the week array and add a song there to a specific week.
			Alternatively, you can make a folder in the Songs folder and put your songs there, however, this gives you less
			control over what you can display about the song (color, icon, etc) since it will be pregenerated for you instead.
		**/
		grpSongs = new FlxTypedGroup<Alphabet>();
		iconGroup = new FlxTypedGroup<HealthIcon>();
		addWeeks();

		// LOAD MUSIC
		// ForeverTools.resetMenuMusic();

		#if !html5
		Discord.changePresence('FREEPLAY MENU', 'Main Menu');
		#end

		// LOAD CHARACTERS

		behind = new FlxSprite().loadGraphic(Paths.image('menus/mixtape/freeplay/behind'));
		sides = new FlxSprite().loadGraphic(Paths.image('menus/mixtape/freeplay/sides'));
		hologram = new FlxSprite().loadGraphic(Paths.image('menus/mixtape/freeplay/holonogram'));
		marker = new FlxSprite().loadGraphic(Paths.image('menus/mixtape/freeplay/marker'));

		topButtonsFrame = new FlxSprite().loadGraphic(Paths.image('menus/mixtape/freeplay/freeplay_top_buttons'));
		bottom = new FlxSprite().loadGraphic(Paths.image('menus/mixtape/freeplay/freeplay_bottom'));
		bottom.setPosition(0, 560);

		buttonGroup = new FlxTypedGroup<FlxSprite>();

		var buttonY = 12;

		var buttonStory = new FlxSprite().loadGraphic(Paths.image('menus/mixtape/freeplay/button_storymode'));
		buttonStory.setPosition(47, buttonY);
		buttonGroup.add(buttonStory);

		var buttonAlt = new FlxSprite().loadGraphic(Paths.image('menus/mixtape/freeplay/button_alt'));
		buttonAlt.setPosition(463, buttonY);
		buttonGroup.add(buttonAlt);

		var buttonBonus = new FlxSprite().loadGraphic(Paths.image('menus/mixtape/freeplay/button_bonus'));
		buttonBonus.setPosition(860, buttonY);
		buttonGroup.add(buttonBonus);

		grayBox = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
		grayBox.alpha = 0;

		add(behind);
		add(hologram);
		add(marker);

		add(grpSongs);
		add(iconGroup);

		add(grayBox);

		add(sides);
		add(buttonGroup);

		add(topButtonsFrame);
		add(bottom);

		blurbText = new FlxText(0, 230, 0, "", 16);
		blurbText.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, RIGHT);

		scoreText = new FlxText(0, blurbText.y + 28, 0, "", 32);
		scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);

		scoreBG = new FlxSprite(scoreText.x - scoreText.width, 0).makeGraphic(Std.int(FlxG.width * 0.35), 66, 0xFF000000);
		scoreBG.alpha = 0;
		add(scoreBG);

		diffText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24);
		diffText.alignment = CENTER;
		diffText.font = scoreText.font;
		diffText.x = scoreBG.getGraphicMidpoint().x;
		add(diffText);

		add(scoreText);

		add(blurbText);

		changeSelection();
		changeDiff();

		// FlxG.sound.playMusic(Paths.music('title'), 0);
		// FlxG.sound.music.fadeIn(2, 0, 0.8);
		selector = new FlxText();

		selector.size = 40;
		selector.text = ">";
		// add(selector);
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String, songColor:FlxColor)
	{
		///*
		var coolDifficultyArray = [];
		for (i in CoolUtil.difficultyArray)
			if (FileSystem.exists(Paths.songJson(songName, songName + '-' + i))
				|| (FileSystem.exists(Paths.songJson(songName, songName)) && i == "NORMAL"))
				coolDifficultyArray.push(i);

		if (coolDifficultyArray.length > 0)
		{ //*/
			songs.push(new SongMetadata(songName, weekNum, songCharacter, songColor));
			existingDifficulties.push(coolDifficultyArray);
		}
	}

	public function addWeek(songs:Array<String>, weekNum:Int, ?songCharacters:Array<String>, ?songColor:Array<FlxColor>)
	{
		if (songCharacters == null)
			songCharacters = ['bf'];
		if (songColor == null)
			songColor = [FlxColor.WHITE];

		var num:Array<Int> = [0, 0];
		for (song in songs)
		{
			addSong(song, weekNum, songCharacters[num[0]], songColor[num[1]]);

			if (songCharacters.length != 1)
				num[0]++;
			if (songColor.length != 1)
				num[1]++;
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		FlxTween.color(hologram, 0.35, hologram.color, mainColor);

		var lerpVal = Main.framerateAdjust(0.1);
		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, lerpVal));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;

		var upP = controls.UP_P;
		var downP = controls.DOWN_P;
		var accepted = controls.ACCEPT;

		if (!selectingCategory) {
			grayBox.alpha = 0;

			if (upP)
				changeSelection(-1);
			else if (downP)
				changeSelection(1);

			blurbText.alpha = 1;
			scoreText.alpha = 1;

			if (selectedCategory == 0)
			{
				diffText.alpha = 1;

				if (controls.LEFT_P)
					changeDiff(-1);
				if (controls.RIGHT_P)
					changeDiff(1);
			}
			else
			{
				diffText.alpha = 0;
				curDifficulty = 1;
			}

			if (controls.BACK)
			{
				selectingCategory = true;
			}

			if (accepted)
			{
				var poop:String = Highscore.formatSong(songs[curSelected].songName.toLowerCase(),
					CoolUtil.difficultyArray.indexOf(existingDifficulties[curSelected][curDifficulty]));

				PlayState.SONG = Song.loadFromJson(poop, songs[curSelected].songName.toLowerCase());
				PlayState.isStoryMode = false;
				PlayState.storyDifficulty = curDifficulty;

				PlayState.storyWeek = songs[curSelected].week;
				trace('CUR WEEK' + PlayState.storyWeek);

				if (FlxG.sound.music != null)
					FlxG.sound.music.stop();

				threadActive = false;

				Main.switchState(this, new PlayState());
			}
		}
		else {
			grayBox.alpha = 0.6;

			if (controls.LEFT_P)
				changeCategorySelection(-1);
			if (controls.RIGHT_P)
				changeCategorySelection(1);

			if (controls.BACK)
			{
				threadActive = false;
				Main.switchState(this, new MainMenuState());
			}

			if (accepted)
			{
				selectingCategory = false;
			}
			
			diffText.alpha = 0;
			scoreText.alpha = 0;
			blurbText.alpha = 0;

			var buttonIdx = 0;
			for (item in buttonGroup.members)
			{
				item.color = 0x808080;
				if (buttonIdx == selectedCategory)
				{
					item.color = 0xFFFFFF;
				}
				buttonIdx++;
			}
		}

		// Adhere the position of all the things (I'm sorry it was just so ugly before I had to fix it Shubs)
		var blurb:String = songBlurbs[songs[curSelected].songName.toLowerCase()];
		blurbText.text = '"' + blurb + '"';
		scoreText.text = "PERSONAL BEST:" + lerpScore;

		blurbText.x = FlxG.width - blurbText.width - 80;
		scoreText.x = FlxG.width - scoreText.width - 80;
		diffText.x = FlxG.width - diffText.width - 80;
	}

	var lastDifficulty:String;

	function changeDiff(change:Int = 0)
	{
		curDifficulty += change;
		if (lastDifficulty != null && change != 0)
			while (existingDifficulties[curSelected][curDifficulty] == lastDifficulty)
				curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = existingDifficulties[curSelected].length - 1;
		if (curDifficulty > existingDifficulties[curSelected].length - 1)
			curDifficulty = 0;

		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);

		diffText.text = '< ' + existingDifficulties[curSelected][curDifficulty] + ' >';
		lastDifficulty = existingDifficulties[curSelected][curDifficulty];
	}

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;

		// selector.y = (70 * curSelected) + 30;

		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);

		// set up color stuffs
		mainColor = songs[curSelected].songColor;

		// song switching stuffs

		var bullShit:Int = 0;

		var iconIndex:Int = 0;
		for (icon in iconGroup.members)
		{
			icon.alpha = 0.6;

			if (iconIndex == curSelected)
				icon.alpha = 1;

			if (songs[iconIndex].songName == "egomania")
				icon.alpha = 0.01;

			iconIndex++;
		}

		for (item in grpSongs.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			item.xTo = 120;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.xTo = 160;
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}

			if (item.text == "egomania")
				item.alpha = 0.01;
			
		}
		//

		trace("curSelected: " + curSelected);

		changeDiff();
		
		// was told to remove it so thats what ima dooooooooooooooooooo
		//changeSongPlaying();
	}

	function changeCategorySelection(change:Int = 0)
	{
		selectedCategory += change;

		if (selectedCategory > 2)
			selectedCategory = 0;
		else if (selectedCategory < 0)
			selectedCategory = 2;

		addWeeks();

		curSelected = 0;
		changeSelection();
	}

	function changeSongPlaying()
	{
		if (songThread == null)
		{
			songThread = Thread.create(function()
			{
				while (true)
				{
					if (!threadActive)
					{
						trace("Killing thread");
						return;
					}

					var index:Null<Int> = Thread.readMessage(false);
					if (index != null)
					{
						if (index == curSelected && index != curSongPlaying)
						{
							trace("Loading index " + index);

							var inst:Sound = Sound.fromFile('./' + Paths.inst(songs[curSelected].songName));

							if (index == curSelected && threadActive)
							{
								FlxG.sound.playMusic(inst);

								if (FlxG.sound.music.fadeTween != null)
									FlxG.sound.music.fadeTween.cancel();

								FlxG.sound.music.volume = 0.0;
								FlxG.sound.music.fadeIn(1.0, 0.0, 1.0);

								curSongPlaying = curSelected;
							}
							else
								trace("Nevermind, skipping " + index);
						}
						else
							trace("Skipping " + index);
					}
				}
			});
		}

		songThread.sendMessage(curSelected);
	}

	function addWeeks()
	{
		songs = [];

		///*
		for (i in 0...Main.gameWeeks.length)
		{
			if (selectedCategory == Main.gameWeeks[i][4]) {
				addWeek(Main.gameWeeks[i][0], i, Main.gameWeeks[i][1], Main.gameWeeks[i][2]);
				for (j in cast(Main.gameWeeks[i][0], Array<Dynamic>))
					existingSongs.push(j.toLowerCase());
			}
		}

		// load in all songs that exist in folder
		// for bonus songs (this may be a problem with alt stuff)
		
		var folderSongs:Array<String> = CoolUtil.returnAssetsLibrary('songs', 'assets');

		// hardcoding egomania secret because im tired,
		// a little bit of programming - codist
		var egoIsReal = false;

		if (selectedCategory == 2) {

			for (i in folderSongs)
			{
				if (!existingSongs.contains(i.toLowerCase()))
				{
					var icon:String = 'gf';
					var chartExists:Bool = FileSystem.exists(Paths.songJson(i, i));

					if (chartExists)
					{
						var castSong:SwagSong = Song.loadFromJson(i, i);

						if (castSong.song == "Egomania") {
							egoIsReal = true;
							continue;
						}

						icon = (castSong != null) ? castSong.player2 : 'gf';
						addSong(CoolUtil.spaceToDash(castSong.song), 1, icon, FlxColor.WHITE);
					}
				}
			}
		
		}

		if (egoIsReal)
			addSong("egomania", 1, "hagomizer", FlxColor.WHITE);

		grpSongs.clear();
		iconGroup.clear();

		for (i in 0...songs.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, songs[i].songName, true, false);
			songText.isMenuItem = true;
			songText.disableX = true;
			songText.targetY = i;
			grpSongs.add(songText);

			var icon:HealthIcon = new HealthIcon(songs[i].songCharacter);
			icon.sprTracker = songText;

			// using a FlxGroup is too much fuss!
			// haha not anymore
			iconGroup.add(icon);

			songText.ySpacing = 100;
			songText.yOffset = 60;

			// songText.x += 40;
			// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
			// songText.screenCenter(X);
		}
	}

	var playingSongs:Array<FlxSound> = [];
}

class SongMetadata
{
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";
	public var songColor:FlxColor = FlxColor.WHITE;

	public function new(song:String, week:Int, songCharacter:String, songColor:FlxColor)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
		this.songColor = songColor;
	}
}
