:- module(teitools, [load_tei/2, abbreviate_name/2]).
:- use_module(library(sgml)).
:- use_module(library(xpath)).
:- use_module('sgmltools.pl').


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
