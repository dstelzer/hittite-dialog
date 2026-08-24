FILES = src/actions.dg src/interface.dg src/automap.dg src/draclib.dg src/substances.dg src/parser.dg src/worldmodel.dg
OPTIONS = --word-seps='^⸗=.,;"()*' --resources=resources -vv -H 2000 -A 1000
# ^ for determiners, ⸗ for proper clitics, = for ASCII clitics; the rest are default
OPTIONS_DBG = --word-seps='^=.,;"()*'
# Debugger can't handle non-ASCII word separators yet
VERSION = 4

debug1: $(FILES) src/act1.dg platform/debug.dg
	dgdebug $(OPTIONS_DBG) platform/debug.dg src/act1.dg $(FILES)

debug2: $(FILES) src/act2.dg platform/debug.dg
	dgdebug $(OPTIONS_DBG) platform/debug.dg src/act2.dg $(FILES)

debug3: $(FILES) src/act3.dg src/act3_machinery.dg platform/debug.dg
	dgdebug $(OPTIONS_DBG) platform/debug.dg src/act3.dg src/act3_machinery.dg $(FILES)

serials:
	./update_serials.sh src/actions.dg
	./update_serials.sh src/parser.dg
	./update_serials.sh src/worldmodel.dg

#hittite.z5: $(FILES) platform_z.dg
#	dialogc -t z5 -o hittite.z5 $(OPTIONS) platform_z.dg $(FILES)

#play: hittite.z5
#	frotz hittite.z5

tablet1.aastory: $(FILES) src/act1.dg platform/web.dg
	dialogc -t aa -o tablet1.aastory $(OPTIONS) platform/web.dg src/act1.dg $(FILES)

tablet2.aastory: $(FILES) src/act2.dg platform/web.dg
	dialogc -t aa -o tablet2.aastory $(OPTIONS) platform/web.dg src/act2.dg $(FILES)

tablet3.aastory: $(FILES) src/act3.dg src/act3_machinery.dg platform/web.dg
	dialogc -t aa -o tablet3.aastory $(OPTIONS) platform/web.dg src/act3.dg src/act3_machinery.dg $(FILES)

dictionary.js: dictionary.tsv dictionarify.py
	python dictionarify.py

web: tablet1.aastory tablet2.aastory tablet3.aastory ishamai modweb dictionary.js serials
	rm -rf web
	aambundle -t web tablet1.aastory -o web
	## Generate the basic files needed, using the first tablet as a template
	cp -rL ishamai_trimmed web/ishamai
	## Bring in ishamai
	rm web/play.html
	rm web/resources/*.aastory
	rm web/resources/story.js
	## Get rid of the files we'll be replacing
	cp -rL modweb/* web/
	## Replace the static files
	aambundle -t web:story tablet1.aastory -o web/resources/tablet1.js
	aambundle -t web:story tablet2.aastory -o web/resources/tablet2.js
	aambundle -t web:story tablet3.aastory -o web/resources/tablet3.js
	cp tablet1.aastory web/resources/tablet1.aastory
	cp tablet2.aastory web/resources/tablet2.aastory
	cp tablet3.aastory web/resources/tablet3.aastory
	## Replace the generated files
	cp web/template.html web/tablet1.html
	sed -i 's/THISFILE/tablet1/g' web/tablet1.html
	sed -i 's/THISNUMBER/1/g' web/tablet1.html
	sed -i 's/dictionary\.js/dictionary_simple\.js/g' web/tablet1.html
	## Tablet 1
	cp web/template.html web/tablet2.html
	sed -i 's/THISFILE/tablet2/g' web/tablet2.html
	sed -i 's/THISNUMBER/2/g' web/tablet2.html
	## Tablet 2
	cp web/template.html web/tablet3.html
	sed -i 's/THISFILE/tablet3/g' web/tablet3.html
	sed -i 's/THISNUMBER/3/g' web/tablet3.html
	## Tablet 3
	rm web/template.html
	## Get rid of the template once it's served its purpose

ifcomp.zip: web hints.html
	rm -f ifcomp.zip
	rm -rf ifcomp
	mkdir ifcomp
	cp -rL web ifcomp/
	cp index.html ifcomp/
	cp hints.html ifcomp/
	cp README.ifcomp ifcomp/
	( cd ifcomp && zip -r ../ifcomp.zip . )
	cp ifcomp.zip ifcomp_$(VERSION).zip

# deploy to meadstelzer.com/daniel/if/hittite/
deploy: web
	( cd web/resources && tnftp -u ftp://nr5x4soelpdf@meadstelzer.com/public_html/daniel/if/hittite/resources/ ./* )
	( cd web/ishamai/fonts && tnftp -u ftp://nr5x4soelpdf@meadstelzer.com/public_html/daniel/if/hittite/ishamai/fonts/ ./*.woff2 )
	( cd web/ishamai && tnftp -u ftp://nr5x4soelpdf@meadstelzer.com/public_html/daniel/if/hittite/ishamai/ ./*.js )
	( cd web/aacuneiform && tnftp -u ftp://nr5x4soelpdf@meadstelzer.com/public_html/daniel/if/hittite/aacuneiform/ ./* )
	( cd web && tnftp -u ftp://nr5x4soelpdf@meadstelzer.com/public_html/daniel/if/hittite/ *.html )

vvv.log: $(FILES)
	dgdebug -vvv $(OPTIONS) $(FILES) > vvv.log

regress1.out: $(FILES) src/act1.dg platform/debug.dg regress1.in
	dgdebug -qD -s 1234 $(OPTIONS_DBG) platform/debug.dg src/act1.dg $(FILES) <regress1.in >regress1.out

regress2.out: $(FILES) src/act2.dg platform/debug.dg regress2.in
	dgdebug -qD -s 1234 $(OPTIONS_DBG) platform/debug.dg src/act2.dg $(FILES) <regress2.in >regress2.out

regress3.out: $(FILES) src/act3.dg src/act3_machinery.dg platform/debug.dg regress3.in
	dgdebug -qD -s 1234 $(OPTIONS_DBG) platform/debug.dg src/act3.dg src/act3_machinery.dg $(FILES) <regress3.in >regress3.out

regress1: regress1.out
	meld regress1.out regress1.gold

regress2: regress2.out
	meld regress2.out regress2.gold

regress3: regress3.out
	meld regress3.out regress3.gold

regress: regress1 regress2 regress3

.PHONY: regress regress1 regress2 regress3 deploy debug1 debug2 debug3 serials

PWD := $(shell pwd)
hints.html: hints.clu
	( cd ~/Projects/Invisiclues && python3 maker.py $(PWD)/hints )
	sed -i 's|<head>|<head><link rel="stylesheet" type="text/css" href="hints.css" /><meta name="viewport" content="width=device-width, initial-scale=1">|g' hints.html
	sed -i 's|<style>|<!-- <style>|g' hints.html
	sed -i 's|</style>|</style> -->|g' hints.html
