package states.stages;

import states.stages.objects.*;
import cutscenes.DialogueBox;
import shaders.WiggleEffect.WiggleEffectType;

class PsychicStage extends BaseStage
{
	var animatedBGSprite:BGSprite;

	override function create()
	{
				var backwall:BGSprite = new BGSprite('backwall', -490, -580, 0.8, 0.92);
				add(backwall);

				var floor:BGSprite = new BGSprite('floor', -370, 570, 0.95, 0.98);
				add(floor);

				if(!ClientPrefs.data.lowQuality) {
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
				if(!ClientPrefs.data.lowQuality) animatedBGSprite.dance();
	}

	var doof:DialogueBox = null;
	function initDoof()
	{
		var file:String = Paths.txt('$songName/${songName}Dialogue_${ClientPrefs.data.language}'); //Checks for vanilla/Senpai dialogue
		#if MODS_ALLOWED
		if (!FileSystem.exists(file))
		#else
		if (!OpenFlAssets.exists(file))
		#end
		{
			file = Paths.txt('$songName/${songName}Dialogue');
		}

		#if MODS_ALLOWED
		if (!FileSystem.exists(file))
		#else
		if (!OpenFlAssets.exists(file))
		#end
		{
			startCountdown();
			return;
		}

		doof = new DialogueBox(false, CoolUtil.coolTextFile(file));
		doof.cameras = [camHUD];
		doof.scrollFactor.set();
		doof.finishThing = startCountdown;
		doof.nextDialogueThing = PlayState.instance.startNextDialogue;
		doof.skipDialogueThing = PlayState.instance.skipDialogue;
	}
}
