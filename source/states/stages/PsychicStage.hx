package states.stages;

import states.stages.objects.*;
import cutscenes.DialogueBox;
import shaders.WiggleEffect;
import objects.Note;
import backend.Achievements.AchievementObject;
import backend.Song;
import openfl.filters.ShaderFilter;
import flixel.ui.FlxBar;
import flixel.FlxObject;

class PsychicStage extends BaseStage
{
	var animatedBGSprite:BGSprite;

	private var updateTime:Bool = false;

	private var vocals:FlxSound;

	var songPercent:Float = 0;

	var talking:Bool = true;
	var songScore:Int = 0;
	var songHits:Int = 0;
	var songMisses:Int = 0;
	var scoreTxt:FlxText;
	var timeTxt:FlxText;

	public static var campaignScore:Int = 0;
	public static var campaignMisses:Int = 0;
	public static var deathCounter:Int = 0;

	private var camZooming:Bool = false;

	var startedCountdown:Bool = false;
	var limoSpeed:Float = 0;

	private var timeBarBG:AttachedSprite;

	public var timeBar:FlxBar;

	public var endingSong:Bool = false;

	private var notes:FlxTypedGroup<Note>;
	private var psychicNotes:Array<Dynamic> = [];

	var finishTimer:FlxTimer = null;

	var wiggleShit:WiggleEffect = new WiggleEffect();

	var frontFakeBf:FlxSprite;
	var fakeBf:FlxSprite;
	var psychicBlack:FlxSprite;

	private var camFollowPos:FlxObject;

	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;

	var ratingString:String;
	var ratingPercent:Float;

	private var camAchievement:FlxCamera;

	public static var practiceMode:Bool = false;
	public static var usedPractice:Bool = false;
	public static var changedDifficulty:Bool = false;

	private static var prevCamFollow:FlxPoint;
	private static var prevCamFollowPos:FlxObject;

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

	function finishSong():Void
	{
		var finishCallback:Void->Void = endSong;
		if(isStoryMode) {
			switch(PlayState.SONG.song.toLowerCase()) {
				case 'psychic': {
					finishCallback = psychicEndSong;
				}
			}
		}

		updateTime = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		vocals.pause();
		if(ClientPrefs.data.noteOffset <= 0) {
			finishCallback();
		} else {
			finishTimer = new FlxTimer().start(ClientPrefs.data.noteOffset / 1000, function(tmr:FlxTimer) {
				finishCallback();
			});
		}
	}

	var achievementObj:AchievementObject = null;
	function startAchievement(achieve:Int) {
		achievementObj = new AchievementObject(achieve, camAchievement);
		achievementObj.onFinish = achievementEnd;
		add(achievementObj);
		trace('Giving achievement ' + achieve);
	}
	function achievementEnd():Void
	{
		achievementObj = null;
		if(endingSong && !inCutscene) {
			endSong();
		}
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
		updateTime = false;
		KillNotes();

		// Cutscene
		FlxTween.tween(camHUD, {alpha: 0}, 2);

		FlxTween.tween(psychicBlack, {alpha: 0.8}, 6, {startDelay: 1.5});
		FlxTween.tween(FlxG.camera, {zoom: 1}, 8, {ease: FlxEase.sineInOut});

		FlxG.camera.follow(camFollowPos, LOCKON, 1);
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
		fakeBf.antialiasing = ClientPrefs.data.antialiasing;

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
					var toBeContinued:Alphabet = new Alphabet(0, 0, "To be continued", true, 0.1);
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
		psychicNotes = [];
	}

	var transitioning = false;
	override function endSong():Bool
	{
		timeBarBG.visible = false;
		timeBar.visible = false;
		timeTxt.visible = false;
		canPause = false;
		endingSong = true;
		camZooming = false;
		inCutscene = false;
		updateTime = false;

		deathCounter = 0;
		KillNotes();

		if(achievementObj != null) {
			return;
		} else {
			var achieve:Int = checkForAchievement([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 13, 14, 15, 16, 17]);
			if(achieve > -1) {
				startAchievement(achieve);
				return;
			}
		}

		if (PlayState.SONG.validScore)
		{
			#if !switch
			var percent:Float = ratingPercent;
			if(Math.isNaN(percent)) percent = 0;
			Highscore.saveScore(PlayState.SONG.song, songScore, storyDifficulty, percent);
			#end
		}

		if (isStoryMode)
		{
			campaignScore += songScore;
			campaignMisses += songMisses;

			storyPlaylist.remove(storyPlaylist[0]);

			if (storyPlaylist.length <= 0)
			{
				FlxG.sound.playMusic(Paths.music('freakyMenu'));

				var transIn:FlxTransitionableState = FlxTransitionableState.defaultTransIn;
				var transOut:FlxTransitionableState = FlxTransitionableState.defaultTransOut;

				FlxG.switchState(new StoryMenuState());

				if (PlayState.SONG.validScore)
				{
					Highscore.saveWeekScore(storyWeek, campaignScore, storyDifficulty);
				}

				FlxG.save.flush();
				usedPractice = false;
				changedDifficulty = false;
			}
			else
			{
				var difficulty:String = "";

				if (storyDifficulty == 0)
					difficulty = '-easy';

				if (storyDifficulty == 2)
					difficulty = '-hard';

				trace('LOADING NEXT SONG');
				trace(PlayState.storyPlaylist[0].toLowerCase() + difficulty);

				var winterHorrorlandNext = (PlayState.SONG.song.toLowerCase() == "eggnog");
				if (winterHorrorlandNext)
				{
					var blackShit:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
						-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
					blackShit.scrollFactor.set();
					add(blackShit);
					camHUD.visible = false;

					FlxG.sound.play(Paths.sound('Lights_Shut_off'));
				}

				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;

				prevCamFollow = camFollow;
				prevCamFollowPos = camFollowPos;

				PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + difficulty, PlayState.storyPlaylist[0]);
				FlxG.sound.music.stop();

				if(winterHorrorlandNext) {
					new FlxTimer().start(1.5, function(tmr:FlxTimer) {
						LoadingState.loadAndSwitchState(new PlayState());
					});
				} else {
					LoadingState.loadAndSwitchState(new PlayState());
				}
			}
		}
		else
		{
			trace('WENT BACK TO FREEPLAY??');
			FlxG.switchState(new FreeplayState());
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
			usedPractice = false;
			changedDifficulty = false;
		}
	}
	private function checkForAchievement(arrayIDs:Array<Int>):Int {
		for (i in 0...arrayIDs.length) {
			//no
		}
		return -1;
	}

	var curLight:Int = 0;
	var curLightEvent:Int = 0;
}
