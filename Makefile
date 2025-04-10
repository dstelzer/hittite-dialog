FILES = act1.dg actions.dg parser.dg worldmodel.dg

debug: $(FILES)
	dgdebug $(FILES)

hittite.z5: $(FILES)
	~/Projects/Dialog/src/dialogc -t z5 -o hittite.z5 $(FILES)

play: hittite.z5
	frotz hittite.z5
