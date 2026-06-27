FILES = act1.dg actions.dg interface.dg parser.dg worldmodel.dg
OPTIONS = --word-seps='⸗=.,;"()*'
OPTIONS_DBG = --word-seps='=.,;"()*'
# Debugger can't handle non-ASCII word separators yet


debug: $(FILES)
	dgdebug $(OPTIONS) platform_debug.dg $(FILES)

hittite.z5: $(FILES)
	dialogc -t z5 -o hittite.z5 $(OPTIONS) platform_z.dg $(FILES)

play: hittite.z5
	frotz hittite.z5

hittite.aastory: $(FILES) platform_web.dg
	dialogc -t aa -o hittite.aastory $(OPTIONS) platform_web.dg $(FILES)

web: hittite.aastory ishamai modweb
	rm -rf web
	aambundle -t web hittite.aastory -o web
	cp -r ishamai web/
	rm web/play.html
	cp -r modweb/* web/

# deploy to meadstelzer.com/daniel/if/hittite/
deploy: web
	( cd web/resources && tnftp -u ftp://nr5x4soelpdf@meadstelzer.com/public_html/daniel/if/hittite/resources/ ./* )
	( cd web/ishamai/fonts && tnftp -u ftp://nr5x4soelpdf@meadstelzer.com/public_html/daniel/if/hittite/ishamai/fonts/ ./*.otf )
	( cd web/ishamai && tnftp -u ftp://nr5x4soelpdf@meadstelzer.com/public_html/daniel/if/hittite/ishamai/ ./*.css ./*.js )
	( cd web && tnftp -u ftp://nr5x4soelpdf@meadstelzer.com/public_html/daniel/if/hittite/ index.html )

vvv.log: $(FILES)
	dgdebug -vvv $(OPTIONS) $(FILES) > vvv.log

regress: $(FILES)
	dgdebug -qD -s 1234 platform_debug.dg $(OPTIONS_DBG) $(FILES) <regress.in >regress.out
	meld regress.out regress.gold
