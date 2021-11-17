package gameFolder.gameObjects.userInterface.menu;

import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;

class MenuCharacter extends FlxSprite
{
	public var character:String = '';
	public var alt:String = '';

	var curCharacterMap:Map<String, Array<Dynamic>> = [
		// the format is currently
		// name of character => id in atlas, fps, loop, scale, offsetx, offsety
		'bf' => ["BF idle dance white", 24, true, 0.9, 100, 100],
		'bfConfirm' => ['BF HEY!!', 24, false, 0.9, 100, 100],
		'gf' => ["GF Dancing Beat WHITE", 24, true, 1, 100, 100],
		'alien' => ["xigmund greendance", 24, true, 1 * 0.45, -20, 0],
		'fbi' => ["grunt greendance", 24, true, 1 * 0.8, -70, 20],
		'bones' => ["bones greendance", 24, true, 1 * 0.4, 0, 20],
		'harold' => ["harold greendance", 24, true, 1 * 0.5, 0, 10],
		'xigman' => ["xigman greendance", 24, true, 1 * 0.45, 0, 0],
		'alien-rude' => ["rude bluedance", 24, true, 1 * 0.4, -20, 0],
	];

	var baseX:Float = 0;
	var baseY:Float = 0;

	public function new(x:Float, newCharacter:String = 'bf', newAlt:String = '')
	{
		super(x);
		y += 70;

		baseX = x;
		baseY = y;

		createCharacter(newCharacter, newAlt);
		updateHitbox();
	}

	public function createCharacter(newCharacter:String, canChange:Bool = false, newAlt:String = '')
	{
		var tex = Paths.getSparrowAtlas('menus/base/storymenu/campaign_menu_UI_characters');
		frames = tex;
		var assortedValues = curCharacterMap.get(newCharacter);
		var assortedAltValues = curCharacterMap.get(newAlt);
		if (assortedValues != null)
		{
			if (!visible)
				visible = true;

			// animation
			animation.addByPrefix("main", assortedValues[0], assortedValues[1], assortedValues[2]);

			if (newAlt != '')
				animation.addByPrefix("alt", assortedAltValues[0], assortedAltValues[1], assortedAltValues[2]);

			// if (character != newCharacter)
			animation.play("main");

			if (canChange)
			{
				// offset
				setGraphicSize(Std.int(width * assortedValues[3]));
				updateHitbox();
				setPosition(baseX + assortedValues[4], baseY + assortedValues[5]);

				if (newCharacter == 'pico')
					flipX = true;
				else
					flipX = false;
			}
		}
		else
			visible = false;

		character = newCharacter;
		alt = newAlt;
	}
}
