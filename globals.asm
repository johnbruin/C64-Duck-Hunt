#importonce 

.var overlay_distance = 19
.var gameState = $f0
.enum {
	intro
	,roundPlaying
	,roundClearWith1Duck
	,roundClearWith2Ducks
	,roundLost
}


*=$4c00 "[DATA] ScreenRam"
screenRam:
	.var charmap = LoadBinary("Pictures/background - Map (40x25).bin")
 	.fill charmap.getSize(), charmap.get(i)

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