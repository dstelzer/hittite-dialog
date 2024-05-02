// Utility functions for DOM manipulation
function make_span(cls){
	let out = document.createElement("span");
	out.setAttribute("class", cls);
	return out;
}
function add_text(parent, text){
	let inner = document.createTextNode(text);
	parent.appendChild(inner);
}

// Create the element representing a sign: a "sign" span containing a "glyph" span (Unicode) and a "read" span (reading)
function make_sign_element(reading, unicode){
	let sign = make_span("sign");
	let glyph = make_span("glyph");
	add_text(glyph, unicode);
	let read = make_span("read");
	add_text(read, reading);
	sign.appendChild(glyph);
	sign.appendChild(read);
	return sign;
}

// Take a reading and convert it to Unicode characters
function get_unicode_for(reading){
	return "U"+reading; // Placeholder
}

// Take a word and split it up into signs, returning an array of readings
function divide_signs(word){
	return word.split(/([aeiou])/g); // Placeholder
}

// Take a word, split it into signs, then make an element for each one and return an array of them
function shatter_word(word){
	let result = divide_signs(word).map(sign => make_sign_element(sign, get_unicode_for(sign)) );
	return result;
}

// Take whitespace and embed it in an element, in case we use this for the future I guess
function shatter_whitespace(word){
	let node = make_span("whitespace");
	add_text(node, word);
	return node;
}

// Take a text element and return an array of nodes to replace it with in the translit version
function shatter_text(text){
	let segments = text.split(/([^\w\.\-]+)/g); // Anything that comes between words, so 0, 2, 4, etc will be the words and 1, 3, 5, etc will be the in-between parts
	let out = [];
	segments.forEach(function(word, index){
		if(!word) ;
		else if(index%2 == 0) out.push(...shatter_word(word));
		else out.push(shatter_whitespace(word));
	});
	console.log(out);
	return out;
}

// Take an element and make two versions of it, "bound" and "translit"
function process_element(element){
	// First, see if it already has a child of class "bound"
	let child = element.querySelector(".bound");
	if(child) return; // Already done, nothing to do here
	
	// Create two new children for it: the first is a span of class "bound"
	let bound = make_span("bound");
	
	// Move all children over to "bound"
	while(element.childNodes.length > 0) bound.appendChild(element.childNodes[0]);
	
	// Then copy it to make "translit"
	let translit = bound.cloneNode(true); // Deep copy
	translit.setAttribute("class", "translit");
	
	// Then put the two spans inside the element
	element.appendChild(bound);
	element.appendChild(translit);
	
	// Now we need to find all the TEXT_NODE nodes within this…which we can't do with querySelectorAll! So we need to do this manually, selecting `element` and all its descendants, then scanning the children of each one.
	let elnodes = Array.from(translit.querySelectorAll("*")); // All descendant elements - cannot get text nodes with querySelectorAll sadly
	elnodes.push(translit);
	let textnodes = [];
	for(let i=0; i<elnodes.length; i++){
		let el = elnodes[i];
		for(let j=0; j<el.childNodes.length; j++){
			let ch = el.childNodes[j];
			if(ch.nodeType == Node.TEXT_NODE){
				textnodes.push(ch);
			}
		}
	}
	console.log("Text nodes: " + textnodes);
	
	textnodes.forEach(node => node.replaceWith(... shatter_text(node.textContent)) );
}

// Do this to every line on the page
function process_all(){
}
