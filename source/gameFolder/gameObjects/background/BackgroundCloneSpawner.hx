package gameFolder.gameObjects.background;

import flixel.FlxBasic;
import flixel.graphics.frames.FlxAtlasFrames;
import gameFolder.meta.CoolUtil;
import gameFolder.meta.data.dependency.FNFSprite;
import flixel.group.FlxGroup.FlxTypedGroup;

class BackgroundCloneSpawner extends FlxTypedGroup<BackgroundClone>
{
	public var nextSpawn:Float = 2;

	public function new(isBottom:Bool)
	{
		super();

		if (isBottom)
			nextSpawn += 2;

		for (i in 0...4) {
			var cloneNum = i;

			if (isBottom)
				cloneNum += 2;

			var skin:Int = (cloneNum % 3) + 1;
			var newClone:BackgroundClone = new BackgroundClone(
				0, 
				(isBottom ? 600 : 200), 
				1, 
				Math.round(Math.random() * 100) + 310,
				skin,
				isBottom
			);
			newClone.spawner = this;
			add(newClone);
		}
	}

	public override function update(elapsed)
	{	
		for (clone in members)
			clone.update(elapsed);

		nextSpawn -= elapsed;
		if (nextSpawn <= 0) {
			nextSpawn = (Math.random() * 5) + 2;

			var spawnedClone:Bool = false;
			for (clone in members)
			{
				if (!spawnedClone && clone.reusable) {
					clone.spawn();
					spawnedClone = true;

					// shuffling things around
					remove(clone);
					add(clone);
				}
			}
		}
	}
}
