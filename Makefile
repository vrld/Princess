love=${HOME}/.bin/love # location of love binary
zip=/usr/bin/zip       # location of zip
luac=/usr/bin/luac     # location of luac

game=Princess
sources=*.lua
res=font/*.ttf img/*.png sound/*.ogg

.PHONY : run test love clean

run : test
	$(love) .

test :
	$(luac) -p $(sources)

love : $(game).love

$(game).love : $(sources) $(res)
	$(zip) $(game).love $(sources) $(res)

clean :
	rm $(game).love
