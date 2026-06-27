#!/usr/bin/env python

# Takes the file dictionary.tsv and turns it into a JSON file that the web frontend can make use of

# TSV format:
# Headword \t Forms \t Definition [ \t Paradigm ]
# "Forms" is an unordered space-separated list of all forms that should bring up this entry
# "Paradigm", if provided, is one of:
# 		CLIT						provide an explanation of clitics
# 		DTM							provide an explanation of determiners
# 		NOUN nom gen dat acc abl	a noun paradigm with five cases
# 		A B A B A B...				make a two-column table, A left, B right
# 										(cells containing spaces must be quoted)

# JSON format:
# Two big dictionaries: `dictionary_forms` and `dictionary_defns`
# `dictionary_forms` maps each form to its headword
# `dictionary_defns` maps each headword to a block of HTML with the definition

import json
from pathlib import Path

def space_separated_with_quotes(s): # a   b "c \" d" -> ['a', 'b', 'c " d']
	out = []
	current = []
	quoted = False
	backslash = False
	for c in s:
		if c == '\\' and not backslash:
			backslash = True
			continue
		else:
			backslash = False
		
		if c == '"' and not backslash:
			quoted = not quoted
		elif c == ' ':
			if quoted: # Preserve spaces inside quotes
				current.append(' ')
			elif current: # Break words
				out.append(''.join(current))
				current = []
			else: # Multiple spaces in a row do nothing
				pass
		else:
			current.append(c)
	# Reached the end
	if backslash: raise ValueError(f'Stray backslash in {s}')
	if quoted: raise ValueError(f'Unclosed quotation mark in {s}')
	if current: out.append(''.join(current))
	return out

def tablify(l): # [A B C D E F] -> HTML table with A B // C D // E F
				# Assumes that entries are already valid HTML, no escaping is done
	if len(l) % 2:
		raise ValueError(f'Lists passed to tablify should have an even number of entries, but got {len(l)}: {l}')
	lines = ['<table class="paradigm">']
	for i in range(0, len(l), 2): # We could use itertools but this is more readable if less elegant
		first, second = l[i], l[i+1]
		lines.append(f'\t<tr> <td class="eng">{first}</td> <td class="htt word" data-word="{second}" data-language="ht">{second}</td> </tr>')
	lines.append('</table>')
	return '\n'.join(lines)

def parse_paradigm(s):
	if s == 'CLIT':
		return "The = sign separates \"clitics\": words that have their own meaning but can't stand on their own. It's like how the English word <i>cat's</i> is clearly made up of <i>cat</i> and <i>'s</i>, but while <i>cat</i> can exist as a word on its own, <i>'s</i> can't."
	elif s == 'DTM':
		return 'This sign can be used as a "determiner": not pronounced, but marking what sort of thing the next word is.'
	elif s.startswith('NOUN '):
		cases = space_separated_with_quotes(s[5:])
		if len(cases) != 5:
			raise ValueError(f'NOUN paradigm should have five cases; found {len(cases)} in {s}')
		return tablify([
			'<abbr title="Nominative: subject of a verb">Nom</abbr>',	cases[0],
			'<abbr title="Genitive: owner of another noun">Gen</abbr>',	cases[1],
			'<abbr title="Dative: location or destination">Dat</abbr>',	cases[2],
			'<abbr title="Accusative: object of a verb">Acc</abbr>',	cases[3],
			'<abbr title="Ablative: origin or tool used">Abl</abbr>',	cases[4],
		])
	else:
		cells = space_separated_with_quotes(s)
		return tablify(cells)

def parse_entry(s):
	s = s.strip()
	if not s or s.startswith('#'): return {}, {} # blank lines and comments
	pieces = [p.strip() for p in s.split('\t')]
	if len(pieces) == 3:
		lemma, forms, defn = pieces
		prdgm = None
	elif len(pieces) == 4:
		lemma, forms, defn, prdgm = pieces
		prdgm = parse_paradigm(prdgm)
	else:
		raise ValueError(f'Dictionary lines should have 0, 3, or 4 pieces, but this one has {len(pieces)}: {s}')
	
	forms = set([f.strip().lower() for f in forms.split()])
	
	form_dict = {f : lemma for f in forms}
	entry = f'<p class="definition" data-language="en">{defn}</p>'
	if prdgm is not None: entry += f'\n<p class="paradigm" data-language="en">{prdgm}</p>'
	defn_dict = {lemma : entry}
	
	return form_dict, defn_dict

def make_json(forms, defns):
	lines = ['/* NOTE: This code was generated automatically from dictionary.tsv by dictionarify.py. Edit those two files instead of working with this directly! */']
	lines.append('')
	lines.append(f'var dictionary_forms = {json.dumps(forms, sort_keys=True, indent="\t")};')
	lines.append('')
	lines.append(f'var dictionary_defns = {json.dumps(defns, sort_keys=True, indent="\t")};')
	return '\n'.join(lines)

def do_it_all(infn, outfn):
	forms = {}
	defns = {}
	with Path(infn).open('r') as inf:
		for line in inf:
			fd, dd = parse_entry(line)
			forms.update(fd)
			defns.update(dd)
	with Path(outfn).open('w') as outf:
		outf.write(make_json(forms, defns))
		outf.write('\n')

if __name__ == '__main__':
	do_it_all('dictionary.tsv', 'dictionary.js')
