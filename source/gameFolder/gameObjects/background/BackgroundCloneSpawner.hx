package gameFolder.gameObjects.background;

import flixel.FlxBasic;
import flixel.graphics.frames.FlxAtlasFrames;
import gameFolder.meta.CoolUtil;
import gameFolder.meta.data.dependency.FNFSprite;
import flixel.group.FlxGroup.FlxTypedGroup;

class BackgroundCloneSpawner extends FlxTypedGroup<BackgroundClone>
{
	public var nextSpawn:Float = 2;

	public function new()
	{
		super();
	}

	public override function update(elapsed)
	{	
		for (clone in members)
			clone.update(elapsed);

		nextSpawn -= elapsed;
		if (nextSpawn <= 0) {
			nextSpawn = (Math.random() * 5) + 2;

			var moveDir = (Math.round(Math.random()) == 0) ? -1 : 1;
			var newClone:BackgroundClone = new BackgroundClone(
				(1400 * -moveDir) + 400, 
				200, 
				moveDir, 
				Math.round(Math.random() * 100) + 310
			);
			newClone.spawner = this;

			add(newClone);
		}
	}
}
