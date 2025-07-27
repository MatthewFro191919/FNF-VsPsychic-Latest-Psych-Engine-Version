package states.stages;

import states.stages.objects.*;

class SpaceStage extends BaseStage
{
	override function create()
	{
				var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('space'));
				bg.antialiasing = ClientPrefs.data.antialiasing;
				bg.scrollFactor.set(0.9, 0.9);
				bg.active = false;
				add(bg);

				var asteroid:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Paths.image('asteroid'));
				asteroid.setGraphicSize(Std.int(asteroid.width * 1.1));
				asteroid.updateHitbox();
				asteroid.antialiasing = ClientPrefs.data.antialiasing;
				asteroid.scrollFactor.set(0.9, 0.9);
				asteroid.active = false;
				add(asteroid);

				if(!ClientPrefs.lowQuality) {
					var voyager:FlxSprite = new FlxSprite(-500, -300).loadGraphic(Paths.image('voyager'));
					voyager.setGraphicSize(Std.int(voyager.width * 0.9));
					voyager.updateHitbox();
					voyager.antialiasing = ClientPrefs.data.antialiasing;
					voyager.scrollFactor.set(1.3, 1.3);
					voyager.active = false;
					add(voyager);
				}
	}
}
