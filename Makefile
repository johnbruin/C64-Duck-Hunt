# http://www.theweb.dk/KickAssembler
KICKASS="G:\Mijn Drive\c64\KickAssembler/KickAss.jar"

# https://sourceforge.net/projects/c64-debugger/
DEBUGGER="G:\Mijn Drive\c64\C64Debugger\C64Debugger.exe"

# https://bitbucket.org/magli143/exomizer/wiki/Home
EXOMIZER="G:\Mijn Drive\c64\exomizer-3.1.0\win32\exomizer.exe"

VICE="G:\Mijn Drive\c64\VICE\bin\x64sc.exe"

# Compile assembly files with KickAssembler
#%.prg: %.asm $(KICKASS)
#	java -jar $(KICKASS) -debugdump "$<"

# Build a final version
duckhunt.prg:
	java -jar $(KICKASS) "main.asm"	
	$(EXOMIZER) sfx sys main.prg -o "duckhunt.prg" -n
	del main.prg
	del main.sym
	$(VICE) "duckhunt.prg"

# Build and debug
%.debug:
	$(DEBUGGER) -prg "$*.prg" -pass -unpause -wait 2500 -autojmp -layout 9

clean:
	del *.prg
	del *.exe.prg
	del *.sym
	del *.vs
	del *.dbg
	del *.d64
	del /S .source.txt