#importonce 

*=$4800 "[DATA] ScreenRam"
ScreenRam:
	.var charmap = LoadBinary("Pictures/background - Map (40x50).bin")
 	.fill 1000, charmap.get(i)

*=$4C00 "[DATA] ScreenRam intro"
ScreenRamTitleScreen:
	.var charmapIntro = LoadBinary("Pictures/background - Map (40x50).bin")
 	.fill 1000, charmapIntro.get(1000+i)

*=$4000 "[DATA] CharRam"
CharRam:
	.var charset = LoadBinary("Pictures/background - Chars.bin")
    .fill charset.getSize(), charset.get(i)

.pc = $5000 "[DATA] Sprite memory"
SpriteMemory:
	.var sprites = LoadBinary("Sprites/DuckHunt - Sprites.bin")
	.fill sprites.getSize(), sprites.get(i)

.var Music = LoadSid("music/Duckhunt.sid")
*=Music.location "[MUSIC] Duckhunt by Jack-Paw-Judi"
.fill Music.size, Music.getData(i)

*=$c000 "[DATA] SoundFX"
#import "Music\SoundFx.asm"