# Generate JavaScript files from the various Hantatallas data
# The data needed is:
# hzl.dat : Hantatallas data on all the signs, includes a mapping from sign names to HZL numbers
# unicode.csv : data from Wiktionary, includes a mapping from HZL numbers to Unicode codepoints

import csv
from pathlib import Path
import json

def get_unicode(path):
	data = {}
	with path.open('r', newline='') as f:
		r = csv.DictReader(f)
		for i, row in enumerate(r):
			# The important columns for us are "HethZL" and "Unicode Glyph"
			# But we also look at "Sign Name" for error messages
			hzl = row['HethZL'].strip()
			unicode = row['Unicode Glyph'].strip()
			name = row['Sign Name'].strip()
			
			if not hzl: continue # Some signs in unicode.csv aren't actually in the HZL; we ignore them
			if not unicode: continue # And same if it has no codepoints
			
			codepoints = []
			for c in unicode.split():
				if c.startswith('U+'):
					codepoints.append(int(c[2:], 16)) # Read as hex
			if not codepoints:
				print(f'\tWarning: couldn\'t parse unicode for {name}: "{unicode}" on line {i+1}')
				continue
			
			new = ''.join(chr(cp) for cp in codepoints)
			if hzl in data:
				print(f'\tWarning: entry for {hzl} exists already, {data[hzl]} being replaced by {new} on line {i+1}')
			# If we've gotten to here, we have a valid HZL number and list of one or more codepoints
			data[hzl] = new
	
	return data

def get_hzl(path):
	data = {}
	with path.open('r') as f:
		current = None
		namefound = False
		for i, line in enumerate(f): # i is for error messages
			if namefound:
				namefound = False
				if current is None: raise ValueError(current, line, i+1)
				if current in data:
					print(f'\tWarning: entry for {current} already exists, {data[current]} being replaced by {line.strip().split()} on line {i+1}')
				data[current] = line.strip().split()
				current = None
			elif not line.startswith('\t'): # At the left column: new identifier
				if line.strip(): # And not a blank line, notably!
					current = line.strip()
			elif line.startswith('\tNAME'): # NAME in the second column: the next line will be the names
				namefound = True
	return data

def write_file(path, unicode, hzl):
	unidata = json.dumps(unicode, indent='\t')
	hzldata = json.dumps(hzl, indent='\t')
	with path.open('w') as f:
		f.write('name_hzl = ' + hzldata + ';\n\n')
		f.write('hzl_unicode = ' + unidata + ';\n')

if __name__ == '__main__':
	base = Path.home() / 'Projects/Cuneiform/hantatallas/data'
	print('Getting unicode')
	uni = get_unicode(base / 'unicode_cleaned.csv') # A version of the file cleaned up to remove warnings in this code
	print('Getting HZL')
	hzl = get_hzl(base / 'hzl.dat')
	print('Writing')
	write_file(Path('./hzl.js'), uni, hzl)
	print('Done!')
