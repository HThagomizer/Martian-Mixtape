package gameFolder.gameObjects;

/**
	The character class initialises any and all characters that exist within gameplay. For now, the character class will
	stay the same as it was in the original source of the game. I'll most likely make some changes afterwards though!
**/
import flixel.FlxG;
import flixel.addons.util.FlxSimplex;
import flixel.animation.FlxBaseAnimation;
import flixel.graphics.frames.FlxAtlasFrames;
import gameFolder.meta.*;
import gameFolder.meta.data.*;
import gameFolder.meta.data.dependency.FNFSprite;
import gameFolder.meta.state.PlayState;
import openfl.utils.Assets as OpenFlAssets;

using StringTools;

class Character extends FNFSprite
{
	// By default, this option set to FALSE will make it so that the character only dances twice per major beat hit
	// If set to on, they will dance every beat, such as Skid and Pump
	public var quickDancer:Bool = false;

	public var debugMode:Bool = false;

	public var isPlayer:Bool = false;
	public var curCharacter:String = 'bf';

	public var holdTimer:Float = 0;

	public function new(x:Float, y:Float, ?character:String = "bf", ?isPlayer:Bool = false)
	{
		super(x, y);

		curCharacter = character;
		this.isPlayer = isPlayer;

		antialiasing = (!Init.trueSettings.get('Disable Antialiasing'));

		generateCharacter(x, y, curCharacter);

		if (isPlayer) // fuck you ninjamuffin lmao
		{
			flipX = !flipX;

			// Doesn't flip for BF, since his are already in the right place???
			if (!curCharacter.startsWith('bf'))
				flipLeftRight();
			//
		}
		else if (curCharacter.startsWith('bf'))
			flipLeftRight();
	}

