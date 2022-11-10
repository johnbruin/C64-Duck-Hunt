#importonce 

.var state_now	= $fb
.var overlay_distance = 19
.var gameState = $f0
.enum {
	 Intro
	,Playing
	,ClearWith1Duck
	,ClearWith2Ducks
	,EndRound
	,StartRound
	,GameOver
	,NewRound
	,NewSet
	,FlyAway
	,Miss
}

*=$4800 "[DATA] ScreenRam"
screenRam:
	.var charmap = LoadBinary("Pictures/background - Map (40x50).bin")
 	.fill 1000, charmap.get(i)

*=$4C00 "[DATA] ScreenRam intro"
screenRamTitleScreen:
	.var charmapIntro = LoadBinary("Pictures/background - Map (40x50).bin")
 	.fill 1000, charmapIntro.get(1000+i)

*=$4000 "[DATA] CharRam"
charRam:
	.var charset = LoadBinary("Pictures/background - Chars.bin")
    .fill charset.getSize(), charset.get(i)

.pc = $5000 "[DATA] Sprite memory"
spriteMemory:
	.var sprites = LoadBinary("Sprites/DuckHunt - Sprites.bin")
	.fill sprites.getSize(), sprites.get(i)

.var music = LoadSid("music/Hiraeth_part_1_mockup.sid")
*=music.location "[MUSIC] Hiraeth by Jack-Paw-Judi"
.fill music.size, music.getData(i)

*=$c000 "[DATA] SoundFX"
#import "Music\SoundFx.asm"