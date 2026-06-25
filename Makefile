FILES = act1.dg actions.dg interface.dg parser.dg worldmodel.dg
OPTIONS = --word-seps='=.,;"()*'

debug: $(FILES)
	dgdebug $(OPTIONS) $(FILES)

hittite.z5: $(FILES)
	~/Projects/Dialog/src/dialogc -t z5 -o hittite.z5 $(OPTIONS) $(FILES)

play: hittite.z5
	frotz hittite.z5

vvv.log: $(FILES)
	dgdebug -vvv $(OPTIONS) $(FILES) > vvv.log

regress: $(FILES)
	dgdebug -s 1234 $(OPTIONS) $(FILES) <regress.in >regress.out
	meld regress.out regress.gold
