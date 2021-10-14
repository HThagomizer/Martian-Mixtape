package gameFolder.gameObjects.background;

import flixel.graphics.frames.FlxAtlasFrames;
import gameFolder.meta.CoolUtil;
import gameFolder.meta.data.dependency.FNFSprite;

class BackgroundClone extends FNFSprite
{
	public function new(x:Float, y:Float, direction:Int, speed:Int, skin:Int, isFront:Bool)
	{
		super(x, y + getYOffset(skin));

		// unclean but whatevs
		// this just picks a random number from 1 to 3 to load lol
		frames = Paths.getSparrowAtlas('backgrounds/breakout/clones/' + Std.string(skin));
		color = 0xFF9999;
		scrollFactor.set(1, 1);
		antialiasing = true;
		visible = false;
		active = true;

		moveDir = direction;
		moveSpeed = speed;
		cloneSkin = skin;

		animation.addByPrefix('run', 'run', fps, true);
		animation.addByPrefix('death', 'death', fps, false);

		if (isFront)
			setGraphicSize(Math.round(width * 1.2), Math.round(height * 1.2));
		
		die(0);
	}

	public function getYOffset(skin:Int):Int
	{
		switch(skin)
		{
			default:
				return 0;
			case 2:
				return -200;
			case 3:
				return -192;
		}
	}

	public function spawn() 
	{
		moveDir = (Math.round(Math.random()) == 0) ? -1 : 1;
		x = (1400 * -moveDir) + 400;

		fps = Math.round((moveSpeed / 360) * 6);
		timeUntilDeath = (Math.random() * 6) + 2;

		animation.play('run', true);
		flipX = (moveDir == 1) ? false : true;

		reusable = false;
		dead = false;
		visible = true;
	}

	public var moveDir:Int = 1;
	public var moveSpeed:Float = 360;
	public var fps:Int = 6;
	public var timeUntilDeath:Float = 2;
	public var timeUntilReusable:Float = 0;

	public var cloneSkin:Int = 0;
	public var reusable:Bool = true;
	public var dead:Bool = true;
	public var spawner:BackgroundCloneSpawner;

	public function die(elapsed:Float)
	{
		animation.play('death', true);
		dead = true;
		timeUntilReusable = 2;
	}

	public override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (!dead) {
			x += moveDir * moveSpeed * elapsed;
		}

		if (timeUntilDeath > 0) {
			timeUntilDeath -= elapsed;
			if (timeUntilDeath <= 0) {
				timeUntilDeath = 0;
				die(elapsed);
			}
		}

		if (timeUntilReusable > 0) {
			timeUntilReusable -= elapsed;
			if (timeUntilReusable <= 0) {
				timeUntilReusable = 0;
				reusable = true;
				visible = false;
			}
		}
	}
}
