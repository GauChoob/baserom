all: clean game.gbc

game.o: source/rom/*.asm
	rgbasm -H -l -p 0xFF -o game.o source/game.asm

game.gbc: game.o
	rgblink -n game.sym -m game.map -S romx=255,wramx=6 -o $@ -p 0xFF $<
	rgbfix -C -f lhg -i GAUC -j -n 0x01 -v -t GAUCHOGAME -r 4 -m 0x1B -p 0xFF $@
	md5sum $@

assets: delassets
	python python\\make\\assets_make.py

delassets:
	python python\\make\\assets_unmake.py

clean:
	-rm game.o game.gbc game.sym game.map