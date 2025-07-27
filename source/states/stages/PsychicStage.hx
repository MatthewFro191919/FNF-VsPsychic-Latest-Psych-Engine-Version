package states.stages;

import states.stages.objects.*;
import cutscenes.DialogueBoxPsych;
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

		if(curStage == 'psychic' && !ClientPrefs.data.lowQuality) {
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
	
	var frontFakeBf:FlxSprite;
	var fakeBf:FlxSprite;
	var psychicBlack:FlxSprite;
	function startSong():Void
	{
		startingSong = false;

		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		if (!paused)
			FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 1, false);
		FlxG.sound.music.onComplete = finishSong;
		vocals.play();

		if(isStoryMode) {
			switch(SONG.song.toLowerCase()) {
				case 'psychic': {
					psychicBlack = new FlxSprite(-200,-200).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
					psychicBlack.scrollFactor.set();
					psychicBlack.alpha = 0;
					add(psychicBlack);
					fakeBf = new FlxSprite(boyfriend.x - 28, boyfriend.y - 23);
					fakeBf.frames = Paths.getSparrowAtlas('BF_Cutscene');
					fakeBf.animation.addByPrefix('idle', 'BF transform', 24, false);
					fakeBf.visible = false;
					add(fakeBf);
					frontFakeBf = new FlxSprite(fakeBf.x, fakeBf.y);
					frontFakeBf.frames = Paths.getSparrowAtlas('BF_Cutscene');
					frontFakeBf.animation.addByPrefix('idle', 'BF transform', 24, false);
					frontFakeBf.antialiasing = ClientPrefs.globalAntialiasing;
					frontFakeBf.visible = false;
					frontFakeBf.alpha = 0.6;
					add(frontFakeBf);
				}
			}
		}

		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;
		FlxTween.tween(timeBarBG, {alpha: 1}, 0.5, {ease: FlxEase.circOut});
		FlxTween.tween(timeBar, {alpha: 1}, 0.5, {ease: FlxEase.circOut});
		FlxTween.tween(timeTxt, {alpha: 1}, 0.5, {ease: FlxEase.circOut});

		#if desktop
		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText, displaySongName + " (" + storyDifficultyText + ")", iconRPC, true, songLength);
		#end
	}

	var camFrontEffect:FlxCamera;
	function psychicEndSong():Void //This function will be removed once we add a second song to Psychic's week, as the cutscene will happen at the start of the second song instead of end of the first one
	{
		songPercent = 1.0;
		timeTxt.text = '0:00';
		inCutscene = true;
		endingSong = true;
		canPause = false;
		camZooming = false;

		deathCounter = 0;
		seenCutscene = false;
		updateTime = false;
		KillNotes();

		// Cutscene
		FlxTween.tween(camHUD, {alpha: 0}, 2);

		FlxTween.tween(psychicBlack, {alpha: 0.8}, 6, {startDelay: 1.5});
		FlxTween.tween(FlxG.camera, {zoom: 1}, 8, {ease: FlxEase.sineInOut});

		FlxG.camera.follow(camFollowPos, LOCKON, 1);
		camFollow.set(camFollowPos.x, camFollowPos.y);
		FlxTween.tween(camFollowPos, {x: boyfriend.getGraphicMidpoint().x, y: boyfriend.getGraphicMidpoint().y - 50}, 6, {ease: FlxEase.circOut});
		boyfriend.specialAnim = true;
		gf.stunned = true;
		dad.stunned = true;

		camFrontEffect.follow(camFollowPos, LOCKON, 1);
		frontFakeBf.cameras = [camFrontEffect];
		FlxTween.tween(frontFakeBf.scale, {x: 1.2, y: 1.2}, 3.75, {startDelay: 7.5, ease: FlxEase.circOut});
		FlxTween.tween(frontFakeBf, {alpha: 0}, 3.75, {startDelay: 7.5});

		wiggleShit.effectType = FLAG;
		camFrontEffect.setFilters([new ShaderFilter(wiggleShit.shader)]);

		boyfriend.visible = false;
		frontFakeBf.visible = true;
		frontFakeBf.animation.play('idle', true);
		fakeBf.visible = true;
		fakeBf.animation.play('idle', true);
		fakeBf.antialiasing = ClientPrefs.globalAntialiasing;

		new FlxTimer().start(7.5, function(tmr:FlxTimer) {
			wiggleShit.setValue(0);
			wiggleShit.waveSpeed = 5;
			FlxTween.tween(wiggleShit, {waveFrequency: 0.03, waveAmplitude: 0.03}, 2.5);
			FlxG.camera.shake(0.012, 1, function() {
				FlxG.camera.shake(0.009, 1, function() {
					FlxG.camera.shake(0.006, 1, function() {
						FlxG.camera.shake(0.003, 1);
					});
				});
			});
			camFrontEffect.shake(0.012, 1, function() {
				camFrontEffect.shake(0.009, 1, function() {
					camFrontEffect.shake(0.006, 1, function() {
						camFrontEffect.shake(0.003, 1);
					});
				});
			});
		});

		new FlxTimer().start(11.5, function(tmr:FlxTimer) {
			var black:FlxSprite = new FlxSprite(-200,-200).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
			black.scrollFactor.set();
			black.alpha = 0;
			add(black);
			FlxTween.tween(black, {alpha: 1}, 3, {onComplete: function(twn:FlxTween) {
				fakeBf.visible = false;
				new FlxTimer().start(1, function(tmr:FlxTimer) {
					var toBeContinued:Alphabet = new Alphabet(0, 0, "To be continued", true, true, 0.1);
					toBeContinued.scrollFactor.set();
					toBeContinued.screenCenter();
					toBeContinued.x -= 425; //No funny weed number for you
					toBeContinued.y -= 105;
					add(toBeContinued);

					var black:FlxSprite = new FlxSprite(-200,-200).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
					black.scrollFactor.set();
					black.alpha = 0;
					add(black);
					FlxTween.tween(black, {alpha: 1}, 2, {onComplete: function(twn:FlxTween) {
						endSong();
					}, startDelay: 5});
				});
			}, ease: FlxEase.linear});
		});
		FlxG.sound.play(Paths.sound('bf_transform'));
	}

	private function KillNotes() {
		while(notes.length > 0) {
			var daNote:Note = notes.members[0];
			daNote.active = false;
			daNote.visible = false;

			FlxTween.cancelTweensOf(daNote);
			daNote.kill();
			notes.remove(daNote, true);
			daNote.destroy();
		}
		unspawnNotes = [];
		psychicNotes = [];
	}
}
