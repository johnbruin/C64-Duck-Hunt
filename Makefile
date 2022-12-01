# http://www.theweb.dk/KickAssembler
KICKASS="G:\Mijn Drive\c64\KickAssembler/KickAss.jar"

# https://sourceforge.net/projects/c64-debugger/
DEBUGGER="G:\Mijn Drive\c64\C64Debugger\C64Debugger.exe"

# https://bitbucket.org/magli143/exomizer/wiki/Home
EXOMIZER="G:\Mijn Drive\c64\exomizer-3.1.0\win32\exomizer.exe"

VICE="G:\Mijn Drive\c64\VICE\bin\x64sc.exe"

# Build a crunched version of Main.prg
%.zip: %.prg
	$(EXOMIZER) sfx sys "$<" -o "$*.zip" -n

# Build a final version
duckhunt.prg:
	java -jar $(KICKASS) "Main.asm"	
	$(EXOMIZER) sfx sys "Main.prg" -o "Main.zip" -n
	java -jar $(KICKASS) "Loading.asm"	
	$(EXOMIZER) sfx sys "Loading.prg" -o "Duck_Hunt.prg" -n
	del Main.prg
	del Main.zip
	del Main.sym
	del Loading.prg
	del Loading.sym
	$(VICE) "Duck_Hunt.prg"

# Build and debug
%.debug:
	$(DEBUGGER) -prg "$*.prg" -pass -unpause -wait 2500 -autojmp -layout 9

clean:
	del Main.zip
	del *.prg
	del *.exe.prg
	del *.sym
	del *.vs
	del *.dbg
	del *.d64
	del /S .source.txt