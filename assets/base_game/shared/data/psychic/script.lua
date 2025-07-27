-- End cutscene
local allowEnd = false;
function onEndSong()
	if not allowEnd and isStoryMode then
		allowEnd = true;
		setProperty('inCutscene', true);
		setProperty('boyfriendGroup.visible', false);
		setProperty('gf.stunned', true);
		setProperty('dad.stunned', true);

		makeLuaSprite('blackTransition', nil, -500, -400);
		makeGraphic('blackTransition', screenWidth * 2, screenHeight * 2, '000000')
		addLuaSprite('blackTransition', true);
		setProperty('blackTransition.alpha', 0);

		cutsceneX = 804;
		cutsceneY = 176;
		playSound('bf_transform');
		makeAnimatedLuaSprite('cutsceneBf', 'psychic/BF_Cutscene', cutsceneX, cutsceneY);
		addAnimationByPrefix('cutsceneBf', 'cutscene', 'BF transform', 24, false);
		addLuaSprite('cutsceneBf', true);

		doTweenZoom('camGameZoomTwn', 'camGame', 1, 6, 'sineInOut');
		doTweenAlpha('camHUDAlphaTwn', 'camHUD', 0, 1, 'linear'); 
		doTweenX('camFollowPosXTwn', 'camFollowPos', cutsceneX + 260, 6, 'quadOut');
		doTweenY('camFollowPosYTwn', 'camFollowPos', cutsceneY + 400, 6, 'quadOut');
		runTimer('startBlackTrans', 1.5);
		runTimer('endSongBlackTrans', 11);
		runTimer('endSongAgain', 15);
		return Function_Stop;
	end
	return Function_Continue;
end
