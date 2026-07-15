FILES = src/actions.dg src/interface.dg src/automap.dg src/draclib.dg src/substances.dg src/parser.dg src/worldmodel.dg
OPTIONS = --word-seps='^⸗=.,;"()*' --resources=resources
# ^ for determiners, ⸗ for proper clitics, = for ASCII clitics; the rest are default
OPTIONS_DBG = --word-seps='^=.,;"()*'
# Debugger can't handle non-ASCII word separators yet


debug1: $(FILES) src/act1.dg platform/debug.dg
	dgdebug $(OPTIONS_DBG) platform/debug.dg src/act1.dg $(FILES)

debug2: $(FILES) src/act2.dg platform/debug.dg
	dgdebug $(OPTIONS_DBG) platform/debug.dg src/act2.dg $(FILES)

#hittite.z5: $(FILES) platform_z.dg
#	dialogc -t z5 -o hittite.z5 $(OPTIONS) platform_z.dg $(FILES)

#play: hittite.z5
#	frotz hittite.z5

tablet1.aastory: $(FILES) src/act1.dg platform/web.dg
	dialogc -t aa -o tablet1.aastory $(OPTIONS) platform/web.dg src/act1.dg $(FILES)

tablet2.aastory: $(FILES) src/act2.dg platform/web.dg
	dialogc -t aa -o tablet2.aastory $(OPTIONS) platform/web.dg src/act2.dg $(FILES)

dictionary.js: dictionary.tsv dictionarify.py
	python dictionarify.py

web: tablet1.aastory tablet2.aastory ishamai modweb dictionary.js
	rm -rf web
	aambundle -t web tablet1.aastory -o web
	## Generate the basic files needed
	cp -r ishamai web/
	## TODO: only really need to copy the .js files and fonts/ from Ishamai
	rm web/play.html
	rm web/resources/*.aastory
	rm web/resources/story.js
	## Get rid of the files we'll be replacing
	cp -r modweb/* web/
	## Replace the static files
	aambundle -t web:story tablet1.aastory -o web/resources/tablet1.js
	aambundle -t web:story tablet2.aastory -o web/resources/tablet2.js
	cp hittite.aastory web/resources/tablet1.aastory
	cp hittite.aastory web/resources/tablet2.aastory
	## Replace the generated files
	cp web/template.html web/tablet1.html
	sed -i 's/THISFILE/tablet1/g' web/tablet1.html
	sed -i 's/dictionary\.js/dictionary_simple\.js/g' web/tablet1.html
	cp web/template.html web/tablet2.html
	sed -i 's/THISFILE/tablet2/g' web/tablet2.html
	rm web/template.html
	## Get rid of the template once it's served its purpose

# deploy to meadstelzer.com/daniel/if/hittite/
deploy: web
	( cd web/resources && tnftp -u ftp://nr5x4soelpdf@meadstelzer.com/public_html/daniel/if/hittite/resources/ ./* )
	( cd web/ishamai/fonts && tnftp -u ftp://nr5x4soelpdf@meadstelzer.com/public_html/daniel/if/hittite/ishamai/fonts/ ./*.otf )
	( cd web/ishamai && tnftp -u ftp://nr5x4soelpdf@meadstelzer.com/public_html/daniel/if/hittite/ishamai/ ./*.css ./*.js )
	( cd web/aacuneiform && tnftp -u ftp://nr5x4soelpdf@meadstelzer.com/public_html/daniel/if/hittite/aacuneiform/ ./* )
	( cd web && tnftp -u ftp://nr5x4soelpdf@meadstelzer.com/public_html/daniel/if/hittite/ *.html )

vvv.log: $(FILES)
	dgdebug -vvv $(OPTIONS) $(FILES) > vvv.log

regress1.out: $(FILES) src/act1.dg platform/debug.dg regress1.in
	dgdebug -qD -s 1234 $(OPTIONS_DBG) platform/debug.dg src/act1.dg $(FILES) <regress1.in >regress1.out

regress1: regress1.out
	meld regress1.out regress1.gold
