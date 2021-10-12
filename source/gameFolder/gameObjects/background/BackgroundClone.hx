package gameFolder.gameObjects.background;

import flixel.graphics.frames.FlxAtlasFrames;
import gameFolder.meta.CoolUtil;
import gameFolder.meta.data.dependency.FNFSprite;

class BackgroundClone extends FNFSprite
{
	public function new(x:Float, y:Float, direction:Int, speed:Int)
	{
		super(x, y);

		// unclean but whatevs
		// this just picks a random number from 1 to 3 to load lol
		frames = Paths.getSparrowAtlas('backgrounds/breakout/clones/' + Std.string(Math.round(Math.random() * 2) + 1));
		color = 0xFF9999;
		scrollFactor.set(1, 1);
		antialiasing = true;
		active = true;

		moveDir = direction;
		moveSpeed = speed;

		fps = Math.round((moveSpeed / 360) * 6);
		timeUntilDeath = (Math.random() * 6) + 2;

		animation.addByPrefix('run', 'run', fps, true);
		animation.addByPrefix('death', 'death', fps, false);

		animation.play('run', true);
		flipX = (moveDir == 1) ? false : true;
	}

	public var moveDir:Int = 1;
	public var moveSpeed:Float = 360;
	public var fps:Int = 6;
	public var timeUntilDeath:Float = 2;
	public var timeUntilDestroy:Float = 0;

	public var spawner:BackgroundCloneSpawner;

	public function die(elapsed:Float)
	{
		animation.play('death', true);
		moveSpeed = 0;
		timeUntilDestroy = 2;
	}

	public override function update(elapsed:Float)
	{
		super.update(elapsed);
		x += moveDir * moveSpeed * elapsed;

		if (timeUntilDeath > 0) {
			timeUntilDeath -= elapsed;
			if (timeUntilDeath <= 0) {
				timeUntilDeath = 0;
				die(elapsed);
			}
		}

		if (timeUntilDestroy > 0) {
			timeUntilDestroy -= elapsed;
			if (timeUntilDestroy <= 0) {
				timeUntilDestroy = 0;
				if (spawner.members.contains(this)) {
					spawner.remove(this, true);
				}
				super.destroy();
			}
		}
	}
}
