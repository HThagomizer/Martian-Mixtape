package gameFolder.gameObjects.userInterface;

import flixel.FlxSprite;

using StringTools;

class HealthIcon extends FlxSprite
{
	// rewrite using da new icon system as ninjamuffin would say it
	public var sprTracker:FlxSprite;

	public var exclusions:Array<String> = ['pissed', 'psychic', 'caffeinated', 'cool', 'spectral'];

	public function new(char:String = 'bf', isPlayer:Bool = false)
	{
		super();

		loadIcon(char, isPlayer);
	}

	public function loadIcon(char:String = 'bf', isPlayer:Bool = false)
	{
		// made a cooler system instead of the one from last time
		if (char.contains('-'))
		{
			if (!exclusions.contains(char.substring(char.indexOf('-') + 1, char.length)))
				char = char.substring(0, char.indexOf('-'));
		}

		antialiasing = true;
		loadGraphic(Paths.image('icons/icon-' + char), true, 150, 150);
		animation.add('icon', [0, 1], 0, false, isPlayer);
		animation.play('icon');
		scrollFactor.set();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y - 30);
	}
}
