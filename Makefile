FILES = act1.dg actions.dg interface.dg parser.dg worldmodel.dg
OPTIONS = --word-seps='^⸗=.,;"()*'
# ^ for determiners, ⸗ for proper clitics, = for ASCII clitics; the rest are default
OPTIONS_DBG = --word-seps='^=.,;"()*'
# Debugger can't handle non-ASCII word separators yet


debug: $(FILES) platform_debug.dg
	dgdebug $(OPTIONS_DBG) platform_debug.dg $(FILES)

hittite.z5: $(FILES) platform_z.dg
	dialogc -t z5 -o hittite.z5 $(OPTIONS) platform_z.dg $(FILES)

play: hittite.z5
	frotz hittite.z5

hittite.aastory: $(FILES) platform_web.dg
	dialogc -t aa -o hittite.aastory $(OPTIONS) platform_web.dg $(FILES)

dictionary.js: dictionary.tsv dictionarify.py
	python dictionarify.py

web: hittite.aastory ishamai modweb dictionary.js
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
	( cd web/aacuneiform && tnftp -u ftp://nr5x4soelpdf@meadstelzer.com/public_html/daniel/if/hittite/aacuneiform/ ./* )
	( cd web && tnftp -u ftp://nr5x4soelpdf@meadstelzer.com/public_html/daniel/if/hittite/ index.html )

vvv.log: $(FILES)
	dgdebug -vvv $(OPTIONS) $(FILES) > vvv.log

regress: $(FILES)
	dgdebug -qD -s 1234 platform_debug.dg $(OPTIONS_DBG) $(FILES) <regress.in >regress.out
	meld regress.out regress.gold
