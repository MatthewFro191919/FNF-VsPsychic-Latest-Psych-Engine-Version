package states.stages;

import states.stages.objects.*;

class PsychicStage extends BaseStage
{
	var animatedBGSprite:BGSprite;

	override function create()
	{
				var backwall:BGSprite = new BGSprite('backwall', -490, -580, 0.8, 0.92);
				add(backwall);

				var floor:BGSprite = new BGSprite('floor', -370, 570, 0.95, 0.98);
				add(floor);

				if(!ClientPrefs.lowQuality) {
					animatedBGSprite = new BGSprite('fireplace', 140, -340, 0.8, 0.92, ['fireplace'], false);
					add(animatedBGSprite);
				} else {
					var fireplace:BGSprite = new BGSprite('fireplace_low', 140, -340, 0.8, 0.92);
					add(fireplace);
				}

				var chair:BGSprite = new BGSprite('chair', -240, 180, 0.9, 0.96);
				add(chair);
	}

	override function beatHit()
	{
				if(!ClientPrefs.lowQuality) animatedBGSprite.dance();
	}

	function dialogueIntro(dialogue:Array<String>, ?song:String = '', ?doBlack:Bool = true):Void
	{
		// TO DO: Make this more flexible
		inCutscene = true;
		var black:FlxSprite = new FlxSprite(-500, -500).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		if(!doBlack) {
			black.alpha = 0.25; //Faster transition to dialogue
			black.visible = false;
		}
		black.scrollFactor.set();

		var white:FlxSprite = new FlxSprite(-500, -500).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.WHITE);
		white.scrollFactor.set();
		white.visible = false;
		add(white);
		add(black);

		if(curStage == 'psychic' && !ClientPrefs.lowQuality) {
			new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer) {
				animatedBGSprite.dance();
			}, 5);
		}

		CoolUtil.precacheSound('dialogue');
		CoolUtil.precacheSound('dialogueClose');
		new FlxTimer().start(0.5, function(tmr:FlxTimer) {
			openSubState(new DialogueBoxPsych(dialogue, song, black, white));
			DialogueBoxPsych.finishThing = startCountdown;
		});
	}
}
