:- module(teitools, [load_tei/2, abbreviate_name/2]).
:- use_module(library(sgml)).
:- use_module(library(xpath)).
:- use_module('sgmltools.pl').
:- encoding(utf8).

do_note(element(note, Attrs, Children), element(note, Attrs0, XChildren), N, M) :-
    ((memberchk(n = _, Attrs) ; memberchk(place = inline, Attrs)) ->
     Attrs0 = Attrs, N0 = N;
     atom_number(AN, N),
     Attrs0 = [n = AN | Attrs],
     N0 is N + 1),
    sew_dom(do_note, Children, XChildren, N0, M).

map_entity('[quot  ]', '"').
map_entity('[apos  ]', '\'').
map_entity('[lt    ]', '<').
map_entity('[gt    ]', '>').
map_entity('[copy  ]', '\u00A9').
map_entity('[numero]', '\u2116').
map_entity('[aacute]', '\u00E1'). 
map_entity('[Aacute]', '\u00C1'). 
map_entity('[acirc ]',  '\u00E2'). 
map_entity('[Acirc ]', '\u00C2'). 
map_entity('[agrave]', '\u00E0'). 
map_entity('[Agrave]', '\u00C0'). 
map_entity('[aring ]',  '\u00E5'). 
map_entity('[Aring ]', '\u00C5'). 
map_entity('[atilde]', '\u00E3'). 
map_entity('[Atilde]', '\u00C3'). 
map_entity('[auml  ]', '\u00E4'). 
map_entity('[Auml  ]', '\u00C4'). 
map_entity('[aelig ]', '\u00E6'). 
map_entity('[AElig ]', '\u00C6'). 
map_entity('[ccedil]', '\u00E7'). 
map_entity('[Ccedil]', '\u00C7'). 
map_entity('[eth   ]', '\u00F0'). 
map_entity('[ETH   ]', '\u00D0'). 
map_entity('[eacute]', '\u00E9'). 
map_entity('[Eacute]', '\u00C9'). 
map_entity('[ecirc ]', '\u00EA'). 
map_entity('[Ecirc ]', '\u00CA'). 
map_entity('[egrave]', '\u00E8'). 
map_entity('[Egrave]', '\u00C8'). 
map_entity('[euml  ]', '\u00EB'). 
map_entity('[Euml  ]', '\u00CB'). 
map_entity('[iacute]', '\u00ED'). 
map_entity('[Iacute]', '\u00CD'). 
map_entity('[icirc ]', '\u00EE'). 
map_entity('[Icirc ]', '\u00CE'). 
map_entity('[igrave]', '\u00EC'). 
map_entity('[Igrave]', '\u00CC'). 
map_entity('[iuml  ]', '\u00EF'). 
map_entity('[Iuml  ]', '\u00CF'). 
map_entity('[ntilde]', '\u00F1'). 
map_entity('[Ntilde]', '\u00D1'). 
map_entity('[oacute]', '\u00F3'). 
map_entity('[Oacute]', '\u00D3'). 
map_entity('[ocirc ]', '\u00F4'). 
map_entity('[Ocirc ]', '\u00D4'). 
map_entity('[ograve]', '\u00F2'). 
map_entity('[Ograve]', '\u00D2'). 
map_entity('[oslash]', '\u00F8'). 
map_entity('[Oslash]', '\u00D8'). 
map_entity('[otilde]', '\u00F5'). 
map_entity('[Otilde]', '\u00D5'). 
map_entity('[ouml  ]', '\u00F6'). 
map_entity('[Ouml  ]', '\u00D6'). 
map_entity('[szlig ]', '\u00DF'). 
map_entity('[thorn ]', '\u00FE'). 
map_entity('[THORN ]', '\u00DE'). 
map_entity('[uacute]', '\u00FA'). 
map_entity('[Uacute]', '\u00DA'). 
map_entity('[ucirc ]', '\u00FB'). 

map_entity('[acystress]', 'а\u0301').
map_entity('[iecystress]', 'е\u0301').
map_entity('[icystress]', 'и\u0301').
map_entity('[ocystress]', 'о\u0301').
map_entity('[ucystress]', 'у\u0301').
map_entity('[ycystress]', 'ы\u0301').


replace_sdata(sdata(Text), Result) :-
    map_entity(Text, Result).
replace_sdata(sdata(Text), Text).

preprocess_tree(Dom, Dom1) :-
    complete_ids(Dom, Dom0),
    sew_dom(do_note, Dom0, Dom1, 1, _).

load_tei(File, Dom) :-
    sgml_register_catalog_file('catalog.fix', start),
    sgml_register_catalog_file('dtd/catalog.tei', start),
    sgml_register_catalog_file('/usr/share/sgml/entities/sgml-iso-entities-8879.1986/catalog', end),
    open(File, read, Input, [encoding(text)]),
    load_sgml_file(stream(Input), [Dom0]),
    close(Input),
    preprocess_tree(Dom0, Dom1),
    map_dom(replace_sdata, Dom1, Dom).

abbr_forename(Name, Abbr) :-
    xpath(Name, /persname/forename(normalize_space), N),
    sub_atom(N, 0, 1, _, First),
    atom_concat(First, '. ', Abbr).

abbreviate_name(Name, Result) :-
    xpath_chk(Name, /persname/surname(normalize_space), Surname),
    findall(Abbr, abbr_forename(Name, Abbr), Forenames),
    atomic_list_concat(Forenames, Forename),
    atom_concat(Forename, Surname, Result).