	public function generateCharacter(x, y, curCharacter)
	{
		var tex:FlxAtlasFrames;

		this.x = x;
		this.y = y;

		switch (curCharacter)
		{
			case 'gf':
				// GIRLFRIEND CODE
				tex = Paths.getSparrowAtlas('characters/GF_assets');
				frames = tex;
				animation.addByPrefix('cheer', 'GF Cheer', 24, false);
				animation.addByPrefix('singLEFT', 'GF left note', 24, false);
				animation.addByPrefix('singRIGHT', 'GF Right Note', 24, false);
				animation.addByPrefix('singUP', 'GF Up Note', 24, false);
				animation.addByPrefix('singDOWN', 'GF Down Note', 24, false);
				animation.addByIndices('sad', 'gf sad', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "", 24, false);
				animation.addByIndices('danceLeft', 'GF Dancing Beat', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'GF Dancing Beat', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
				animation.addByIndices('hairBlow', "GF Dancing Beat Hair blowing", [0, 1, 2, 3], "", 24);
				animation.addByIndices('hairFall', "GF Dancing Beat Hair Landing", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11], "", 24, false);
				animation.addByPrefix('scared', 'GF FEAR', 24);

				playAnim('danceRight');
			case 'gf-speakerless':
				// GIRLFRIEND CODE
				tex = Paths.getSparrowAtlas('characters/speakerless_gf');
				frames = tex;
				animation.addByIndices('singUP', 'GF Dancing Beat Hair blowing', [0], "", 24, false);
				animation.addByIndices('danceLeft', 'GF Dancing Beat Hair blowing', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'GF Dancing Beat Hair blowing', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24,
					false);

				playAnim('danceRight');
			case 'gf-ufo':
				// GIRLFRIEND CODE
				tex = Paths.getSparrowAtlas('characters/UFO/ufoGF_assets');
				frames = tex;
				animation.addByPrefix('cheer', 'GF Cheer', 24, false);
				animation.addByIndices('sad', 'gf sad', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "", 24, false);
				animation.addByIndices('danceLeft', 'GF Dancing Beat', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'GF Dancing Beat', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);

				addOffset('cheer');
				addOffset('sad', 0, -25);
				addOffset('danceLeft', 0, -9);
				addOffset('danceRight', 0, -9);

				playAnim('danceRight');
			
			case 'gf-hominid':
				tex = Paths.getSparrowAtlas('characters/hominid/alien_hominid');
				frames = tex;
				animation.addByPrefix('land', 'GF_HominidLand', 24, false);
				animation.addByIndices('sad', 'gf sad', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "", 24, false);
				animation.addByIndices('danceLeft', 'GF Dancing Beat', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'GF Dancing Beat', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);

				addOffset('land', 0, 237);
				addOffset('sad', -4, -11);
				addOffset('danceLeft');
				addOffset('danceRight');

				playAnim('danceRight');

			case 'gf-ufo-flying':
				tex = Paths.getSparrowAtlas('characters/UFO/GF_ass_sets');
				frames = tex;
				animation.addByIndices('singUP', 'GF Dancing Beat Hair blowing CAR', [0], "", 24, false);
				animation.addByIndices('danceLeft', 'GF Dancing Beat Hair blowing CAR', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'GF Dancing Beat Hair blowing CAR', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24,
					false);

				addOffset('danceLeft', 0);
				addOffset('danceRight', 0);

				playAnim('danceRight');

			case 'gf-tombstone':
				tex = Paths.getSparrowAtlas('characters/tombstoneGF/gf-tombstone');
				frames = tex;
				animation.addByPrefix('cheer', 'GF Cheer', 24, false);
				animation.addByPrefix('singLEFT', 'GF left note', 24, false);
				animation.addByPrefix('singRIGHT', 'GF Right Note', 24, false);
				animation.addByPrefix('singUP', 'GF Up Note', 24, false);
				animation.addByPrefix('singDOWN', 'GF Down Note', 24, false);
				animation.addByIndices('sad', 'gf sad', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "", 24, false);
				animation.addByIndices('danceLeft', 'GF Dancing Beat', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'GF Dancing Beat', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
				animation.addByIndices('hairBlow', "GF Dancing Beat Hair blowing", [0, 1, 2, 3], "", 24);
				animation.addByIndices('hairFall', "GF Dancing Beat Hair Landing", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11], "", 24, false);
				animation.addByPrefix('scared', 'GF FEAR', 24);

				addOffset('cheer', 0, 20);
				addOffset('sad', -2, -2);
				addOffset('danceLeft', 0, -9);
				addOffset('danceRight', 0, -9);

				addOffset("singUP", 0, 4);
				addOffset("singRIGHT", 0, -20);
				addOffset("singLEFT", 0, -19);
				addOffset("singDOWN", 0, -20);
				addOffset('hairBlow', 45, -8);
				addOffset('hairFall', 0, -9);

				addOffset('scared', -2, -17);

				playAnim('danceRight');

			case 'gf-xigman':
				tex = Paths.getSparrowAtlas('characters/xigman gf/background gf xigman');
				frames = tex;
				animation.addByPrefix('cheer', 'xigman cheer', 24, false);
				animation.addByIndices('sad', 'xigman cry', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "", 24, false);
				animation.addByIndices('danceLeft', 'xigman dancing beat', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'xigman dancing beat', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);

				addOffset('cheer', -15, -15);
				addOffset('sad', -21, -7);
				addOffset('danceLeft');
				addOffset('danceRight');

				playAnim('danceRight');

			case 'gf-fbi':
				tex = Paths.getSparrowAtlas('characters/fbi gf/background gf fbi');
				frames = tex;
				animation.addByPrefix('cheer', 'fbi cheer', 24, false);
				animation.addByIndices('sad', 'fbi cry', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "", 24, false);
				animation.addByIndices('danceLeft', 'fbi dancing beat', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'fbi dancing beat', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);

				addOffset('cheer');
				addOffset('sad', 0, -7);
				addOffset('danceLeft');
				addOffset('danceRight');

				playAnim('danceRight');
			case 'gf-gold':
				// GIRLFRIEND CODE
				tex = Paths.getSparrowAtlas('characters/secret character/the gold hank');
				frames = tex;
				animation.addByIndices('sad', 'gf sad', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "", 24, false);
				animation.addByIndices('danceLeft', 'GF Dancing Beat', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'GF Dancing Beat', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);

				addOffset('sad');
				addOffset('danceLeft');
				addOffset('danceRight');

				playAnim('danceRight');
			case 'dad':
				// DAD ANIMATION LOADING CODE
				tex = Paths.getSparrowAtlas('characters/DADDY_DEAREST');
				frames = tex;
				animation.addByPrefix('idle', 'Dad idle dance', 30, false);
				animation.addByPrefix('singUP', 'Dad Sing Note UP', 24);
				animation.addByPrefix('singRIGHT', 'Dad Sing Note RIGHT', 24);
				animation.addByPrefix('singDOWN', 'Dad Sing Note DOWN', 24);
				animation.addByPrefix('singLEFT', 'Dad Sing Note LEFT', 24);

				playAnim('idle');

			case 'bf':
				frames = Paths.getSparrowAtlas('characters/BOYFRIEND');

				animation.addByPrefix('idle', 'BF idle dance', 24, false);
				animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
				animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
				animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
				animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
				animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
				animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
				animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);
				animation.addByPrefix('hey', 'BF HEY', 24, false);
				animation.addByPrefix('scared', 'BF idle shaking', 24);

				playAnim('idle');

				flipX = true;

			case 'bf-car':
				var tex = Paths.getSparrowAtlas('characters/bfCar');
				frames = tex;
				animation.addByPrefix('idle', 'BF idle dance', 24);
				animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
				animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
				animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
				animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
				animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
				animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
				animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);

