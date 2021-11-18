package gameFolder.meta.state.menus;

// modified code from psych engine, credits to shadow mario lol!

import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import lime.utils.Assets;
import gameFolder.meta.MusicBeat.MusicBeatState;
import gameFolder.meta.data.font.Alphabet;
import gameFolder.meta.data.dependency.AttachedSprite;

using StringTools;

class CreditsState extends MusicBeatState
{
	var curSelected:Int = 1;

	private var grpOptions:FlxTypedGroup<Alphabet>;
	private var iconArray:Array<AttachedSprite> = [];
	private var creditsStuff:Array<Dynamic> = [];

	var bg:FlxSprite;
	var descText:FlxText;

	override function create()
	{
		super.create();
		
		bg = new FlxSprite().loadGraphic(Paths.image('menus/base/menuDesat'));
		bg.color = 0xCE64DF;
		add(bg);

		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);

		// should be updated with the actual team later
		var pisspoop = [ //Name - Icon name - Description - Link
			['Active dev team'],
			['HThagomizer',		    'hagomizer',		    'Project lead, artist, animator, programmer',	'https://twitter.com/HThagomizer'],
			['Simply EJ',		    'ej',		    		'Artist, composer',								''],
			['SaltySkkulls',		'salty',		    	'Artist, composer',								''],
			['LuckiiBean',		    'luckii',		    	'Composer',										''],
			['KrystalPhantasm',		'krystal',		    	'Artist, composer',								''],
			['Begwhi02',		    'begwhi',		    	'Composer',										''],
			['Zavemann',		    'zavemann',		    	'Composer, concept art',						''],
			['Zack the Nerd',		'zack',		    		'Artist, animator',								''],
			['FreshWoomy',		    'fresh',		    	'Artist, animator',								''],
			['Baqly',		    	'baqly',		    	'Menu artist, promo art',						''],
			['Yoshubs',		    	'yoshubs',		    	'Forever Engine, programmer',					''],
			['SuperMakerPlayer',	'maker',		    	'Programmer',									'https://twitter.com/SuperMakerPlaye/'],
			['codist',		    	'codist',		    	'Programmer',									''],
			[''],
			["Previous devs"],
			['kevenandsoki',		'',		    			'Composer',										''],
			['Commander Cello',		'',		    			'Composer',										''],
			['Bryanjo97527502',		'',		    			'Composer',										'https://twitter.com/bryanjo97527502'],
			['Lolman',				'',		   				'Composer',										''],
			[''],
			["Contributors"],
			['HeavenArtist2006',	'',		    			'Icons',										'https://gamebanana.com/members/1725165'],
			['Junkgle',				'',		    			'Concept artist',								''],
			['Crow at a Computer',	'',		    			'Concept artist',								''],
			['IronB',				'',		   				'3.0 trailer editor',							''],
			[''],
			["Special thanks"],
			['spaghettitron',		'',		    			'Beta tester, cool guy',						''],
			['BestrJestr',		'',		    				'Eta',											''],
			[''],
			["Funkin' crew"],
			['ninjamuffin99',		'',						"Programmer of Friday Night Funkin'",			'https://twitter.com/ninja_muffin99'],
			['PhantomArcade',		'',						"Animator of Friday Night Funkin'",				'https://twitter.com/PhantomArcade3K'],
			['evilsk8r',			'',						"Artist of Friday Night Funkin'",				'https://twitter.com/evilsk8r'],
			['kawaisprite',			'',						"Composer of Friday Night Funkin'",				'https://twitter.com/kawaisprite']
		];
		
		for(i in pisspoop){
			creditsStuff.push(i);
		}
	
		for (i in 0...creditsStuff.length)
		{
			var isSelectable:Bool = !unselectableCheck(i);
			var optionText:Alphabet = new Alphabet(0, 70 * i, creditsStuff[i][0], !isSelectable, false);
			optionText.isMenuItem = true;
			optionText.screenCenter(X);
			if(isSelectable) {
				optionText.x -= 70;
			}
			//optionText.xTo = Std.int(optionText.x);
			//optionText.yMult = 90;
			optionText.targetY = i;
			grpOptions.add(optionText);

			if(isSelectable && (creditsStuff[i][1] != '')) {
				var icon:AttachedSprite = new AttachedSprite('credits/' + creditsStuff[i][1]);
				icon.xAdd = optionText.width + 10;
				icon.sprTracker = optionText;
	
				// using a FlxGroup is too much fuss!
				iconArray.push(icon);
				add(icon);
			}
		}

		descText = new FlxText(50, 600, 1180, "", 32);
		descText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		descText.scrollFactor.set();
		descText.borderSize = 2.4;
		add(descText);

		changeSelection();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		var upP = controls.UP_P;
		var downP = controls.DOWN_P;

		if (upP)
		{
			changeSelection(-1);
		}
		if (downP)
		{
			changeSelection(1);
		}

		if (controls.BACK)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			Main.switchState(this, new MainMenuState());
		}
		if(controls.ACCEPT && (creditsStuff[curSelected][3] != '')) {
			CoolUtil.browserLoad(creditsStuff[curSelected][3]);
		}
	}

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		do {
			curSelected += change;
			if (curSelected < 0)
				curSelected = creditsStuff.length - 1;
			if (curSelected >= creditsStuff.length)
				curSelected = 0;
		} while(unselectableCheck(curSelected));

		var bullShit:Int = 0;

		for (item in grpOptions.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			if(!unselectableCheck(bullShit-1)) {
				item.alpha = 0.6;
				if (item.targetY == 0) {
					item.alpha = 1;
				}
			}
		}
		descText.text = creditsStuff[curSelected][2];
	}

	private function unselectableCheck(num:Int):Bool {
		return creditsStuff[num].length <= 1;
	}
}