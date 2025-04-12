FILES = act1.dg actions.dg interface.dg parser.dg worldmodel.dg

debug: $(FILES)
	dgdebug $(FILES)

hittite.z5: $(FILES)
	~/Projects/Dialog/src/dialogc -t z5 -o hittite.z5 $(FILES)

play: hittite.z5
	frotz hittite.z5

vvv.log: $(FILES)
	dgdebug -vvv $(FILES) > vvv.log

regress: $(FILES)
	dgdebug -s 1234 $(FILES) <regress.in >regress.out
	meld regress.out regress.gold