				addOffset('idle', -5);
				addOffset("singUP", -29, 27);
				addOffset("singRIGHT", -38, -7);
				addOffset("singLEFT", 12, -6);
				addOffset("singDOWN", -10, -50);
				addOffset("singUPmiss", -29, 27);
				addOffset("singRIGHTmiss", -30, 21);
				addOffset("singLEFTmiss", 12, 24);
				addOffset("singDOWNmiss", -11, -19);

				playAnim('idle');

				flipX = true;

			case 'bf-hominid':
				var tex = Paths.getSparrowAtlas('characters/bfHominid/bfHominid');
				frames = tex;
				animation.addByPrefix('idle', 'BF idle dance', 24, false);
				animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
				animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
				animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
				animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
				animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
				animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
				animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);
				animation.addByPrefix('hey', 'BF HEY', 24, false);

				animation.addByPrefix('firstDeath', "BF dies", 24, false);
				animation.addByPrefix('deathLoop', "BF Dead Loop", 24, true);
				animation.addByPrefix('deathConfirm', "BF Dead confirm", 24, false);

				animation.addByPrefix('scared', 'BF idle shaking', 24);

				addOffset('idle', -5);
				addOffset("singUP", -29, 27);
				addOffset("singRIGHT", -38, -7);
				addOffset("singLEFT", 12, -6);
				addOffset("singDOWN", -10, -50);
				addOffset("singUPmiss", -29, 27);
				addOffset("singRIGHTmiss", -30, 21);
				addOffset("singLEFTmiss", 12, 24);
				addOffset("singDOWNmiss", -11, -19);
				addOffset("hey", 7, 4);
				addOffset('firstDeath', 37, 11);
				addOffset('deathLoop', 37, 5);
				addOffset('deathConfirm', 37, 69);
				addOffset('scared', -4);

				playAnim('idle');

				flipX = true;

			case 'bf-dead':
				frames = Paths.getSparrowAtlas('characters/BF_DEATH');

				animation.addByPrefix('firstDeath', "BF dies", 24, false);
				animation.addByPrefix('deathLoop', "BF Dead Loop", 24, true);
				animation.addByPrefix('deathConfirm', "BF Dead confirm", 24, false);

				playAnim('firstDeath');

				flipX = true;

			case 'alien':
				tex = Paths.getSparrowAtlas('characters/xigmund/alien_assets');
				frames = tex;
				animation.addByPrefix('idle', 'xigidle', 24);
				animation.addByPrefix('singUP', 'xigup', 24, false);
				animation.addByPrefix('singRIGHT', 'xigright', 24, false);
				animation.addByPrefix('singDOWN', 'xigdown', 24);
				animation.addByPrefix('singLEFT', 'xigleft', 24, false);

				animation.addByPrefix('OUCH', 'xigOUCH', 24);
				animation.addByPrefix('psychic', 'xigpsiionic', 24);

				addOffset('idle');
				addOffset("singUP", -6, 14);
				addOffset("singRIGHT", 0, 8);
				addOffset("singLEFT", 0, 0);
				addOffset("singDOWN", 29, -62);
				addOffset("OUCH", 65, -74);
				addOffset("psychic", -5, 0);

				playAnim('idle');

			case 'alien-alt':
				tex = Paths.getSparrowAtlas('characters/xigmund/alt_alien_assets');
				frames = tex;
				animation.addByPrefix('idle', 'xigidle', 24);
				animation.addByPrefix('singUP', 'xigup', 24, false);
				animation.addByPrefix('singRIGHT', 'xigright', 24, false);
				animation.addByPrefix('singDOWN', 'xigdown', 24);
				animation.addByPrefix('singLEFT', 'xigleft', 24, false);

				addOffset('idle');
				addOffset("singUP", -6, 14);
				addOffset("singRIGHT", 0, 8);
				addOffset("singLEFT", 0, 0);
				addOffset("singDOWN", 29, -62);

				playAnim('idle');

			case 'alien-pissed':
				tex = Paths.getSparrowAtlas('characters/xigmund/alienpissed_assets');
				frames = tex;
				animation.addByPrefix('idle', 'pissedidle', 24);
				animation.addByPrefix('singUP', 'pissedup', 24, false);
				animation.addByPrefix('singRIGHT', 'pissedright', 24, false);
				animation.addByPrefix('singDOWN', 'pisseddown', 24);
				animation.addByPrefix('singLEFT', 'pissedleft', 24, false);

				animation.addByPrefix('charging', 'charging', 24, false);

				addOffset('idle');
				addOffset("singUP", -6, 2);
				addOffset("singRIGHT", 0, -50);
				addOffset("singLEFT", 10, 10);
				addOffset("singDOWN", 29, -85);
				addOffset("takeoff", 0, 0);

				playAnim('idle');

			case 'alien-psychic':
				// XIG ANIMATION LOADING CODE
				tex = Paths.getSparrowAtlas('characters/xigmund/alienpsychic_assets');
				frames = tex;
				animation.addByPrefix('idle', 'INSANEidle', 24);
				animation.addByPrefix('singUP', 'INSANEup', 24);
				animation.addByPrefix('singRIGHT', 'INSANEright', 24);
				animation.addByPrefix('singDOWN', 'INSANEdown', 24);
				animation.addByPrefix('singLEFT', 'INSANEleft', 24);

				animation.addByPrefix('singUPmiss', 'INSANEmissup', 24, false);
				animation.addByPrefix('singDOWNmiss', 'INSANEmissdown', 24, false);
				animation.addByPrefix('singLEFTmiss', 'INSANEmissleft', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'INSANEmissright', 24, false);

				animation.addByPrefix('xigdeath', "INSANEdead", 24, false);

				addOffset("singUPmiss", -11, 63);
				addOffset("singRIGHTmiss", 40, -30);
				addOffset("singLEFTmiss", 40, -31);
				addOffset("singDOWNmiss", 2, -37);
				addOffset('idle');
				addOffset('xigdeath', 0, 0);
				addOffset("singUP", -11, 63);
				addOffset("singRIGHT", 40, -30);
				addOffset("singLEFT", 40, -31);
				addOffset("singDOWN", 2, -37);

				playAnim('idle');

			case 'alien-rude':
				tex = Paths.getSparrowAtlas('characters/xigmund/alienrude_assets');
				frames = tex;
				animation.addByPrefix('idle', 'xigmund idle', 24);
				animation.addByPrefix('singUP', 'xigmund singUP', 24, false);
				animation.addByPrefix('singRIGHT', 'xigmund singRIGHT', 24, false);
				animation.addByPrefix('singDOWN', 'xigmund singDOWN', 24);
				animation.addByPrefix('singLEFT', 'xigmund singLEFT', 24, false);

				animation.addByPrefix('fuck', 'xigmund alt singDOWN', 24);
				animation.addByPrefix('pain', 'xigmund pain', 24);

				addOffset('idle');
				addOffset("singUP");
				addOffset("singRIGHT", 0, -6);
				addOffset("singLEFT", 33, -5);
				addOffset("singDOWN", 55, -55);

				addOffset("fuck", -4, -58);
				addOffset("pain", 53, -75);

				playAnim('idle');

			case 'alien-ouch':
				tex = Paths.getSparrowAtlas('characters/xigmund/alienouch_assets');
				frames = tex;
				animation.addByPrefix('idle', 'xigmouch idle', 24);
				animation.addByPrefix('singUP', 'xigmouch up', 24, false);
				animation.addByPrefix('singRIGHT', 'xigmouch Right', 24, false);
				animation.addByPrefix('singDOWN', 'xigmouch down', 24);
				animation.addByPrefix('singLEFT', 'xigmouch left', 24, false);

				animation.addByPrefix('charging', 'xigmouch charge', 24, false);

				addOffset('idle');
				addOffset("singUP", 45, -46);
				addOffset("singRIGHT", -9, -144);
				addOffset("singLEFT", 120, -216);
				addOffset("singDOWN", 68, -230);

				addOffset("charge", 38, -26);

				playAnim('idle');

			case 'alien-power':
				tex = Paths.getSparrowAtlas('characters/xigmund/alienpower_assets');
				frames = tex;
				animation.addByPrefix('idle', 'xiggod idle', 24);
				animation.addByPrefix('singUP', 'xiggod up', 24, false);
				animation.addByPrefix('singRIGHT', 'xiggod right', 24, false);
				animation.addByPrefix('singDOWN', 'xiggod down', 24);
				animation.addByPrefix('singLEFT', 'xiggod left', 24, false);
				animation.addByPrefix('death', 'xiggod FUCKING DIES', 24, false);

				addOffset('idle');
				addOffset("singUP");
				addOffset("singRIGHT");
				addOffset("singLEFT");
				addOffset("singDOWN");
				addOffset("death", 29, 58);

				playAnim('idle');

			case 'alien-air':
				frames = Paths.getSparrowAtlas('characters/xigmund/alienair_assets');
				animation.addByPrefix('idle', 'AeroIdle', 24, false);
				animation.addByPrefix('singUP', 'AeroUp', 24);
				animation.addByPrefix('singDOWN', 'AeroDown', 24);
				animation.addByPrefix('singLEFT', 'AeroLeft', 24);
				animation.addByPrefix('singRIGHT', 'AeroRight', 24);
				animation.addByPrefix('shoot', 'AeroShoot', 24);

				addOffset('idle');
				addOffset("singUP", 0, 36);
				addOffset("singRIGHT", -16, 5);
				addOffset("singLEFT", 44);
				addOffset("singDOWN", 5, -16);
				addOffset('shoot', -119, 3);

				playAnim('idle');

			case 'bones':
				tex = Paths.getSparrowAtlas('characters/bones/own_bones');
				frames = tex;
				animation.addByPrefix('idle', 'idle', 24);
				animation.addByPrefix('singUP', 'singUP', 24);
				animation.addByPrefix('singRIGHT', 'singRIGHT', 24);
				animation.addByPrefix('singDOWN', 'singDOWN', 24, false);
				animation.addByPrefix('singLEFT', 'singLEFT', 24);

				addOffset('idle');
				addOffset("singUP", 34, 9);
				addOffset("singRIGHT", 8, -8);
				addOffset("singLEFT", 36, 41);
				addOffset("singDOWN", 18, -57);

				playAnim('idle');
			case 'bones-cool':
				tex = Paths.getSparrowAtlas('characters/bones/cool_bones');
				frames = tex;
				animation.addByPrefix('idle', 'idle cool', 24);
				animation.addByPrefix('singUP', 'cool singUP', 24);
				animation.addByPrefix('singRIGHT', 'cool singRIGHT', 24);
				animation.addByPrefix('singDOWN', 'cool singDOWN', 24, false);
				animation.addByPrefix('singLEFT', 'cool singLEFT', 24);

				addOffset('idle');
				addOffset("singUP", 4, 9);
				addOffset("singRIGHT", 28, 2);
				addOffset("singLEFT", 26, 2);
				addOffset("singDOWN", -14, -17);

				playAnim('idle');
			case 'bones-spectral':
				tex = Paths.getSparrowAtlas('characters/bones/spectral_bones');
				frames = tex;
				animation.addByPrefix('idle', 'idle', 24);
				animation.addByPrefix('singUP', 'singUP spectral', 24);
				animation.addByPrefix('singRIGHT', 'singRIGHT spectral', 24);
				animation.addByPrefix('singDOWN', 'singDOWN spectral', 24, false);
				animation.addByPrefix('singLEFT', 'singLEFT spectral', 24);

				addOffset('idle');
				addOffset("singUP", 24, -21);
				addOffset("singRIGHT", -2, 12);
				addOffset("singLEFT", 66, 12);
				addOffset("singDOWN", 6, -87);

				playAnim('idle');
			case 'harold':
				tex = Paths.getSparrowAtlas('characters/harold/harold');
				frames = tex;
				animation.addByPrefix('idle', 'idle', 24);
				animation.addByPrefix('singUP', 'singUP', 24);
				animation.addByPrefix('singRIGHT', 'singRIGHT', 24);
				animation.addByPrefix('singDOWN', 'singDOWN', 24);
				animation.addByPrefix('singLEFT', 'singLEFT', 24);
				animation.addByPrefix('singDOWN-alt', 'ach', 24, false);
				animation.addByPrefix('swig', 'swig', 24, false);
				animation.addByPrefix('short swig', 'short swig', 24, false);

				addOffset('idle');
				addOffset("singUP", -6, 50);
				addOffset("singRIGHT", -5, 7);
				addOffset("singLEFT", 49, 3);
				addOffset("singDOWN", -4, -22);
				addOffset('singDOWN-alt', 2, 5);
				addOffset('swig', 2, 5);

				playAnim('idle');
			case 'harold-caffeinated':
				tex = Paths.getSparrowAtlas('characters/harold/harold');
				frames = tex;
				animation.addByPrefix('idle', 'twitchy idle', 24);
				animation.addByPrefix('singUP', 'twitchy singUP', 24);
				animation.addByPrefix('singRIGHT', 'twitchy singRIGHT', 24);
				animation.addByPrefix('singDOWN', 'twitchy singDOWN', 24);
				animation.addByPrefix('singLEFT', 'twitchy singLEFT', 24);
				animation.addByPrefix('swig', 'twitchy swig', 24, false);
				animation.addByPrefix('singUP-alt', 'alt twitchy singUP', 24, false);
				animation.addByPrefix('singDOWN-alt', 'alt twitchy singDOWN', 24, false);
				animation.addByPrefix('singLEFT-alt', 'alt twitchy singLEFT', 24, false);
				animation.addByPrefix('singRIGHT-alt', 'alt twitchy singRIGHT', 24, false);

				addOffset('idle');
				addOffset("singUP", 14, 40);
				addOffset("singRIGHT", -5, -23);
				addOffset("singLEFT", 39, -7);
				addOffset("singDOWN", 26, -22);
				addOffset("singUP-alt", 14, 40);
				addOffset("singRIGHT-alt", -5, -23);
				addOffset("singLEFT-alt", 39, -7);
				addOffset("singDOWN-alt", 26, -22);
				addOffset('swig', 2, 5);

				playAnim('idle');
			case 'FBI':
				frames = Paths.getSparrowAtlas('characters/FBI/FBI');
				animation.addByPrefix('idle', 'grunt idle', 24, false);
				animation.addByPrefix('singUP', 'grunt singUP', 24, false);
				animation.addByPrefix('singDOWN', 'grunt singDOWN', 24, false);
				animation.addByPrefix('singLEFT', 'grunt singLEFT', 24, false);
				animation.addByPrefix('singRIGHT', 'grunt singRIGHT', 24, false);
				animation.addByPrefix('singUP-alt', 'grunt alt singUP', 24, false);
				animation.addByPrefix('singDOWN-alt', 'grunt alt singDOWN', 24, false);
				animation.addByPrefix('singLEFT-alt', 'grunt alt singLEFT', 24, false);
				animation.addByPrefix('singRIGHT-alt', 'grunt alt singRIGHT', 24, false);

				addOffset('idle');
				addOffset("singUP", -25, 58);
				addOffset("singRIGHT", -31, -3);
				addOffset("singLEFT", 61, 21);
				addOffset("singDOWN", -31, -99);
				addOffset("singUP-alt", -37, 59);
				addOffset("singRIGHT-alt", -24, -3);
				addOffset("singLEFT-alt", 70, 24);
				addOffset("singDOWN-alt", 12, -93);

				playAnim('idle');
			case 'FBIbodyguard':
				frames = Paths.getSparrowAtlas('characters/FBI/FBIbodyguard');
				animation.addByPrefix('idle', 'bodyguard idle', 24, false);
				animation.addByPrefix('singUP', 'bodyguard singUP', 24, false);
				animation.addByPrefix('singDOWN', 'bodyguard singDOWN', 24, false);
				animation.addByPrefix('singLEFT', 'bodyguard singLEFT', 24, false);
				animation.addByPrefix('singRIGHT', 'bodyguard singRIGHT', 24, false);

				addOffset('idle');
				addOffset("singUP", -125, 78);
				addOffset("singRIGHT", -31, 17);
				addOffset("singLEFT", 51, 21);
				addOffset("singDOWN", -111, -69);

				playAnim('idle');
			case 'FBIhacker':
				frames = Paths.getSparrowAtlas('characters/FBI/FBIhacker');
				animation.addByPrefix('idle', 'hacker idle', 24, false);
				animation.addByPrefix('singUP', 'hacker singUP', 24, false);
				animation.addByPrefix('singDOWN', 'hacker singDOWN', 24, false);
				animation.addByPrefix('singLEFT', 'hacker singLEFT', 24, false);
				animation.addByPrefix('singRIGHT', 'hacker singRIGHT', 24, false);
				animation.addByPrefix('woh', 'hacker woh', 24, false);

				addOffset('idle');
				addOffset("singUP", -76, 34);
				addOffset("singRIGHT", -36, -13);
				addOffset("singLEFT", -35, -12);
				addOffset("singDOWN", -20, -16);
				addOffset('woh');

				playAnim('idle');
			case 'FBImech':
				frames = Paths.getSparrowAtlas('characters/FBI/FBImech');
				animation.addByPrefix('idle', 'idle', 24, false);
				animation.addByPrefix('singUP', 'singUP', 24, false);
				animation.addByPrefix('singDOWN', 'singDOWN', 24, false);
				animation.addByPrefix('singLEFT', 'singLEFT', 24, false);
				animation.addByPrefix('singRIGHT', 'singRIGHT', 24, false);

				addOffset('idle');
				addOffset("singUP", 84, 140);
				addOffset("singRIGHT", -74, 9);
				addOffset("singLEFT", -109, 13);
				addOffset("singDOWN", -123, -29);

				playAnim('idle');

				setGraphicSize(Std.int(width * 3));
				updateHitbox();
			case 'xigman':
				frames = Paths.getSparrowAtlas('characters/xigman/XIGMAN');
				animation.addByPrefix('idle', 'idle', 24, false);
				animation.addByPrefix('singUP', 'singUP', 24);
				animation.addByPrefix('singDOWN', 'singDOWN', 24);
				animation.addByPrefix('singLEFT', 'singLEFT', 24);
				animation.addByPrefix('singRIGHT', 'singRIGHT', 24);

				addOffset('idle');
				addOffset("singUP", -62, 115);
				addOffset("singRIGHT", 29, -53);
				addOffset("singLEFT", -9, 21);
				addOffset("singDOWN", 19, -89);

				playAnim('idle');
			case 'mooninites':
				tex = Paths.getSparrowAtlas('characters/mooninites/mooninites');
				frames = tex;
				animation.addByPrefix('idle', 'duo IDLE', 24);
				animation.addByPrefix('singUP', 'duo ignignokt singUP', 24);
				animation.addByPrefix('singRIGHT', 'duo ignignokt singRIGHT', 24);
				animation.addByPrefix('singDOWN', 'duo ignignokt singDOWN', 24);
				animation.addByPrefix('singLEFT', 'duo ignignokt singLEFT', 24);
				
				animation.addByPrefix('singUP-alt', 'duo err singUP', 24, false);
				animation.addByPrefix('singDOWN-alt', 'duo err singDOWN', 24, false);
				animation.addByPrefix('singLEFT-alt', 'duo err singLEFT', 24, false);
				animation.addByPrefix('singRIGHT-alt', 'duo err singRIGHT', 24, false);

				addOffset('idle');
				addOffset("singUP", 0, 14);
				addOffset("singRIGHT", -9, 0);
				addOffset("singLEFT", 8, 0);
				addOffset("singDOWN", 0, -13);

				addOffset("singUP-alt");
				addOffset("singRIGHT-alt");
				addOffset("singLEFT-alt");
				addOffset("singDOWN-alt");

				playAnim('idle');

				antialiasing = false;
			case 'hagomizer':
				tex = Paths.getSparrowAtlas('characters/secret character/hank');
				frames = tex;
				animation.addByPrefix('idle', 'hank idle', 24);
				animation.addByPrefix('singUP', 'hank singUP', 24);
				animation.addByPrefix('singRIGHT', 'hank singRIGHT', 24);
				animation.addByPrefix('singDOWN', 'hank singDOWN', 24);
				animation.addByPrefix('singLEFT', 'hank singLEFT', 24);
				animation.addByPrefix('cough', 'hank cough', 24);
				animation.addByPrefix('puppet', 'hank gain puppet', 24);

				addOffset('idle');
				addOffset("singUP", 88, 32);
				addOffset("singRIGHT", -5, 6);
				addOffset("singLEFT", 68, 20);
				addOffset("singDOWN", 19, -150);
				addOffset("cough", -12, -9);
				addOffset("puppet", 8, 18);

				playAnim('idle');
			case 'hagomizer-puppet':
				tex = Paths.getSparrowAtlas('characters/secret character/hank');
				frames = tex;
				animation.addByPrefix('idle', 'hank puppet idle', 24);
				animation.addByPrefix('singUP', 'hank puppet singUP', 24);
				animation.addByPrefix('singRIGHT', 'hank puppet singRIGHT', 24);
				animation.addByPrefix('singDOWN', 'hank puppet singDOWN', 24);
				animation.addByPrefix('singLEFT', 'hank puppet singLEFT', 24);

				addOffset('idle');
				addOffset("singUP", -29, 48);
				addOffset("singRIGHT", -24, -3);
				addOffset("singLEFT", -27, 12);
				addOffset("singDOWN", -24, -20);

				playAnim('idle');
			case 'hagomizer-rage':
				tex = Paths.getSparrowAtlas('characters/secret character/hank-RAGE');
				frames = tex;
				animation.addByPrefix('idle', 'hank RAGE idle', 24);
				animation.addByPrefix('singUP', 'hank RAGE singUP', 24);
				animation.addByPrefix('singRIGHT', 'hank RAGE singRIGHT', 24);
				animation.addByPrefix('singDOWN', 'hank RAGE singDOWN', 24);
				animation.addByPrefix('singLEFT', 'hank RAGE singLEFT', 24);
				animation.addByPrefix('rage', 'hank BECOME RAGE', 24, false);

				addOffset('idle');
				addOffset("singUP", 136, 71);
				addOffset("singRIGHT", 7, 64);
				addOffset("singLEFT", 87, 58);
				addOffset("singDOWN", 54, -104);
				addOffset('rage');

				playAnim('idle');
		}

		// set up offsets cus why not
		if (OpenFlAssets.exists(Paths.offsetTxt(curCharacter + 'Offsets')))
		{
			var characterOffsets:Array<String> = CoolUtil.coolTextFile(Paths.offsetTxt(curCharacter + 'Offsets'));
			for (i in 0...characterOffsets.length)
			{
				var getterArray:Array<Array<String>> = CoolUtil.getOffsetsFromTxt(Paths.offsetTxt(curCharacter + 'Offsets'));
				addOffset(getterArray[i][0], Std.parseInt(getterArray[i][1]), Std.parseInt(getterArray[i][2]));
			}
		}

		dance();
	}

	function flipLeftRight():Void
	{
		// get the old right sprite
		var oldRight = animation.getByName('singRIGHT').frames;

		// set the right to the left
		animation.getByName('singRIGHT').frames = animation.getByName('singLEFT').frames;

		// set the left to the old right
		animation.getByName('singLEFT').frames = oldRight;

		// insert ninjamuffin screaming I think idk I'm lazy as hell

		if (animation.getByName('singRIGHTmiss') != null)
		{
			var oldMiss = animation.getByName('singRIGHTmiss').frames;
			animation.getByName('singRIGHTmiss').frames = animation.getByName('singLEFTmiss').frames;
			animation.getByName('singLEFTmiss').frames = oldMiss;
		}
	}

	override function update(elapsed:Float)
	{
		if (!curCharacter.startsWith('bf'))
		{
			if (animation.curAnim.name.startsWith('sing'))
			{
				holdTimer += elapsed;
			}

			var dadVar:Float = 4;
			if (holdTimer >= Conductor.stepCrochet * dadVar * 0.001)
			{
				dance();
				holdTimer = 0;
			}
		}

		var curCharSimplified:String = simplifyCharacter();
		switch (curCharSimplified)
		{
			case 'gf':
				if (animation.curAnim.name == 'hairFall' && animation.curAnim.finished)
					playAnim('danceRight');
				if ((animation.curAnim.name.startsWith('sad')) && (animation.curAnim.finished))
					playAnim('danceLeft');
		}

		// Post idle animation (think Week 4 and how the player and mom's hair continues to sway after their idle animations are done!)
		if (animation.curAnim.finished && animation.curAnim.name == 'idle')
		{
			// We look for an animation called 'idlePost' to switch to
			if (animation.getByName('idlePost') != null)
				// (( WE DON'T USE 'PLAYANIM' BECAUSE WE WANT TO FEED OFF OF THE IDLE OFFSETS! ))
				animation.play('idlePost', true, false, 0);
		}

		super.update(elapsed);
	}

	private var danced:Bool = false;

	/**
	 * FOR GF DANCING SHIT
	 */
	public function dance(?forced:Bool = false)
	{
		if (!debugMode)
		{
			var curCharSimplified:String = simplifyCharacter();
			switch (curCharSimplified)
			{
				case 'gf':
					if ((!animation.curAnim.name.startsWith('hair')) && (!animation.curAnim.name.startsWith('sad'))&& (!animation.curAnim.name.startsWith('land')))
					{
						danced = !danced;

						if (danced)
							playAnim('danceRight', forced);
						else
							playAnim('danceLeft', forced);
					}
				default:
					// Left/right dancing, think Skid & Pump
					if (animation.getByName('danceLeft') != null && animation.getByName('danceRight') != null)
						playAnim((animation.curAnim.name == 'danceRight') ? 'danceLeft' : 'danceRight', forced);
					// Play normal idle animations for all other characters
					else
						playAnim('idle', forced);
			}
		}
	}

	override public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
	{
		if (animation.getByName(AnimName) != null)
			super.playAnim(AnimName, Force, Reversed, Frame);

		var daOffset = animOffsets.get(AnimName);
		if (animOffsets.exists(AnimName))
		{
			offset.set(daOffset[0] * scale.x, daOffset[1] * scale.y);
		}
		else
			offset.set(0, 0);

		if (curCharacter == 'gf')
		{
			if (AnimName == 'singLEFT')
				danced = true;
			else if (AnimName == 'singRIGHT')
				danced = false;

			if (AnimName == 'singUP' || AnimName == 'singDOWN')
				danced = !danced;
		}
	}

	public function simplifyCharacter():String
	{
		var base = curCharacter;

		if (base.startsWith('gf'))
			base = 'gf';
		return base;
	}
}
